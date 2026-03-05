///|
extern "js" fn make_click_event(
  button : Int,
  meta : Bool,
  ctrl : Bool,
  shift : Bool,
  alt : Bool,
  default_prevented : Bool,
  target : String,
) -> @webapi.Event = "(button, meta, ctrl, shift, alt, default_prevented, target) => ({ button, metaKey: meta, ctrlKey: ctrl, shiftKey: shift, altKey: alt, defaultPrevented: default_prevented, currentTarget: { target }, target: { value: '', checked: false }, preventDefault() { this.defaultPrevented = true } })"

///|
extern "js" fn make_input_event(
  value : String,
  checked : Bool,
) -> @webapi.Event = "(value, checked) => ({ target: { value, checked } })"

///|
extern "js" fn make_key_event(key : String) -> @webapi.Event = "(key) => ({ key })"
