///|
using @chai {
  type VNode,
  type Cmd,
  type Sub,
  start,
  div,
  h1,
  h2,
  p,
  button,
  pre,
  text,
  class,
  on_click,
}

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
fn app_init() -> (Model, Cmd[Msg]) {
  ({ post_id: 1, status: Idle }, Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    FetchPost => {
      let url = "https://jsonplaceholder.typicode.com/posts/" +
        model.post_id.to_string()
      ({ ..model, status: Loading }, Cmd::http_get(url, fn(r) { GotResult(r) }))
    }
    GotResult(Ok(body)) =>
      ({ post_id: model.post_id + 1, status: Loaded(body) }, Cmd::none())
    GotResult(Err(msg)) => ({ ..model, status: Failed(msg) }, Cmd::none())
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class("fetch-app")], [
    h1([], [text("Post Viewer")]),
    p([class("post-id")], [text("Post #" + model.post_id.to_string())]),
    button([class("fetch-btn"), on_click(fn(_e) { FetchPost })], [text("Fetch")]),
    div([class("status")], [
      match model.status {
        Idle => p([class("hint")], [text("Click Fetch to load a post")])
        Loading => p([class("loading")], [text("Loading…")])
        Loaded(body) =>
          div([], [
            h2([], [text("Response")]),
            pre([class("body")], [text(body)]),
          ])
        Failed(err) => p([class("error")], [text(err)])
      },
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
