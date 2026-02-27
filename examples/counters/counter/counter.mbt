///|
pub(all) struct Model {
  count : Int
}

///|
pub(all) enum Msg {
  Increment
  Decrement
}

///|
pub fn counter_init() -> (Model, Cmd[Msg]) {
  ({ count: 0 }, Cmd::none())
}

///|
pub fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, Cmd::none())
    Decrement => ({ count: model.count - 1 }, Cmd::none())
  }
}

///|
pub fn view(model : Model) -> VNode[Msg] {
  div([class_("counter")], [
    button([class_("counter-btn"), on_click(fn(_e) { Decrement })], [text("-")]),
    span([class_("counter-value")], [text(model.count.to_string())]),
    button([class_("counter-btn"), on_click(fn(_e) { Increment })], [text("+")]),
  ])
}

///|
/// Self-contained counter component. When reset_gen changes, the
/// framework destroys and remounts the counter (resetting to 0).
pub fn[ParentMsg] widget(reset_gen : Int) -> VNode[ParentMsg] {
  component(
    props_fingerprint=reset_gen,
    init=fn() { ({ count: 0 }, Cmd::none()) },
    update~,
    view~,
  )
}
