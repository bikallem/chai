// Attribute and event helpers for the h package.
// These delegate to @chai base constructors (attr, property, on, style).

// -- Internal helpers (reimplemented from chai, since they're package-private) --

///|
fn get_target_input(event : @webapi.Event) -> @webapi.HTMLInputElement {
  event.target().unsafe_into()
}

///|
fn get_target_prop(event : @webapi.Event, name : String) -> @webapi.JsValue {
  let target : @webapi.JsObject = @webapi.TJsValue::to_js(event.target()).unsafe_into()
  target.get(name)
}

///|
fn get_target_value(event : @webapi.Event) -> String {
  get_target_prop(event, "value").to_string()
}

///|
fn[Msg] on_target_value(
  event : String,
  handler : (String) -> Msg,
) -> @chai.Attr[Msg] {
  @chai.on(event, fn(e) { handler(get_target_value(e)) })
}

// -- Event handlers --

///|
pub fn[Msg] on_click(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("click", handler)
}

///|
pub fn[Msg] on_input(handler : (String) -> Msg) -> @chai.Attr[Msg] {
  on_target_value("input", handler)
}

///|
pub fn[Msg] on_change(handler : (String) -> Msg) -> @chai.Attr[Msg] {
  on_target_value("change", handler)
}

///|
pub fn[Msg] on_check(handler : (Bool) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("change", fn(e) { handler(get_target_input(e).checked()) })
}

///|
pub fn[Msg] on_keydown(handler : (String) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("keydown", fn(e) {
    let ke : @webapi.KeyboardEvent = e.unsafe_into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_submit(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("submit", fn(e) {
    e.prevent_default()
    handler(e)
  })
}

///|
pub fn[Msg] on_dblclick(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("dblclick", handler)
}

///|
pub fn[Msg] on_mousedown(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mousedown", handler)
}

///|
pub fn[Msg] on_mouseup(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mouseup", handler)
}

///|
pub fn[Msg] on_mouseover(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mouseover", handler)
}

///|
pub fn[Msg] on_mouseout(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mouseout", handler)
}

///|
pub fn[Msg] on_mouseenter(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mouseenter", handler)
}

///|
pub fn[Msg] on_mouseleave(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("mouseleave", handler)
}

///|
pub fn[Msg] on_keyup(handler : (String) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("keyup", fn(e) {
    let ke : @webapi.KeyboardEvent = e.unsafe_into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_keypress(handler : (String) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("keypress", fn(e) {
    let ke : @webapi.KeyboardEvent = e.unsafe_into()
    handler(ke.key())
  })
}

///|
pub fn[Msg] on_focus(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("focus", handler)
}

///|
pub fn[Msg] on_blur(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("blur", handler)
}

///|
pub fn[Msg] on_drag(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("drag", handler)
}

///|
pub fn[Msg] on_dragstart(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("dragstart", handler)
}

///|
pub fn[Msg] on_dragend(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("dragend", handler)
}

///|
pub fn[Msg] on_dragover(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("dragover", handler)
}

///|
pub fn[Msg] on_drop(handler : (@webapi.Event) -> Msg) -> @chai.Attr[Msg] {
  @chai.on("drop", handler)
}

// -- Attribute helpers (Attribute-based) --

///|
pub fn[Msg] class(value : String) -> @chai.Attr[Msg] {
  @chai.attr("class", value)
}

///|
pub fn[Msg] class_list(classes : Array[(String, Bool)]) -> @chai.Attr[Msg] {
  let parts = classes.filter(fn(pair) { pair.1 }).map(fn(pair) { pair.0 })
  @chai.attr("class", parts.join(" "))
}

///|
pub fn[Msg] id(value : String) -> @chai.Attr[Msg] {
  @chai.attr("id", value)
}

///|
pub fn[Msg] placeholder(value : String) -> @chai.Attr[Msg] {
  @chai.attr("placeholder", value)
}

///|
pub fn[Msg] type_(value : String) -> @chai.Attr[Msg] {
  @chai.attr("type", value)
}

///|
pub fn[Msg] href(value : String) -> @chai.Attr[Msg] {
  @chai.attr("href", value)
}

///|
pub fn[Msg] for_(value : String) -> @chai.Attr[Msg] {
  @chai.attr("for", value)
}

///|
pub fn[Msg] src(value : String) -> @chai.Attr[Msg] {
  @chai.attr("src", value)
}

///|
pub fn[Msg] alt(value : String) -> @chai.Attr[Msg] {
  @chai.attr("alt", value)
}

///|
pub fn[Msg] title(value : String) -> @chai.Attr[Msg] {
  @chai.attr("title", value)
}

///|
pub fn[Msg] target(value : String) -> @chai.Attr[Msg] {
  @chai.attr("target", value)
}

///|
pub fn[Msg] rel(value : String) -> @chai.Attr[Msg] {
  @chai.attr("rel", value)
}

///|
pub fn[Msg] download(value : String) -> @chai.Attr[Msg] {
  @chai.attr("download", value)
}

///|
pub fn[Msg] name(value : String) -> @chai.Attr[Msg] {
  @chai.attr("name", value)
}

///|
pub fn[Msg] action(value : String) -> @chai.Attr[Msg] {
  @chai.attr("action", value)
}

///|
pub fn[Msg] method_(value : String) -> @chai.Attr[Msg] {
  @chai.attr("method", value)
}

///|
pub fn[Msg] autocomplete(value : String) -> @chai.Attr[Msg] {
  @chai.attr("autocomplete", value)
}

///|
pub fn[Msg] min(value : String) -> @chai.Attr[Msg] {
  @chai.attr("min", value)
}

///|
pub fn[Msg] max(value : String) -> @chai.Attr[Msg] {
  @chai.attr("max", value)
}

///|
pub fn[Msg] step(value : String) -> @chai.Attr[Msg] {
  @chai.attr("step", value)
}

///|
pub fn[Msg] pattern(value : String) -> @chai.Attr[Msg] {
  @chai.attr("pattern", value)
}

///|
pub fn[Msg] maxlength(value : Int) -> @chai.Attr[Msg] {
  @chai.attr("maxlength", value.to_string())
}

///|
pub fn[Msg] minlength(value : Int) -> @chai.Attr[Msg] {
  @chai.attr("minlength", value.to_string())
}

///|
pub fn[Msg] rows(value : Int) -> @chai.Attr[Msg] {
  @chai.attr("rows", value.to_string())
}

///|
pub fn[Msg] cols(value : Int) -> @chai.Attr[Msg] {
  @chai.attr("cols", value.to_string())
}

///|
pub fn[Msg] width(value : String) -> @chai.Attr[Msg] {
  @chai.attr("width", value)
}

///|
pub fn[Msg] height(value : String) -> @chai.Attr[Msg] {
  @chai.attr("height", value)
}

///|
pub fn[Msg] role(value : String) -> @chai.Attr[Msg] {
  @chai.attr("role", value)
}

///|
pub fn[Msg] tabindex(value : Int) -> @chai.Attr[Msg] {
  @chai.attr("tabindex", value.to_string())
}

///|
pub fn[Msg] aria(name : String, value : String) -> @chai.Attr[Msg] {
  @chai.attr("aria-" + name, value)
}

///|
pub fn[Msg] data(name : String, value : String) -> @chai.Attr[Msg] {
  @chai.attr("data-" + name, value)
}

///|
pub fn[Msg] draggable(value : String) -> @chai.Attr[Msg] {
  @chai.attr("draggable", value)
}

///|
pub fn[Msg] contenteditable(value : String) -> @chai.Attr[Msg] {
  @chai.attr("contenteditable", value)
}

///|
pub fn[Msg] spellcheck(value : String) -> @chai.Attr[Msg] {
  @chai.attr("spellcheck", value)
}

// -- Property-based attributes --

///|
pub fn[Msg] value(value : String) -> @chai.Attr[Msg] {
  @chai.property("value", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] checked(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("checked", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] disabled(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("disabled", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] required(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("required", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] readonly_(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("readOnly", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] autofocus(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("autofocus", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] multiple(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("multiple", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] selected(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("selected", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] hidden(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("hidden", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] autoplay(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("autoplay", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] controls(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("controls", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] loop_(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("loop", @webapi.TJsValue::to_js(value))
}

///|
pub fn[Msg] muted(value : Bool) -> @chai.Attr[Msg] {
  @chai.property("muted", @webapi.TJsValue::to_js(value))
}

// -- Re-exports of @chai base constructors --

///|
pub fn[Msg] on(
  event : String,
  handler : (@webapi.Event) -> Msg,
) -> @chai.Attr[Msg] {
  @chai.on(event, handler)
}

///|
pub fn[Msg] attr(name : String, value : String) -> @chai.Attr[Msg] {
  @chai.attr(name, value)
}

///|
pub fn[Msg] style(name : String, value : String) -> @chai.Attr[Msg] {
  @chai.style(name, value)
}

///|
pub fn[Msg] property(name : String, value : @webapi.JsValue) -> @chai.Attr[Msg] {
  @chai.property(name, value)
}
