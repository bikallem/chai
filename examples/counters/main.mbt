///|
struct Model {
  initial_count : Int
}

///|
enum Msg {
  ResetAll
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ initial_count: 0 }, Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    ResetAll => ({ initial_count: model.initial_count + 1 }, Cmd::none())
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class_("counters-app")], [
    h1([], [text("Counters")]),
    div([class_("counters")], [
      div([class_("counter-wrapper")], [
        h2([], [text("Counter A")]),
        counter(model.initial_count),
      ]),
      div([class_("counter-wrapper")], [
        h2([], [text("Counter B")]),
        counter(model.initial_count),
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
