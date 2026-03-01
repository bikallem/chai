///|
struct Model {
  counter_a : Handle[@counter.Msg]
  counter_b : Handle[@counter.Msg]
}

///|
enum Msg {
  ResetAll
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ counter_a: Handle::new(), counter_b: Handle::new() }, Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    ResetAll =>
      (
        model,
        Cmd::batch([
          Cmd::send(model.counter_a, @counter.SetValue(0)),
          Cmd::send(model.counter_b, @counter.SetValue(0)),
        ]),
      )
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class_("counters-app")], [
    h1([], [text("Counters")]),
    div([class_("counters")], [
      div([class_("counter-wrapper")], [
        h2([], [text("Counter A")]),
        counter(handle=model.counter_a),
      ]),
      div([class_("counter-wrapper")], [
        h2([], [text("Counter B")]),
        counter(handle=model.counter_b),
      ]),
    ]),
    button([class_("reset-btn"), on_click(fn(_e) { ResetAll })], [
      text("Reset All"),
    ]),
  ])
}

///|
fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::none()
}

///|
fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
