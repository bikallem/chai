///|
enum Attr[Msg] {
  Attribute(String, String)
  Property(String, String)
  BoolProperty(String, Bool)
  Event(String, (@webapi.Event) -> Msg)
  Style(String, String)
}

///|
pub fn[A, B] Attr::map(self : Attr[A], f : (A) -> B) -> Attr[B] {
  match self {
    Attribute(k, v) => Attribute(k, v)
    Property(k, v) => Property(k, v)
    BoolProperty(k, v) => BoolProperty(k, v)
    Event(name, handler) => Event(name, fn(e) { f(handler(e)) })
    Style(k, v) => Style(k, v)
  }
}

///|
pub fn[Msg] on_click(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event("click", handler)
}

///|
pub fn[Msg] on_input(handler : (String) -> Msg) -> Attr[Msg] {
  Event("input", fn(e) { handler(get_target_value(e)) })
}

///|
pub fn[Msg] on_change(handler : (String) -> Msg) -> Attr[Msg] {
  Event("change", fn(e) { handler(get_target_value(e)) })
}

///|
pub fn[Msg] on_check(handler : (Bool) -> Msg) -> Attr[Msg] {
  Event("change", fn(e) { handler(get_target_checked(e)) })
}

///|
pub fn[Msg] on_keydown(handler : (String) -> Msg) -> Attr[Msg] {
  Event("keydown", fn(e) { handler(get_event_key(e)) })
}

///|
pub fn[Msg] on_submit(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event("submit", handler)
}

///|
/// A generic attribute function for any attribute name and value. 
/// For specific attributes, it's better to use the provided helper 
/// functions like `class_`, `id_`, etc.
pub fn[Msg] at(attr_name : String, value : String) -> Attr[Msg] {
  Attribute(attr_name, value)
}

///|
pub fn[Msg] class_(value : String) -> Attr[Msg] {
  Attribute("class", value)
}

///|
pub fn[Msg] id(value : String) -> Attr[Msg] {
  Attribute("id", value)
}

///|
pub fn[Msg] style(name : String, value : String) -> Attr[Msg] {
  Style(name, value)
}

///|
pub fn[Msg] value(value : String) -> Attr[Msg] {
  Property("value", value)
}

///|
pub fn[Msg] checked(value : Bool) -> Attr[Msg] {
  BoolProperty("checked", value)
}

///|
pub fn[Msg] placeholder(value : String) -> Attr[Msg] {
  Attribute("placeholder", value)
}

///|
pub fn[Msg] type_(value : String) -> Attr[Msg] {
  Attribute("type", value)
}

///|
pub fn[Msg] disabled(value : Bool) -> Attr[Msg] {
  BoolProperty("disabled", value)
}

///|
pub fn[Msg] href(value : String) -> Attr[Msg] {
  Attribute("href", value)
}

///|
pub fn[Msg] for_(value : String) -> Attr[Msg] {
  Attribute("for", value)
}
