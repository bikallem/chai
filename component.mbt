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
  render : () -> VNode[Unit]
  teardown : () -> Unit
}

///|
let component_counter : Ref[Int] = Ref::new(0)

///|
let component_slots : Map[String, ComponentSlot] = {}

///|
let trigger_render : Ref[() -> Unit] = Ref::new(fn() {  })

///|
let pending_init_cmds : Array[() -> Unit] = []

///|
let seen_slots : @hashset.HashSet[String] = @hashset.new()

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
  let slot_key = match id {
    Some(s) => "id:" + s
    None => {
      let c = component_counter.val
      component_counter.val = c + 1
      "pos:" + c.to_string()
    }
  }
  seen_slots.add(slot_key)
  match component_slots.get(slot_key) {
    Some(slot) => {
      slot.previous_expanded.val = slot.current_expanded.val
      slot.current_expanded.val = (slot.render)()
    }
    None => {
      let (init_model, init_cmd) = init()
      let model_ref : Ref[Model] = Ref::new(init_model)
      let msg_queue : Array[CMsg] = []
      let is_updating : Ref[Bool] = Ref::new(false)
      let comp_dispatch_ref : Ref[(CMsg) -> Unit] = Ref::new(fn(_) {  })
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
          let batch = msg_queue.copy()
          msg_queue.clear()
          for m in batch {
            let (new_model, cmd) = update(model_ref.val, m)
            model_ref.val = new_model
            cmd.run(comp_dispatch)
          }
        }
        is_updating.val = false
        (trigger_render.val)()
      }
      match handle {
        Some(h) => h.dispatch.val = comp_dispatch
        None => ()
      }
      let teardown = match handle {
        Some(h) => fn() { h.dispatch.val = disconnected_handle_dispatch() }
        None => fn() {  }
      }
      let render = fn() -> VNode[Unit] {
        bind_events(view(model_ref.val), comp_dispatch)
      }
      let expanded = render()
      let slot : ComponentSlot = {
        current_expanded: Ref::new(expanded),
        previous_expanded: Ref::new(expanded),
        render,
        teardown,
      }
      component_slots[slot_key] = slot
      if init_cmd.tasks.length() > 0 {
        pending_init_cmds.push(fn() { init_cmd.run(comp_dispatch) })
      }
    }
  }
  Component({ id: slot_key })
}

///|
fn drain_pending_init_cmds() -> Unit {
  while pending_init_cmds.length() > 0 {
    let batch = pending_init_cmds.copy()
    pending_init_cmds.clear()
    for cmd_fn in batch {
      cmd_fn()
    }
  }
}

///|
/// Reset all component state for a fresh start.
fn reset_component_state() -> Unit {
  component_slots.each(fn(_, slot) { (slot.teardown)() })
  component_slots.clear()
  component_counter.val = 0
  seen_slots.clear()
}

///|
/// Prepare for a new render pass.
fn begin_render_pass() -> Unit {
  component_counter.val = 0
  seen_slots.clear()
}

///|
fn[V] remove_unless(
  map : Map[String, V],
  keep : @hashset.HashSet[String],
  on_remove : (V) -> Unit,
) -> Unit {
  let to_remove : Array[String] = []
  map.each(fn(k, _) { if not(keep.contains(k)) { to_remove.push(k) } })
  for k in to_remove {
    match map.get(k) {
      Some(v) => on_remove(v)
      None => ()
    }
    map.remove(k)
  }
}

///|
/// Remove component slots that were not visited during the last render.
fn remove_unused_component_slots() -> Unit {
  remove_unless(component_slots, seen_slots, fn(slot) { (slot.teardown)() })
}
