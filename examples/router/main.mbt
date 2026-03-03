///|
using @chai {
  type VNode,
  type Cmd,
  type Sub,
  type Url,
  start,
  div,
  h1,
  h2,
  p,
  nav,
  text,
  class,
  hash_url,
  hash_link,
}

///|
enum Route {
  Home
  About
  NotFound
}

///|
struct Model {
  route : Route
}

///|
enum Msg {
  UrlChanged(Url)
}

///|
fn to_route(url : Url) -> Route {
  match url.path {
    [] => Home
    ["about"] => About
    _ => NotFound
  }
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ route: to_route(hash_url()) }, Cmd::none())
}

///|
fn update(_model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    UrlChanged(url) => ({ route: to_route(url) }, Cmd::none())
  }
}

///|
fn view_nav() -> VNode[Msg] {
  nav([class("nav")], [
    hash_link("/", [class("nav-link")], [text("Home")]),
    hash_link("/about", [class("nav-link")], [text("About")]),
    hash_link("/nowhere", [class("nav-link")], [text("???")]),
  ])
}

///|
fn view_page(route : Route) -> VNode[Msg] {
  match route {
    Home =>
      div([class("page")], [
        h2([], [text("Home")]),
        p([], [text("Welcome to the Chai router example.")]),
      ])
    About =>
      div([class("page")], [
        h2([], [text("About")]),
        p([], [text("Chai is a TEA framework for MoonBit.")]),
      ])
    NotFound =>
      div([class("page")], [
        h2([], [text("404")]),
        p([], [text("Page not found.")]),
      ])
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class("app")], [
    h1([], [text("Router Demo")]),
    view_nav(),
    view_page(model.route),
  ])
}

///|
fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::on_hash_change("url", fn(url) { UrlChanged(url) })
}

///|
fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
