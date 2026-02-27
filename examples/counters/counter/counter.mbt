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
pub fn counter_init() -> (Model, @mvdom.Cmd[Msg]) {
  ({ count: 0 }, @mvdom.Cmd::none())
}

///|
pub fn update(model : Model, msg : Msg) -> (Model, @mvdom.Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, @mvdom.Cmd::none())
    Decrement => ({ count: model.count - 1 }, @mvdom.Cmd::none())
  }
}

///|
pub fn view(model : Model) -> @mvdom.VNode[Msg] {
  @mvdom.div([@mvdom.class_("counter")], [
    @mvdom.button(
      [@mvdom.class_("counter-btn"), @mvdom.on_click(fn(_e) { Decrement })],
      [@mvdom.text("-")],
    ),
    @mvdom.span([@mvdom.class_("counter-value")], [
      @mvdom.text(model.count.to_string()),
    ]),
    @mvdom.button(
      [@mvdom.class_("counter-btn"), @mvdom.on_click(fn(_e) { Increment })],
      [@mvdom.text("+")],
    ),
  ])
}

///|
/// Self-contained counter component. When reset_gen changes, the
/// framework destroys and remounts the counter (resetting to 0).
pub fn[ParentMsg] widget(reset_gen : Int) -> @mvdom.VNode[ParentMsg] {
  @mvdom.component(
    props_fingerprint=reset_gen,
    init=fn() { ({ count: 0 }, @mvdom.Cmd::none()) },
    update~,
    view~,
  )
}
