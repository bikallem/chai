///|
pub struct Url {
  path : Array[String]
  query : String
  hash : String
}

///|
fn parse_path(pathname : String) -> Array[String] {
  let segments : Array[String] = []
  for s in pathname.split("/") {
    let str = s.to_string()
    if str.length() > 0 {
      segments.push(str)
    }
  }
  segments
}

///|
fn url_from_location() -> Url {
  let loc = @webapi.window.location()
  { path: parse_path(loc.pathname()), query: loc.search(), hash: loc.hash() }
}

///|
fn url_from_hash() -> Url {
  let raw = @webapi.window.location().hash()
  let s = match raw.strip_prefix("#") {
    Some(v) => v.to_string()
    None => raw
  }
  let (path_part, query) = match s.find("?") {
    Some(qmark) =>
      (
        s.view(end_offset=qmark).to_string(),
        s.view(start_offset=qmark).to_string(),
      )
    None => (s, "")
  }
  { path: parse_path(path_part), query, hash: "" }
}

///|
/// Get the current URL from the browser location (for pushState-based routing).
pub fn url() -> Url {
  url_from_location()
}

///|
/// Get the current hash fragment parsed as a URL (for hash-based routing).
pub fn hash_url() -> Url {
  url_from_hash()
}

///|
fn dispatch_popstate() -> Unit {
  @webapi.window.dispatch_event(@webapi.PopStateEvent::new("popstate"))
  |> ignore
}

///|
/// Navigate to a new URL using pushState. Triggers `on_url_change` subscribers.
pub fn[Msg] Cmd::push_url(url : String) -> Cmd[Msg] {
  Cmd::task(fn(_dispatch) {
    @webapi.window.history().push_state(@webapi.JsValue::null(), "", url~)
    dispatch_popstate()
  })
}

///|
/// Replace the current URL using replaceState. Triggers `on_url_change` subscribers.
pub fn[Msg] Cmd::replace_url(url : String) -> Cmd[Msg] {
  Cmd::task(fn(_dispatch) {
    @webapi.window.history().replace_state(@webapi.JsValue::null(), "", url~)
    dispatch_popstate()
  })
}

///|
/// Set the location hash. Triggers `on_hash_change` subscribers natively.
pub fn[Msg] Cmd::push_hash(hash : String) -> Cmd[Msg] {
  Cmd::task(fn(_dispatch) { @webapi.window.location().set_hash(hash) })
}

///|
/// Subscribe to URL changes (popstate events) for pushState-based routing.
pub fn[Msg] Sub::on_url_change(key : String, to_msg : (Url) -> Msg) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler : (@webapi.Event) -> Unit = fn(_e) {
      dispatch(to_msg(url_from_location()))
    }
    @webapi.window.add_event_listener("popstate", handler)
    fn() { @webapi.window.remove_event_listener("popstate", handler) }
  })
}

///|
/// Subscribe to hash changes for hash-based routing.
pub fn[Msg] Sub::on_hash_change(
  key : String,
  to_msg : (Url) -> Msg,
) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler : (@webapi.Event) -> Unit = fn(_e) {
      dispatch(to_msg(url_from_hash()))
    }
    @webapi.window.add_event_listener("hashchange", handler)
    fn() { @webapi.window.remove_event_listener("hashchange", handler) }
  })
}

///|
/// Create a link that uses pushState navigation. Prevents default click behavior
/// and dispatches the given message instead.
pub fn[Msg] link(
  url : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
  on_nav~ : Msg,
) -> VNode[Msg] {
  let all_attrs = [
    href(url),
    on("click", fn(e) {
      e.prevent_default()
      on_nav
    }),
  ]
  for attr in attrs {
    all_attrs.push(attr)
  }
  a(all_attrs, children)
}

///|
/// Create a link for hash-based navigation. Uses a plain `<a href="#/path">`.
pub fn[Msg] hash_link(
  hash : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  let all_attrs : Array[Attr[Msg]] = [href("#" + hash)]
  for attr in attrs {
    all_attrs.push(attr)
  }
  a(all_attrs, children)
}
