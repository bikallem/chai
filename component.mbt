///|
/// Identity for a component node in the VNode tree.
priv struct ComponentNode {
  id : String
}

///|
/// Opaque handle for sending messages into a child component's update loop.
struct Handle[CMsg] {
  dispatch : Ref[(CMsg) -> Unit]
}

///|
pub fn[CMsg] Handle::new() -> Handle[CMsg] {
  { dispatch: Ref::new(fn(_) {  }) }
}

///|
/// Stores type-erased component state via closure capture.
priv struct ComponentSlot {
  current_expanded : Ref[VNode[Unit]]
  previous_expanded : Ref[VNode[Unit]]
  refresh : (@webapi.JsValue, @webapi.JsValue, @webapi.JsValue) -> Unit
  teardown : () -> Unit
}

///|
priv struct ComponentRuntime {
  component_counter : Ref[Int]
  component_slots : Map[String, ComponentSlot]
  trigger_render : Ref[() -> Unit]
  pending_init_cmds : Array[() -> Unit]
  seen_slots : @hashset.HashSet[String]
}

///|
fn new_component_runtime() -> ComponentRuntime {
  {
    component_counter: Ref::new(0),
    component_slots: {},
    trigger_render: Ref::new(fn() {  }),
    pending_init_cmds: [],
    seen_slots: @hashset.new(),
  }
}

///|
let active_component_runtime : Ref[ComponentRuntime?] = Ref::new(None)

///|
fn[A] erase_component_value(value : A) -> @webapi.JsValue = "%identity"

///|
fn[A] unerase_component_value(value : @webapi.JsValue) -> A = "%identity"

///|
fn current_component_runtime() -> ComponentRuntime {
  guard active_component_runtime.val is Some(runtime) else {
    abort("chai: component() requires an active Chai runtime")
  }
  runtime
}

///|
fn[A] with_component_runtime(runtime : ComponentRuntime, f : () -> A) -> A {
  let previous_runtime = active_component_runtime.val
  active_component_runtime.val = Some(runtime)
  let result = f()
  active_component_runtime.val = previous_runtime
  result
}

///|
fn[CMsg] disconnected_handle_dispatch() -> (CMsg) -> Unit {
  let warned : Ref[Bool] = Ref::new(false)
  fn(_msg) {
    if not(warned.val) {
      warned.val = true
      @webapi.Console::warn([
        "chai: Cmd::send ignored because component handle is unmounted",
      ])
    }
  }
}

///|
/// Create a self-contained component VNode. The component's Model and CMsg
/// types are erased via closure capture; the returned VNode works for any
/// parent Msg type. Pass id~ for stable identity in keyed lists.
pub fn[Model, CMsg, Msg] component(
  id? : String,
  handle? : Handle[CMsg],
  init~ : () -> (Model, Cmd[CMsg]),
  update~ : (Model, CMsg) -> (Model, Cmd[CMsg]),
  view~ : (Model) -> VNode[CMsg],
) -> VNode[Msg] {
  let runtime = current_component_runtime()
  let slot_key = match id {
    Some(s) => "id:" + s
    None => {
      let c = runtime.component_counter.val
      runtime.component_counter.val = c + 1
      "pos:" + c.to_string()
    }
  }
  runtime.seen_slots.add(slot_key)
  match runtime.component_slots.get(slot_key) {
    Some(slot) =>
      (slot.refresh)(
        erase_component_value(update),
        erase_component_value(view),
        erase_component_value(handle),
      )
    None => {
      let (init_model, init_cmd) = init()
      let model_ref : Ref[Model] = Ref::new(init_model)
      let msg_queue : Array[CMsg] = []
      let is_updating : Ref[Bool] = Ref::new(false)
      let update_ref : Ref[(Model, CMsg) -> (Model, Cmd[CMsg])] = Ref::new(
        update,
      )
      let view_ref : Ref[(Model) -> VNode[CMsg]] = Ref::new(view)
      let comp_dispatch_ref : Ref[(CMsg) -> Unit] = Ref::new(fn(_) {  })
      let handle_teardown_ref : Ref[() -> Unit] = Ref::new(fn() {  })
      fn comp_dispatch(cmsg : CMsg) -> Unit {
        (comp_dispatch_ref.val)(cmsg)
      }

      comp_dispatch_ref.val = fn(cmsg) {
        msg_queue.push(cmsg)
        if is_updating.val {
          return
        }
        is_updating.val = true
        while msg_queue.length() > 0 {
          for cursor = 0; cursor < msg_queue.length(); cursor = cursor + 1 {
            let m = msg_queue[cursor]
            let (new_model, cmd) = (update_ref.val)(model_ref.val, m)
            model_ref.val = new_model
            cmd.run(comp_dispatch)
          }
          msg_queue.clear()
        }
        is_updating.val = false
        (runtime.trigger_render.val)()
      }
      fn bind_handle(next_handle : Handle[CMsg]?) -> Unit {
        (handle_teardown_ref.val)()
        handle_teardown_ref.val = match next_handle {
          Some(h) => {
            h.dispatch.val = comp_dispatch
            fn() { h.dispatch.val = disconnected_handle_dispatch() }
          }
          None => fn() {  }
        }
      }
      let render = fn() -> VNode[Unit] {
        with_component_runtime(runtime, fn() {
          bind_events((view_ref.val)(model_ref.val), comp_dispatch)
        })
      }
      let expanded = render()
      let current_expanded_ref : Ref[VNode[Unit]] = Ref::new(expanded)
      let previous_expanded_ref : Ref[VNode[Unit]] = Ref::new(expanded)
      let refresh = fn(
        next_update_js : @webapi.JsValue,
        next_view_js : @webapi.JsValue,
        next_handle_js : @webapi.JsValue,
      ) -> Unit {
        update_ref.val = unerase_component_value(next_update_js)
        view_ref.val = unerase_component_value(next_view_js)
        bind_handle(unerase_component_value(next_handle_js))
        previous_expanded_ref.val = current_expanded_ref.val
        current_expanded_ref.val = render()
      }
      bind_handle(handle)
      let slot : ComponentSlot = {
        current_expanded: current_expanded_ref,
        previous_expanded: previous_expanded_ref,
        refresh,
        teardown: fn() { (handle_teardown_ref.val)() },
      }
      runtime.component_slots[slot_key] = slot
      if init_cmd.tasks.length() > 0 {
        runtime.pending_init_cmds.push(fn() { init_cmd.run(comp_dispatch) })
      }
    }
  }
  Component({ id: slot_key })
}

///|
fn drain_pending_init_cmds_for(runtime : ComponentRuntime) -> Unit {
  for cmd_fn in runtime.pending_init_cmds {
    cmd_fn()
  }
  runtime.pending_init_cmds.clear()
}

///|
/// Reset all component state for a fresh start.
fn reset_component_state_for(runtime : ComponentRuntime) -> Unit {
  runtime.component_slots.each(fn(_, slot) { (slot.teardown)() })
  runtime.component_slots.clear()
  runtime.component_counter.val = 0
  runtime.seen_slots.clear()
}

///|
/// Prepare for a new render pass.
fn begin_render_pass_for(runtime : ComponentRuntime) -> Unit {
  runtime.component_counter.val = 0
  runtime.seen_slots.clear()
}

///|
/// Remove component slots that were not visited during the last render.
fn remove_unused_component_slots_for(runtime : ComponentRuntime) -> Unit {
  let to_remove : Array[String] = []
  runtime.component_slots.each(fn(k, _) {
    if not(runtime.seen_slots.contains(k)) {
      to_remove.push(k)
    }
  })
  for k in to_remove {
    match runtime.component_slots.get(k) {
      Some(slot) => (slot.teardown)()
      None => ()
    }
    runtime.component_slots.remove(k)
  }
}
