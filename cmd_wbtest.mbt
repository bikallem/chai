///|
test "Cmd::none has no tasks" {
  let none : Cmd[Unit] = Cmd::none()
  assert_eq(none.tasks.length(), 0)
}

///|
test "Cmd::batch runs child tasks in order" {
  let seen : Array[Int] = []
  let cmd = Cmd::batch([
    Cmd::task(fn(dispatch) { dispatch(1) }),
    Cmd::task(fn(dispatch) { dispatch(2) }),
  ])
  cmd.run(fn(msg) { seen.push(msg) })
  assert_eq(seen.length(), 2)
  assert_eq(seen[0], 1)
  assert_eq(seen[1], 2)
}

///|
test "Cmd::map transforms dispatched messages" {
  let seen : Array[String] = []
  let mapped = Cmd::task(fn(dispatch) { dispatch(7) }).map(fn(x) {
    "mapped-" + x.to_string()
  })
  mapped.run(fn(msg) { seen.push(msg) })
  assert_eq(seen.length(), 1)
  assert_eq(seen[0], "mapped-7")
}

///|
test "Cmd::send uses handle dispatch" {
  let handle = Handle::new()
  let seen : Array[Int] = []
  handle.dispatch.val = fn(msg) { seen.push(msg) }
  let send_cmd : Cmd[Unit] = Cmd::send(handle, 42)
  send_cmd.run(fn(_msg) {  })
  assert_eq(seen.length(), 1)
  assert_eq(seen[0], 42)
}

///|
test "error_message handles nullish reasons" {
  assert_eq(error_message(@webapi.JsValue::null()), "null")
  assert_eq(error_message(@webapi.JsValue::undefined()), "undefined")
}

///|
test "error_message reads message field when present" {
  let obj = @webapi.JsObject::new()
  obj.set("message", @webapi.TJsValue::to_js("boom")) |> ignore
  assert_eq(error_message(@webapi.TJsValue::to_js(obj)), "boom")
}

///|
test "error_message falls back to reason string when message missing" {
  let obj = @webapi.JsObject::new()
  assert_eq(error_message(@webapi.TJsValue::to_js(obj)), "[object Object]")
}
