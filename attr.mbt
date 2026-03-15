///|
enum Attr[Msg] {
  Attribute(String, String)
  Property(String, @webapi.JsValue)
  Event(String, (@webapi.Event) -> Msg)
  EventMaybe(String, (@webapi.Event) -> Msg?)
  BoundEvent(String, (@webapi.Event) -> Unit)
  Style(String, String)
}

///|
pub fn[A, B] Attr::map(self : Attr[A], f : (A) -> B) -> Attr[B] {
  match self {
    Attribute(k, v) => Attribute(k, v)
    Property(k, v) => Property(k, v)
    Event(name, handler) => on(name, fn(e) { f(handler(e)) })
    EventMaybe(name, handler) => EventMaybe(name, fn(e) { handler(e).map(f) })
    BoundEvent(name, handler) => BoundEvent(name, handler)
    Style(k, v) => Style(k, v)
  }
}

///|
/// Generic event handler for any event name not covered by helpers.
pub fn[Msg] on(name : String, handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event(name, handler)
}

///|
/// A generic attribute function for any attribute name and value.
pub fn[V : Show, Msg] attr(attr_name : String, value : V) -> Attr[Msg] {
  Attribute(attr_name, value.to_string())
}

///|
/// A generic style property function.
pub fn[Msg] style(name : String, value : String) -> Attr[Msg] {
  Style(name, value)
}

///|
/// A generic DOM property function.
pub fn[Msg] property(name : String, value : @webapi.JsValue) -> Attr[Msg] {
  Property(name, value)
}
