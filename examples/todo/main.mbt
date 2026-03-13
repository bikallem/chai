///|
using @chai {
  type VNode,
  type Cmd,
  type Sub,
  type Handle,
  start,
}

///|
using @todo_app { todo_app }

///|
struct Model {
  todo_app_handle : Handle[@todo_app.Msg]
}

///|
type Msg = Unit

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ todo_app_handle: Handle::new() }, Cmd::none())
}

///|
fn update(model : Model, _msg : Msg) -> (Model, Cmd[Msg]) {
  (model, Cmd::none())
}

///|
fn view(model : Model) -> VNode[Msg] {
  todo_app(model.todo_app_handle)
}

///|
fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::none()
}

///|
fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
