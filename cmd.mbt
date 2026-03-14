///|
struct Cmd[Msg] {
  tasks : Array[((Msg) -> Unit) -> Unit]
}

///|
pub fn[Msg] Cmd::none() -> Cmd[Msg] {
  { tasks: [] }
}

///|
pub fn[Msg] Cmd::batch(cmds : Array[Cmd[Msg]]) -> Cmd[Msg] {
  let tasks : Array[((Msg) -> Unit) -> Unit] = []
  for cmd in cmds {
    tasks.append(cmd.tasks)
  }
  { tasks, }
}

///|
pub fn[A, B] Cmd::map(self : Cmd[A], f : (A) -> B) -> Cmd[B] {
  let new_tasks : Array[((B) -> Unit) -> Unit] = self.tasks.map(fn(task) {
    fn(dispatch : (B) -> Unit) { task(fn(a) { dispatch(f(a)) }) }
  })
  { tasks: new_tasks }
}

///|
pub fn[Msg] Cmd::task(task : ((Msg) -> Unit) -> Unit) -> Cmd[Msg] {
  { tasks: [task] }
}

///|
fn[Msg] Cmd::run(self : Cmd[Msg], dispatch : (Msg) -> Unit) -> Unit {
  for task in self.tasks {
    task(dispatch)
  }
}

///|
/// Send a message into a child component's update loop via its Handle.
pub fn[CMsg, Msg] Cmd::send(handle : Handle[CMsg], msg : CMsg) -> Cmd[Msg] {
  { tasks: [fn(_dispatch) { (handle.dispatch.val)(msg) }] }
}

///|
fn js_callback(f : () -> Unit) -> @webapi.Function {
  @webapi.Function::new(fn(_) {
    f()
    @webapi.JsValue::undefined()
  })
}

///|
/// Dispatch a message after a delay in milliseconds.
pub fn[Msg] Cmd::after(ms : Int, msg : Msg) -> Cmd[Msg] {
  Cmd::task(fn(dispatch) {
    @webapi.window().set_timeout(
      js_callback(fn() { dispatch(msg) }),
      timeout=ms,
      [],
    )
    |> ignore
  })
}

///|
fn error_message(reason : @webapi.JsValue) -> String {
  if not(reason.is_null()) {
    let obj : @webapi.JsObject = reason.unsafe_into()
    let msg = obj.get("message")
    if not(msg.is_null()) {
      return msg.to_string()
    }
  }
  reason.to_string()
}

///|
/// Perform an HTTP GET request. Dispatches `on_result(Ok(body))` on success
/// or `on_result(Err(message))` on failure.
pub fn[Msg] Cmd::http_get(
  url : String,
  on_result : (Result[String, String]) -> Msg,
) -> Cmd[Msg] {
  Cmd::task(fn(dispatch) {
    @webapi.window()
    .fetch(url)
    .then(fn(response : @webapi.Response) {
      if response.ok() {
        response
        .text()
        .then(fn(body : String) { dispatch(on_result(Ok(body))) })
        .catch_(fn(reason : @webapi.JsValue) {
          dispatch(on_result(Err(error_message(reason))))
        })
        |> ignore
      } else {
        dispatch(on_result(Err("HTTP " + response.status().to_string())))
      }
    })
    .catch_(fn(reason : @webapi.JsValue) {
      dispatch(on_result(Err(error_message(reason))))
    })
    |> ignore
  })
}
