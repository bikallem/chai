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
pub fn[Msg] class_(value : String) -> Attr[Msg] {
  Attribute("class", value)
}

///|
pub fn[Msg] id_(value : String) -> Attr[Msg] {
  Attribute("id", value)
}

///|
pub fn[Msg] style_(name : String, value : String) -> Attr[Msg] {
  Style(name, value)
}

///|
pub fn[Msg] value_(value : String) -> Attr[Msg] {
  Property("value", value)
}

///|
pub fn[Msg] checked_(value : Bool) -> Attr[Msg] {
  BoolProperty("checked", value)
}

///|
pub fn[Msg] placeholder_(value : String) -> Attr[Msg] {
  Attribute("placeholder", value)
}

///|
pub fn[Msg] type__(value : String) -> Attr[Msg] {
  Attribute("type", value)
}

///|
pub fn[Msg] disabled_(value : Bool) -> Attr[Msg] {
  BoolProperty("disabled", value)
}

///|
pub fn[Msg] href_(value : String) -> Attr[Msg] {
  Attribute("href", value)
}

///|
pub fn[Msg] for_(value : String) -> Attr[Msg] {
  Attribute("for", value)
}
