///|
enum Attr[Msg] {
  Attribute(String, String)
  Event(String, (@webapi.Event) -> Msg)
  BoundEvent(String, (@webapi.Event) -> Unit)
  Style(String, String)
}

///|
pub fn[A, B] Attr::map(self : Attr[A], f : (A) -> B) -> Attr[B] {
  match self {
    Attribute(k, v) => Attribute(k, v)
    Event(name, handler) => Event(name, fn(e) { f(handler(e)) })
    BoundEvent(name, handler) => BoundEvent(name, handler)
    Style(k, v) => Style(k, v)
  }
}

///|
pub fn[Msg] on_click(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event("click", handler)
}

///|
/// Get the value from an input event's target
fn get_target_value(event : @webapi.Event) -> String {
  let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(event.target()).into()
  input.value()
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
  Event("change", fn(e) {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(e.target()).into()
    handler(input.checked())
  })
}

///|
pub fn[Msg] on_keydown(handler : (String) -> Msg) -> Attr[Msg] {
  Event("keydown", fn(e) {
    let ke : @webapi.KeyboardEvent = @webapi.TJsValue::to_js(e).into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_submit(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event("submit", fn(e) {
    e.prevent_default()
    handler(e)
  })
}

///|
/// Generic event handler for any event name not covered by helpers.
pub fn[Msg] on(name : String, handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  Event(name, handler)
}

///|
/// Build a class string from conditional class names.
pub fn[Msg] class_list(classes : Array[(String, Bool)]) -> Attr[Msg] {
  let parts : Array[String] = []
  for pair in classes {
    if pair.1 {
      parts.push(pair.0)
    }
  }
  Attribute("class", parts.join(" "))
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
  Attribute("value", value)
}

///|
pub fn[Msg] checked(value : Bool) -> Attr[Msg] {
  Attribute("checked", if value { "true" } else { "false" })
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
  Attribute("disabled", if value { "true" } else { "false" })
}

///|
pub fn[Msg] href(value : String) -> Attr[Msg] {
  Attribute("href", value)
}

///|
pub fn[Msg] for_(value : String) -> Attr[Msg] {
  Attribute("for", value)
}
