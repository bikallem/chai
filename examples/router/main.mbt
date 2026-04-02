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
  @h.nav([@h.class("nav")], [
    @chai.hash_link("/", [@h.class("nav-link")], [@h.text("Home")]),
    @chai.hash_link("/about", [@h.class("nav-link")], [@h.text("About")]),
    @chai.hash_link("/nowhere", [@h.class("nav-link")], [@h.text("???")]),
  ])
}

///|
fn view_page(route : Route) -> @chai.VNode[Msg] {
  match route {
    Home =>
      @h.div([@h.class("page")], [
        @h.h2([], [@h.text("Home")]),
        @h.p([], [@h.text("Welcome to the Chai router example.")]),
      ])
    About =>
      @h.div([@h.class("page")], [
        @h.h2([], [@h.text("About")]),
        @h.p([], [@h.text("Chai is a TEA framework for MoonBit.")]),
      ])
    NotFound =>
      @h.div([@h.class("page")], [
        @h.h2([], [@h.text("404")]),
        @h.p([], [@h.text("Page not found.")]),
      ])
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("app")], [
    @h.h1([], [@h.text("Router Demo")]),
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
