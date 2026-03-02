///|
pub using @chai {
  type VNode,
  type Attr,
  type Cmd,
  type Sub,
  start,
  div,
  h1,
  p,
  button,
  text,
  class,
  on_click,
}

///|
struct Model {
  seconds : Int
  running : Bool
}

///|
enum Msg {
  Tick
  Toggle
  Reset
  KeyDown(String)
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ seconds: 0, running: false }, Cmd::after(1000, Toggle))
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    Tick => ({ ..model, seconds: model.seconds + 1 }, Cmd::none())
    Toggle => ({ ..model, running: not(model.running) }, Cmd::none())
    Reset => ({ seconds: 0, running: false }, Cmd::none())
    KeyDown(key) =>
      if key == " " {
        ({ ..model, running: not(model.running) }, Cmd::none())
      } else if key == "r" || key == "R" {
        ({ seconds: 0, running: false }, Cmd::none())
      } else {
        (model, Cmd::none())
      }
  }
}

///|
fn format_time(seconds : Int) -> String {
  let m = seconds / 60
  let s = seconds % 60
  let mm = if m < 10 { "0" + m.to_string() } else { m.to_string() }
  let ss = if s < 10 { "0" + s.to_string() } else { s.to_string() }
  mm + ":" + ss
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class("clock-app")], [
    h1([], [text("Stopwatch")]),
    div([class("display")], [text(format_time(model.seconds))]),
    div([class("controls")], [
      button([class("control-btn"), on_click(fn(_e) { Toggle })], [
        text(if model.running { "Stop" } else { "Start" }),
      ]),
      button([class("control-btn"), on_click(fn(_e) { Reset })], [text("Reset")]),
    ]),
    p([class("hint")], [text("Space = start/stop, R = reset")]),
  ])
}

///|
fn subscriptions(model : Model) -> Sub[Msg] {
  let key_sub = Sub::on_key_down(
    "global-keydown",
    fn(key) { KeyDown(key) },
    prevent_default=true,
  )
  if model.running {
    Sub::batch([Sub::every(1000, "tick-timer", fn() { Tick }), key_sub])
  } else {
    key_sub
  }
}

///|
fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
