///|
using @chai {
  type VNode,
  type Cmd,
  type Sub,
  type Handle,
  start,
  div,
  h1,
  h2,
  button,
  text,
  class,
  on_click,
}

///|
using @counter {counter}

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
  div([class("counters-app")], [
    h1([], [text("Counters")]),
    div([class("counters")], [
      div([class("counter-wrapper")], [
        h2([], [text("Counter A")]),
        counter(handle=model.counter_a),
      ]),
      div([class("counter-wrapper")], [
        h2([], [text("Counter B")]),
        counter(handle=model.counter_b),
      ]),
    ]),
    button([class("reset-btn"), on_click(fn(_e) { ResetAll })], [
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
