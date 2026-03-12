///|
priv enum AttrSlotKind {
  AttributeSlot
  PropertySlot
  EventSlot
  StyleSlot
} derive(Eq)

///|
fn[Msg] bind_attr(attr : Attr[Msg], dispatch : (Msg) -> Unit) -> Attr[Unit] {
  match attr {
    Attribute(k, v) => Attribute(k, v)
    Property(k, v) => Property(k, v)
    Event(name, handler) => BoundEvent(name, fn(e) { dispatch(handler(e)) })
    EventMaybe(name, handler) =>
      BoundEvent(name, fn(e) {
        match handler(e) {
          Some(msg) => dispatch(msg)
          None => ()
        }
      })
    BoundEvent(name, handler) => BoundEvent(name, handler)
    Style(k, v) => Style(k, v)
  }
}

///|
fn[Msg] attr_slot_kind(attr : Attr[Msg]) -> AttrSlotKind {
  match attr {
    Attribute(_, _) => AttributeSlot
    Property(_, _) => PropertySlot
    Event(_, _) => EventSlot
    EventMaybe(_, _) => EventSlot
    BoundEvent(_, _) => EventSlot
    Style(_, _) => StyleSlot
  }
}

///|
fn[Msg] attr_name(attr : Attr[Msg]) -> String {
  match attr {
    Attribute(name, _) => name
    Property(name, _) => name
    Event(name, _) => name
    EventMaybe(name, _) => name
    BoundEvent(name, _) => name
    Style(name, _) => name
  }
}

///|
fn[Msg] same_attr_slot(old : Attr[Msg], new_ : Attr[Msg]) -> Bool {
  attr_slot_kind(old) == attr_slot_kind(new_) && attr_name(old) == attr_name(new_)
}

///|
fn[Msg] attr_needs_update(old : Attr[Msg], new_ : Attr[Msg]) -> Bool {
  match (old, new_) {
    (Attribute(_, old_value), Attribute(_, new_value)) => old_value != new_value
    (Style(_, old_value), Style(_, new_value)) => old_value != new_value
    _ => true
  }
}

///|
fn[Msg] attr_text_value(attr : Attr[Msg]) -> String {
  match attr {
    Attribute(_, value) => value
    Style(_, value) => value
    _ => abort("chai: attr_text_value expected Attribute or Style")
  }
}

///|
/// Cast a closure to JsValue (on the JS target, closures are JS functions).
fn handler_to_js(handler : (@webapi.Event) -> Unit) -> @webapi.JsValue = "%identity"

///|
/// Set a DOM Level 0 event handler (e.g., el.onclick = fn)
fn set_event_handler(
  el : @webapi.Element,
  name : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit {
  set_prop(el, "on" + name, handler_to_js(handler))
}

///|
/// Remove a DOM Level 0 event handler (e.g., el.onclick = null)
fn remove_event_handler(el : @webapi.Element, name : String) -> Unit {
  set_prop(el, "on" + name, @webapi.JsValue::null())
}

///|
fn set_prop(el : @webapi.Element, name : String, val : @webapi.JsValue) -> Unit {
  let obj : @webapi.JsObject = @webapi.TJsValue::to_js(el).into()
  obj.set(name, val) |> ignore
}

///|
fn set_style_prop(el : @webapi.Element, name : String, value : String) -> Unit {
  let html_el : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).into()
  html_el.style().set_property(name, value)
}

///|
fn apply_bound_attr(el : @webapi.Element, attr : Attr[Unit]) -> Unit {
  match attr {
    Attribute(name, value) => el.set_attribute(name, value)
    Property(name, value) => set_prop(el, name, value)
    BoundEvent(name, handler) => set_event_handler(el, name, handler)
    Style(name, value) => set_style_prop(el, name, value)
    Event(_, _) =>
      abort("chai: apply_bound_attr expected a bound event handler")
    EventMaybe(_, _) =>
      abort("chai: apply_bound_attr expected a bound event handler")
  }
}

///|
fn[Msg] apply_attr(
  el : @webapi.Element,
  attr : Attr[Msg],
  dispatch : (Msg) -> Unit,
) -> Unit {
  apply_bound_attr(el, bind_attr(attr, dispatch))
}
