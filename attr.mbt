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
pub fn[Msg] on_click(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("click", handler)
}

///|
fn get_target_input(event : @webapi.Event) -> @webapi.HTMLInputElement {
  event.target().into()
}

///|
fn get_target_prop(event : @webapi.Event, name : String) -> @webapi.JsValue {
  let target : @webapi.JsObject = @webapi.TJsValue::to_js(event.target()).into()
  target.get(name)
}

///|
fn get_target_value(event : @webapi.Event) -> String {
  get_target_prop(event, "value").to_string()
}

///|
fn[Msg] on_target_value(event : String, handler : (String) -> Msg) -> Attr[Msg] {
  on(event, fn(e) { handler(get_target_value(e)) })
}

///|
pub fn[Msg] on_input(handler : (String) -> Msg) -> Attr[Msg] {
  on_target_value("input", handler)
}

///|
pub fn[Msg] on_change(handler : (String) -> Msg) -> Attr[Msg] {
  on_target_value("change", handler)
}

///|
pub fn[Msg] on_check(handler : (Bool) -> Msg) -> Attr[Msg] {
  on("change", fn(e) { handler(get_target_input(e).checked()) })
}

///|
pub fn[Msg] on_keydown(handler : (String) -> Msg) -> Attr[Msg] {
  on("keydown", fn(e) {
    let ke : @webapi.KeyboardEvent = e.into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_submit(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("submit", fn(e) {
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
  let parts = classes.filter(fn(pair) { pair.1 }).map(fn(pair) { pair.0 })
  Attribute("class", parts.join(" "))
}

///|
/// A generic attribute function for any attribute name and value. 
/// For specific attributes, it's better to use the provided helper 
/// functions like `class`, `id`, etc.
pub fn[Msg] attr(attr_name : String, value : String) -> Attr[Msg] {
  Attribute(attr_name, value)
}

///|
pub fn[Msg] class(value : String) -> Attr[Msg] {
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
  Property("value", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] checked(value : Bool) -> Attr[Msg] {
  Property("checked", @webapi.TJsValue::to_js(value))
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
  Property("disabled", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] href(value : String) -> Attr[Msg] {
  Attribute("href", value)
}

///|
pub fn[Msg] for_(value : String) -> Attr[Msg] {
  Attribute("for", value)
}

// -- Links / Navigation --

///|
pub fn[Msg] src(value : String) -> Attr[Msg] {
  Attribute("src", value)
}

///|
pub fn[Msg] alt(value : String) -> Attr[Msg] {
  Attribute("alt", value)
}

///|
pub fn[Msg] title(value : String) -> Attr[Msg] {
  Attribute("title", value)
}

///|
pub fn[Msg] target(value : String) -> Attr[Msg] {
  Attribute("target", value)
}

///|
pub fn[Msg] rel(value : String) -> Attr[Msg] {
  Attribute("rel", value)
}

///|
pub fn[Msg] download(value : String) -> Attr[Msg] {
  Attribute("download", value)
}

// -- Form attributes --

///|
pub fn[Msg] name(value : String) -> Attr[Msg] {
  Attribute("name", value)
}

///|
pub fn[Msg] action(value : String) -> Attr[Msg] {
  Attribute("action", value)
}

///|
pub fn[Msg] method_(value : String) -> Attr[Msg] {
  Attribute("method", value)
}

///|
pub fn[Msg] required(value : Bool) -> Attr[Msg] {
  Property("required", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] readonly_(value : Bool) -> Attr[Msg] {
  Property("readOnly", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] autofocus(value : Bool) -> Attr[Msg] {
  Property("autofocus", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] autocomplete(value : String) -> Attr[Msg] {
  Attribute("autocomplete", value)
}

///|
pub fn[Msg] min(value : String) -> Attr[Msg] {
  Attribute("min", value)
}

///|
pub fn[Msg] max(value : String) -> Attr[Msg] {
  Attribute("max", value)
}

///|
pub fn[Msg] step(value : String) -> Attr[Msg] {
  Attribute("step", value)
}

///|
pub fn[Msg] pattern(value : String) -> Attr[Msg] {
  Attribute("pattern", value)
}

///|
pub fn[Msg] maxlength(value : Int) -> Attr[Msg] {
  Attribute("maxlength", value.to_string())
}

///|
pub fn[Msg] minlength(value : Int) -> Attr[Msg] {
  Attribute("minlength", value.to_string())
}

///|
pub fn[Msg] rows(value : Int) -> Attr[Msg] {
  Attribute("rows", value.to_string())
}

///|
pub fn[Msg] cols(value : Int) -> Attr[Msg] {
  Attribute("cols", value.to_string())
}

///|
pub fn[Msg] multiple(value : Bool) -> Attr[Msg] {
  Property("multiple", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] selected(value : Bool) -> Attr[Msg] {
  Property("selected", @webapi.TJsValue::to_js(value))
}

// -- Dimension / Layout --

///|
pub fn[Msg] width(value : String) -> Attr[Msg] {
  Attribute("width", value)
}

///|
pub fn[Msg] height(value : String) -> Attr[Msg] {
  Attribute("height", value)
}

// -- Accessibility --

///|
pub fn[Msg] role(value : String) -> Attr[Msg] {
  Attribute("role", value)
}

///|
pub fn[Msg] tabindex(value : Int) -> Attr[Msg] {
  Attribute("tabindex", value.to_string())
}

///|
pub fn[Msg] aria(name : String, value : String) -> Attr[Msg] {
  Attribute("aria-" + name, value)
}

///|
pub fn[Msg] hidden(value : Bool) -> Attr[Msg] {
  Property("hidden", @webapi.TJsValue::to_js(value))
}

// -- Data / Misc --

///|
pub fn[Msg] data(name : String, value : String) -> Attr[Msg] {
  Attribute("data-" + name, value)
}

///|
pub fn[Msg] draggable(value : String) -> Attr[Msg] {
  Attribute("draggable", value)
}

///|
pub fn[Msg] contenteditable(value : String) -> Attr[Msg] {
  Attribute("contenteditable", value)
}

///|
pub fn[Msg] spellcheck(value : String) -> Attr[Msg] {
  Attribute("spellcheck", value)
}

// -- Media --

///|
pub fn[Msg] autoplay(value : Bool) -> Attr[Msg] {
  Property("autoplay", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] controls(value : Bool) -> Attr[Msg] {
  Property("controls", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] loop_(value : Bool) -> Attr[Msg] {
  Property("loop", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] muted(value : Bool) -> Attr[Msg] {
  Property("muted", @webapi.TJsValue::to_js(value))
}

// -- Additional event handlers --

///|
pub fn[Msg] on_dblclick(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("dblclick", handler)
}

///|
pub fn[Msg] on_mousedown(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mousedown", handler)
}

///|
pub fn[Msg] on_mouseup(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mouseup", handler)
}

///|
pub fn[Msg] on_mouseover(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mouseover", handler)
}

///|
pub fn[Msg] on_mouseout(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mouseout", handler)
}

///|
pub fn[Msg] on_mouseenter(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mouseenter", handler)
}

///|
pub fn[Msg] on_mouseleave(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("mouseleave", handler)
}

///|
pub fn[Msg] on_keyup(handler : (String) -> Msg) -> Attr[Msg] {
  on("keyup", fn(e) {
    let ke : @webapi.KeyboardEvent = e.into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_keypress(handler : (String) -> Msg) -> Attr[Msg] {
  on("keypress", fn(e) {
    let ke : @webapi.KeyboardEvent = e.into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_focus(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("focus", handler)
}

///|
pub fn[Msg] on_blur(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("blur", handler)
}

///|
pub fn[Msg] on_drag(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("drag", handler)
}

///|
pub fn[Msg] on_dragstart(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("dragstart", handler)
}

///|
pub fn[Msg] on_dragend(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("dragend", handler)
}

///|
pub fn[Msg] on_dragover(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("dragover", handler)
}

///|
pub fn[Msg] on_drop(handler : (@webapi.Event) -> Msg) -> Attr[Msg] {
  on("drop", handler)
}
