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
    let seg = s.to_string()
    if seg.length() > 0 {
      segments.push(seg)
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
fn[Msg] on_window_event(
  key : String,
  event : String,
  parse : () -> Url,
  to_msg : (Url) -> Msg,
) -> Sub[Msg] {
  refreshable_sub(key, "window:" + event, to_msg, fn(dispatch, behavior_ref) {
    let handler : (@webapi.Event) -> Unit = fn(_e) {
      dispatch((behavior_ref.val)(parse()))
    }
    @webapi.window.add_event_listener(event, handler)
    fn() { @webapi.window.remove_event_listener(event, handler) }
  })
}

///|
/// Subscribe to URL changes (popstate events) for pushState-based routing.
pub fn[Msg] Sub::on_url_change(key : String, to_msg : (Url) -> Msg) -> Sub[Msg] {
  on_window_event(key, "popstate", fn() { url_from_location() }, to_msg)
}

///|
/// Subscribe to hash changes for hash-based routing.
pub fn[Msg] Sub::on_hash_change(
  key : String,
  to_msg : (Url) -> Msg,
) -> Sub[Msg] {
  on_window_event(key, "hashchange", fn() { url_from_hash() }, to_msg)
}

///|
fn is_plain_primary_click(e : @webapi.Event) -> Bool {
  let me : @webapi.MouseEvent = e.into()
  me.button() == 0 &&
  not(me.meta_key()) &&
  not(me.ctrl_key()) &&
  not(me.shift_key()) &&
  not(me.alt_key())
}

///|
fn should_intercept_link_click(e : @webapi.Event) -> Bool {
  if e.default_prevented() || not(is_plain_primary_click(e)) {
    return false
  }
  let anchor : @webapi.HTMLAnchorElement = e.current_target().into()
  let target = anchor.target()
  target == "" || target == "_self"
}

///|
fn[Msg] a_with_attrs(
  prefix : Array[Attr[Msg]],
  user : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  for attr in user {
    prefix.push(attr)
  }
  a(prefix, children)
}

///|
/// Create a link that uses pushState navigation. Intercepts only plain primary
/// clicks in the same tab and dispatches the given message.
pub fn[Msg] link(
  url : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
  on_nav~ : Msg,
) -> VNode[Msg] {
  a_with_attrs(
    [
      href(url),
      EventMaybe("click", fn(e) {
        if should_intercept_link_click(e) {
          e.prevent_default()
          Some(on_nav)
        } else {
          None
        }
      }),
    ],
    attrs,
    children,
  )
}

///|
/// Create a link for hash-based navigation. Uses a plain `<a href="#/path">`.
pub fn[Msg] hash_link(
  hash : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  a_with_attrs([href("#" + hash)], attrs, children)
}
