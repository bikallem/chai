///|
#cfg(target="js")
fn make_click_event(
  button : Int,
  meta : Bool,
  ctrl : Bool,
  shift : Bool,
  alt : Bool,
  default_prevented : Bool,
  target : String,
) -> @webapi.Event {
  let obj = @webapi.JsObject::new()
  obj.set("button", @webapi.TJsValue::to_js(button)) |> ignore
  obj.set("metaKey", @webapi.TJsValue::to_js(meta)) |> ignore
  obj.set("ctrlKey", @webapi.TJsValue::to_js(ctrl)) |> ignore
  obj.set("shiftKey", @webapi.TJsValue::to_js(shift)) |> ignore
  obj.set("altKey", @webapi.TJsValue::to_js(alt)) |> ignore
  obj.set("defaultPrevented", @webapi.TJsValue::to_js(default_prevented))
  |> ignore
  let ct = @webapi.JsObject::new()
  ct.set("target", @webapi.TJsValue::to_js(target)) |> ignore
  obj.set("currentTarget", @webapi.TJsValue::to_js(ct)) |> ignore
  let t = @webapi.JsObject::new()
  t.set("value", @webapi.TJsValue::to_js("")) |> ignore
  t.set("checked", @webapi.TJsValue::to_js(false)) |> ignore
  obj.set("target", @webapi.TJsValue::to_js(t)) |> ignore
  let prevent = @webapi.VoidFunction::new(fn() {
    obj.set("defaultPrevented", @webapi.TJsValue::to_js(true)) |> ignore
  })
  obj.set("preventDefault", @webapi.TJsValue::to_js(prevent)) |> ignore
  @webapi.TJsValue::to_js(obj).unsafe_into()
}

///|
#cfg(target="js")
fn make_input_event(value : String, checked : Bool) -> @webapi.Event {
  let obj = @webapi.JsObject::new()
  let t = @webapi.JsObject::new()
  t.set("value", @webapi.TJsValue::to_js(value)) |> ignore
  t.set("checked", @webapi.TJsValue::to_js(checked)) |> ignore
  obj.set("target", @webapi.TJsValue::to_js(t)) |> ignore
  @webapi.TJsValue::to_js(obj).unsafe_into()
}

///|
#cfg(target="js")
fn make_key_event(key : String) -> @webapi.Event {
  let obj = @webapi.JsObject::new()
  obj.set("key", @webapi.TJsValue::to_js(key)) |> ignore
  @webapi.TJsValue::to_js(obj).unsafe_into()
}
