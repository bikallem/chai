///|
struct Model {
  strokes : Array[Array[(Double, Double)]]
  drawing : Bool
}

///|
enum Msg {
  Down(Double, Double)
  Move(Double, Double)
  Up
  Clear
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ strokes: [], drawing: false }, @chai.Cmd::none())
}

///|
fn redraw(model : Model) -> @chai.Cmd[Msg] {
  @chai.Cmd::task(fn(_dispatch) {
    let canvas : @webapi.HTMLCanvasElement = @webapi.document()
      .get_element_by_id("draw-canvas")
      .into()
    let ctx : @webapi.CanvasRenderingContext2D = canvas
      .get_context("2d")
      .unwrap()
      .into()
    let w = canvas.width().to_double()
    let h = canvas.height().to_double()
    ctx.clear_rect(0.0, 0.0, w, h)
    ctx
    ..set_stroke_style("#333")
    ..set_line_width(2.0)
    .set_line_cap(@webapi.CanvasLineCap::Round)
    for stroke in model.strokes {
      if stroke.length() > 0 {
        ctx.begin_path()
        ctx.move_to(stroke[0].0, stroke[0].1)
        for i = 1; i < stroke.length(); i = i + 1 {
          ctx.line_to(stroke[i].0, stroke[i].1)
        }
        ctx.stroke()
      }
    }
  })
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Down(x, y) => {
      let strokes = model.strokes.copy()
      strokes.push([(x, y)])
      let m = { strokes, drawing: true }
      (m, redraw(m))
    }
    Move(x, y) =>
      if model.drawing && model.strokes.length() > 0 {
        let strokes = model.strokes.copy()
        let i = strokes.length() - 1
        let last = strokes[i].copy()
        last.push((x, y))
        strokes[i] = last
        let m = { ..model, strokes, }
        (m, redraw(m))
      } else {
        (model, @chai.Cmd::none())
      }
    Up => ({ ..model, drawing: false }, @chai.Cmd::none())
    Clear => {
      let m = { strokes: [], drawing: false }
      (m, redraw(m))
    }
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @chai.div([@chai.class("canvas-app")], [
    @chai.h1([], [@chai.text("Drawing Pad")]),
    @chai.el(
      "canvas",
      [
        @chai.id("draw-canvas"),
        @chai.attr("width", "600"),
        @chai.attr("height", "400"),
        @chai.class("draw-canvas"),
        @chai.on("mousedown", fn(e) {
          let me : @webapi.MouseEvent = e.into()
          Down(me.offset_x(), me.offset_y())
        }),
        @chai.on("mousemove", fn(e) {
          let me : @webapi.MouseEvent = e.into()
          Move(me.offset_x(), me.offset_y())
        }),
        @chai.on("mouseup", fn(_e) { Up }),
        @chai.on("mouseleave", fn(_e) { Up }),
      ],
      [],
    ),
    @chai.div([@chai.class("controls")], [
      @chai.button(
        [@chai.class("clear-btn"), @chai.on_click(fn(_e) { Clear })],
        [@chai.text("Clear")],
      ),
      @chai.div(
        [@chai.class("stroke-count"), @chai.style("display", "inline-block")],
        [@chai.text(model.strokes.length().to_string() + " strokes")],
      ),
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
