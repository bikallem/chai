///|
/// A self-contained component with type-erased internal state.
/// The component's Model and Msg types are hidden inside the mount closure.
pub(all) struct Component {
  key : String
  props_fingerprint : Int
  mount : () -> @webapi.Node
}

///|
/// Create a component specification. The returned Component captures
/// init/update/view in a closure, erasing the Model and Msg types.
pub fn[Model, Msg] component(
  key~ : String,
  props_fingerprint~ : Int,
  init~ : () -> (Model, Cmd[Msg]),
  update~ : (Model, Msg) -> (Model, Cmd[Msg]),
  view~ : (Model) -> VNode[Msg],
) -> Component {
  {
    key,
    props_fingerprint,
    mount: fn() { mount_component(init, update, view) },
  }
}

///|
/// Wrap a Component as a VNode for embedding in a parent view tree.
pub fn[Msg] embed(spec : Component) -> VNode[Msg] {
  Embed(spec)
}

///|
/// Mount a component: creates a wrapper div with display:contents and
/// sets up an independent mini TEA runtime inside it.
fn[Model, Msg] mount_component(
  init : () -> (Model, Cmd[Msg]),
  update : (Model, Msg) -> (Model, Cmd[Msg]),
  view : (Model) -> VNode[Msg],
) -> @webapi.Node {
  // Wrapper element — invisible to layout
  let wrapper = @webapi.document.create_element("div")
  set_style_ffi(@webapi.TJsValue::to_js(wrapper), "display", "contents")
  let wrapper_node : @webapi.Node = @webapi.TJsValue::to_js(wrapper).into()
  // Mutable state
  let (init_model, init_cmd) = init()
  let state : Ref[Model] = Ref::new(init_model)
  let current_vdom : Ref[VNode[Msg]] = Ref::new(Text(""))
  let msg_queue : Array[Msg] = []
  let is_updating : Ref[Bool] = Ref::new(false)
  // Forward-declare dispatch
  let dispatch_ref : Ref[(Msg) -> Unit] = Ref::new(fn(_msg) {  })
  fn dispatch(msg : Msg) -> Unit {
    (dispatch_ref.val)(msg)
  }

  fn process_queue() -> Unit {
    if is_updating.val {
      return
    }
    is_updating.val = true
    while msg_queue.length() > 0 {
      let msg = msg_queue.remove(0)
      let (new_model, cmd) = update(state.val, msg)
      state.val = new_model
      let new_vdom = view(new_model)
      diff(wrapper_node, 0, current_vdom.val, new_vdom, dispatch)
      current_vdom.val = new_vdom
      for task in cmd.tasks {
        task(dispatch)
      }
    }
    is_updating.val = false
  }

  dispatch_ref.val = fn(msg) {
    msg_queue.push(msg)
    process_queue()
  }
  // Initial render
  let initial_vdom = view(init_model)
  let dom_node = create_dom_node(initial_vdom, dispatch)
  wrapper_node.append_child(dom_node) |> ignore
  current_vdom.val = initial_vdom
  // Execute initial commands
  for task in init_cmd.tasks {
    task(dispatch)
  }
  wrapper_node
}
