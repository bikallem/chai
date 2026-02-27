///|
/// A self-contained component with type-erased internal state.
/// The component's Model and Msg types are hidden inside the mount closure.
struct Component {
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
