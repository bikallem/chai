///|
/// Set a string property on a DOM element (e.g., el.value = "text")
extern "js" fn set_property_ffi(
  el : @webapi.JsValue,
  name : String,
  value : String,
) -> Unit = "(el, name, value) => { el[name] = value; }"

///|
/// Set a boolean property on a DOM element (e.g., el.checked = true)
extern "js" fn set_bool_property_ffi(
  el : @webapi.JsValue,
  name : String,
  value : Bool,
) -> Unit = "(el, name, value) => { el[name] = value; }"

///|
/// Set an inline style property on a DOM element
extern "js" fn set_style_ffi(
  el : @webapi.JsValue,
  name : String,
  value : String,
) -> Unit = "(el, name, value) => { el.style[name] = value; }"

///|
/// Remove an inline style property from a DOM element
extern "js" fn remove_style_ffi(el : @webapi.JsValue, name : String) -> Unit = "(el, name) => { el.style[name] = ''; }"

///|
/// Set a DOM Level 0 event handler (e.g., el.onclick = fn)
extern "js" fn set_event_handler_ffi(
  el : @webapi.JsValue,
  name : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit = "(el, name, handler) => { el['on' + name] = handler; }"

///|
/// Remove a DOM Level 0 event handler (e.g., el.onclick = null)
extern "js" fn remove_event_handler_ffi(
  el : @webapi.JsValue,
  name : String,
) -> Unit = "(el, name) => { el['on' + name] = null; }"

///|
/// Get event.target.value
extern "js" fn get_target_value_ffi(event : @webapi.JsValue) -> String = "(event) => event.target.value"

///|
/// Get event.target.checked
extern "js" fn get_target_checked_ffi(event : @webapi.JsValue) -> Bool = "(event) => event.target.checked"

///|
/// Get event.key (for keyboard events)
extern "js" fn get_event_key_ffi(event : @webapi.JsValue) -> String = "(event) => event.key"

// Event helpers: get_target_value/checked/key use FFI because webapi has no
// EventTarget -> HTMLInputElement or Event -> KeyboardEvent cast path.

///|
/// Get the value from an input event's target
pub fn get_target_value(event : @webapi.Event) -> String {
  get_target_value_ffi(@webapi.TJsValue::to_js(event))
}

///|
/// Get the checked state from a checkbox event's target
pub fn get_target_checked(event : @webapi.Event) -> Bool {
  get_target_checked_ffi(@webapi.TJsValue::to_js(event))
}

///|
/// Get the key from a keyboard event
pub fn get_event_key(event : @webapi.Event) -> String {
  get_event_key_ffi(@webapi.TJsValue::to_js(event))
}

///|
/// Prevent the default behavior of an event
pub fn prevent_default(event : @webapi.Event) -> Unit {
  event.prevent_default()
}
