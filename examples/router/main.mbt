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
  UrlChanged(@chai.Url)
}

///|
fn to_route(url : @chai.Url) -> Route {
  match url.path {
    [] => Home
    ["about"] => About
    _ => NotFound
  }
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ route: to_route(@chai.hash_url()) }, @chai.Cmd::none())
}

///|
fn update(_model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    UrlChanged(url) => ({ route: to_route(url) }, @chai.Cmd::none())
  }
}

///|
fn view_nav() -> @chai.VNode[Msg] {
  @chai.nav([@chai.class("nav")], [
    @chai.hash_link("/", [@chai.class("nav-link")], [@chai.text("Home")]),
    @chai.hash_link("/about", [@chai.class("nav-link")], [@chai.text("About")]),
    @chai.hash_link("/nowhere", [@chai.class("nav-link")], [@chai.text("???")]),
  ])
}

///|
fn view_page(route : Route) -> @chai.VNode[Msg] {
  match route {
    Home =>
      @chai.div([@chai.class("page")], [
        @chai.h2([], [@chai.text("Home")]),
        @chai.p([], [@chai.text("Welcome to the Chai router example.")]),
      ])
    About =>
      @chai.div([@chai.class("page")], [
        @chai.h2([], [@chai.text("About")]),
        @chai.p([], [@chai.text("Chai is a TEA framework for MoonBit.")]),
      ])
    NotFound =>
      @chai.div([@chai.class("page")], [
        @chai.h2([], [@chai.text("404")]),
        @chai.p([], [@chai.text("Page not found.")]),
      ])
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @chai.div([@chai.class("app")], [
    @chai.h1([], [@chai.text("Router Demo")]),
    view_nav(),
    view_page(model.route),
  ])
}

///|
fn subscriptions(_model : Model) -> @chai.Sub[Msg] {
  @chai.Sub::on_hash_change("url", fn(url) { UrlChanged(url) })
}

///|
fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
