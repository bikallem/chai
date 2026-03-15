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
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ seconds: 0, running: false }, @chai.Cmd::after(1000, Toggle))
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Tick => ({ ..model, seconds: model.seconds + 1 }, @chai.Cmd::none())
    Toggle => ({ ..model, running: not(model.running) }, @chai.Cmd::none())
    Reset => ({ seconds: 0, running: false }, @chai.Cmd::none())
    KeyDown(key) =>
      match key {
        " " => update(model, Toggle)
        "r" | "R" => update(model, Reset)
        _ => (model, @chai.Cmd::none())
      }
  }
}

///|
fn pad2(n : Int) -> String {
  if n < 10 {
    "0" + n.to_string()
  } else {
    n.to_string()
  }
}

///|
fn format_time(seconds : Int) -> String {
  pad2(seconds / 60) + ":" + pad2(seconds % 60)
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("clock-app")], [
    @h.h1([], [@h.text("Stopwatch")]),
    @h.div([@h.class("display")], [@h.text(format_time(model.seconds))]),
    @h.div([@h.class("controls")], [
      @h.button([@h.class("control-btn"), @h.on_click(fn(_e) { Toggle })], [
        @h.text(if model.running { "Stop" } else { "Start" }),
      ]),
      @h.button([@h.class("control-btn"), @h.on_click(fn(_e) { Reset })], [
        @h.text("Reset"),
      ]),
    ]),
    @h.p([@h.class("hint")], [@h.text("Space = start/stop, R = reset")]),
  ])
}

///|
fn subscriptions(model : Model) -> @chai.Sub[Msg] {
  let key_sub = @chai.Sub::on_key_down(
    "global-keydown",
    fn(key) { KeyDown(key) },
    prevent_default=fn(key) { key == " " || key == "r" || key == "R" },
  )
  if model.running {
    @chai.Sub::batch([
      @chai.Sub::every(1000, "tick-timer", fn() { Tick }),
      key_sub,
    ])
  } else {
    key_sub
  }
}

///|
fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
