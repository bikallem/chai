///|
enum Status {
  Idle
  Loading
  Loaded(String)
  Failed(String)
}

///|
struct Model {
  post_id : Int
  status : Status
}

///|
enum Msg {
  FetchPost
  GotResult(Result[String, String])
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ post_id: 1, status: Idle }, @chai.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    FetchPost => {
      let url = "https://jsonplaceholder.typicode.com/posts/" +
        model.post_id.to_string()
      (
        { ..model, status: Loading },
        @chai.Cmd::http_get(url, fn(r) { GotResult(r) }),
      )
    }
    GotResult(Ok(body)) =>
      ({ post_id: model.post_id + 1, status: Loaded(body) }, @chai.Cmd::none())
    GotResult(Err(msg)) => ({ ..model, status: Failed(msg) }, @chai.Cmd::none())
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("fetch-app")], [
    @h.h1([], [@h.text("Post Viewer")]),
    @h.p([@h.class("post-id")], [
      @h.text("Post #" + model.post_id.to_string()),
    ]),
    @h.button(
      [@h.class("fetch-btn"), @h.on_click(fn(_e) { FetchPost })],
      [@h.text("Fetch")],
    ),
    @h.div([@h.class("status")], [
      match model.status {
        Idle =>
          @h.p([@h.class("hint")], [
            @h.text("Click Fetch to load a post"),
          ])
        Loading => @h.p([@h.class("loading")], [@h.text("Loading…")])
        Loaded(body) =>
          @h.div([], [
            @h.h2([], [@h.text("Response")]),
            @h.pre([@h.class("body")], [@h.text(body)]),
          ])
        Failed(err) => @h.p([@h.class("error")], [@h.text(err)])
      },
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
