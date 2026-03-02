///|
pub using @chai {
  type VNode,
  type Attr,
  type Cmd,
  type Handle,
  div,
  span,
  button,
  text,
  class,
  on_click,
  component,
}

///|
pub(all) struct Model {
  count : Int
}

///|
pub(all) enum Msg {
  Increment
  Decrement
  SetValue(Int)
}

///|
pub fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, Cmd::none())
    Decrement => ({ count: model.count - 1 }, Cmd::none())
    SetValue(n) => ({ count: n }, Cmd::none())
  }
}

///|
pub fn view(model : Model) -> VNode[Msg] {
  div([class("counter")], [
    button([class("counter-btn"), on_click(fn(_e) { Decrement })], [text("-")]),
    span([class("counter-value")], [text(model.count.to_string())]),
    button([class("counter-btn"), on_click(fn(_e) { Increment })], [text("+")]),
  ])
}

///|
/// Self-contained counter component. Optionally accepts a Handle for
/// parent-to-child messaging (e.g. SetValue).
pub fn[ParentMsg] counter(handle? : Handle[Msg]) -> VNode[ParentMsg] {
  component(handle?, init=fn() { ({ count: 0 }, Cmd::none()) }, update~, view~)
}
