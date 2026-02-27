///|
/// A self-contained component with type-erased internal state.
/// The component's Model and Msg types are hidden inside the mount closure.
priv struct Component {
  key : String
  props_fingerprint : Int
  mount : () -> @webapi.Node
}

///|
/// Create a self-contained component VNode. The component's Model and CMsg
/// types are erased via closure capture; the returned VNode works for any
/// parent Msg type.
pub fn[Model, CMsg, Msg] component(
  key~ : String,
  props_fingerprint~ : Int,
  init~ : () -> (Model, Cmd[CMsg]),
  update~ : (Model, CMsg) -> (Model, Cmd[CMsg]),
  view~ : (Model) -> VNode[CMsg],
) -> VNode[Msg] {
  Embed({
    key,
    props_fingerprint,
    mount: fn() { mount_component(init, update, view) },
  })
}

///|
/// Mount a component: creates a wrapper div with display:contents and
/// boots an independent TEA runtime inside it.
fn[Model, Msg] mount_component(
  init : () -> (Model, Cmd[Msg]),
  update : (Model, Msg) -> (Model, Cmd[Msg]),
  view : (Model) -> VNode[Msg],
) -> @webapi.Node {
  let wrapper = @webapi.document.create_element("div")
  set_style_ffi(@webapi.TJsValue::to_js(wrapper), "display", "contents")
  let wrapper_node : @webapi.Node = @webapi.TJsValue::to_js(wrapper).into()
  boot(wrapper_node, init, update, view, fn(_model, _dispatch) {  })
  wrapper_node
}
