///|
struct Model {
  reset_gen : Int
}

///|
enum Msg {
  ResetAll
}

///|
fn app_init() -> (Model, @mvdom.Cmd[Msg]) {
  ({ reset_gen: 0 }, @mvdom.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @mvdom.Cmd[Msg]) {
  match msg {
    ResetAll => ({ reset_gen: model.reset_gen + 1 }, @mvdom.Cmd::none())
  }
}

///|
fn view(model : Model) -> @mvdom.VNode[Msg] {
  @mvdom.div([@mvdom.class_("counters-app")], [
    @mvdom.h1([], [@mvdom.text("Counters")]),
    @mvdom.div([@mvdom.class_("counters")], [
      @mvdom.div([@mvdom.class_("counter-wrapper")], [
        @mvdom.h2([], [@mvdom.text("Counter A")]),
        @counter.widget(model.reset_gen),
      ]),
      @mvdom.div([@mvdom.class_("counter-wrapper")], [
        @mvdom.h2([], [@mvdom.text("Counter B")]),
        @counter.widget(model.reset_gen),
      ]),
    ]),
    @mvdom.button(
      [@mvdom.class_("reset-btn"), @mvdom.on_click(fn(_e) { ResetAll })],
      [@mvdom.text("Reset All")],
    ),
  ])
}

///|
fn subscriptions(_model : Model) -> @mvdom.Sub[Msg] {
  @mvdom.Sub::none()
}

///|
fn main {
  @mvdom.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
