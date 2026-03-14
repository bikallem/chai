///|
struct Model {
  counter_a : @chai.Handle[@counter.Msg]
  counter_b : @chai.Handle[@counter.Msg]
}

///|
enum Msg {
  ResetAll
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  (
    { counter_a: @chai.Handle::new(), counter_b: @chai.Handle::new() },
    @chai.Cmd::none(),
  )
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    ResetAll =>
      (
        model,
        @chai.Cmd::batch([
          @chai.Cmd::send(model.counter_a, @counter.SetValue(0)),
          @chai.Cmd::send(model.counter_b, @counter.SetValue(0)),
        ]),
      )
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("counters-app")], [
    @h.h1([], [@h.text("Counters")]),
    @h.div([@h.class("counters")], [
      @h.div([@h.class("counter-wrapper")], [
        @h.h2([], [@h.text("Counter A")]),
        @counter.counter(handle=model.counter_a),
      ]),
      @h.div([@h.class("counter-wrapper")], [
        @h.h2([], [@h.text("Counter B")]),
        @counter.counter(handle=model.counter_b),
      ]),
    ]),
    @h.button([@h.class("reset-btn"), @h.on_click(fn(_e) { ResetAll })], [
      @h.text("Reset All"),
    ]),
  ])
}

///|
fn subscriptions(_model : Model) -> @chai.Sub[Msg] {
  @chai.Sub::none()
}

///|
fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
