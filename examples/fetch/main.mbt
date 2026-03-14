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
  @chai.div([@chai.class("fetch-app")], [
    @chai.h1([], [@chai.text("Post Viewer")]),
    @chai.p([@chai.class("post-id")], [
      @chai.text("Post #" + model.post_id.to_string()),
    ]),
    @chai.button(
      [@chai.class("fetch-btn"), @chai.on_click(fn(_e) { FetchPost })],
      [@chai.text("Fetch")],
    ),
    @chai.div([@chai.class("status")], [
      match model.status {
        Idle =>
          @chai.p([@chai.class("hint")], [
            @chai.text("Click Fetch to load a post"),
          ])
        Loading => @chai.p([@chai.class("loading")], [@chai.text("Loading…")])
        Loaded(body) =>
          @chai.div([], [
            @chai.h2([], [@chai.text("Response")]),
            @chai.pre([@chai.class("body")], [@chai.text(body)]),
          ])
        Failed(err) => @chai.p([@chai.class("error")], [@chai.text(err)])
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
