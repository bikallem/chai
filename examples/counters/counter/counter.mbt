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
pub fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, @chai.Cmd::none())
    Decrement => ({ count: model.count - 1 }, @chai.Cmd::none())
    SetValue(n) => ({ count: n }, @chai.Cmd::none())
  }
}

///|
pub fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("counter")], [
    @h.button([@h.class("counter-btn"), @h.on_click(fn(_e) { Decrement })], [
      @h.text("-"),
    ]),
    @h.span([@h.class("counter-value")], [@h.text(model.count.to_string())]),
    @h.button([@h.class("counter-btn"), @h.on_click(fn(_e) { Increment })], [
      @h.text("+"),
    ]),
  ])
}

///|
/// Self-contained counter component. Optionally accepts a Handle for
/// parent-to-child messaging (e.g. SetValue).
pub fn[ParentMsg] counter(
  handle? : @chai.Handle[Msg],
) -> @chai.VNode[ParentMsg] {
  @chai.component(
    handle?,
    init=fn() { ({ count: 0 }, @chai.Cmd::none()) },
    update~,
    view~,
  )
}
