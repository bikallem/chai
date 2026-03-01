///|
/// Identity for a component node in the VNode tree.
priv struct ComponentNode {
  id : Int
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
  key : Ref[Int]
  current_expanded : Ref[VNode[Unit]]
  previous_expanded : Ref[VNode[Unit]]
  reinit : () -> Unit
  render : () -> VNode[Unit]
}

///|
let component_counter : Ref[Int] = Ref::new(0)

///|
let component_slots : Array[ComponentSlot] = []

///|
let trigger_render : Ref[() -> Unit] = Ref::new(fn() {  })

///|
let pending_init_cmds : Array[() -> Unit] = []

///|
/// Create a self-contained component VNode. The component's Model and CMsg
/// types are erased via closure capture; the returned VNode works for any
/// parent Msg type. When key changes, the component reinitializes its state.
pub fn[Model, CMsg, Msg] component(
  key? : Int = 0,
  handle? : Handle[CMsg],
  init~ : () -> (Model, Cmd[CMsg]),
  update~ : (Model, CMsg) -> (Model, Cmd[CMsg]),
  view~ : (Model) -> VNode[CMsg],
) -> VNode[Msg] {
  let id = component_counter.val
  component_counter.val = id + 1
  if id < component_slots.length() {
    // Existing slot
    let slot = component_slots[id]
    if slot.key.val != key {
      slot.key.val = key
      (slot.reinit)()
    }
    slot.previous_expanded.val = slot.current_expanded.val
    slot.current_expanded.val = (slot.render)()
  } else {
    // New slot — create typed refs captured by closures
    let (init_model, init_cmd) = init()
    let model_ref : Ref[Model] = Ref::new(init_model)
    let comp_dispatch_ref : Ref[(CMsg) -> Unit] = Ref::new(fn(_) {  })
    fn comp_dispatch(cmsg : CMsg) -> Unit {
      (comp_dispatch_ref.val)(cmsg)
    }

    comp_dispatch_ref.val = fn(cmsg) {
      let (new_model, cmd) = update(model_ref.val, cmsg)
      model_ref.val = new_model
      for task in cmd.tasks {
        task(comp_dispatch)
      }
      (trigger_render.val)()
    }
    match handle {
      Some(h) => h.dispatch.val = comp_dispatch
      None => ()
    }
    let render = fn() -> VNode[Unit] {
      bind_events(view(model_ref.val), comp_dispatch)
    }
    let reinit = fn() {
      let (m, cmd) = init()
      model_ref.val = m
      for task in cmd.tasks {
        task(comp_dispatch)
      }
    }
    let expanded = render()
    let slot : ComponentSlot = {
      key: Ref::new(key),
      current_expanded: Ref::new(expanded),
      previous_expanded: Ref::new(expanded),
      reinit,
      render,
    }
    component_slots.push(slot)
    // Queue init cmd tasks for processing after DOM is built
    if init_cmd.tasks.length() > 0 {
      pending_init_cmds.push(fn() {
        for task in init_cmd.tasks {
          task(comp_dispatch)
        }
      })
    }
  }
  Embed({ id, })
}
