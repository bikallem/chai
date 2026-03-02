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
    for task in cmd.tasks {
      tasks.push(task)
    }
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
/// Send a message into a child component's update loop via its Handle.
pub fn[CMsg, Msg] Cmd::send(handle : Handle[CMsg], msg : CMsg) -> Cmd[Msg] {
  { tasks: [fn(_dispatch) { (handle.dispatch.val)(msg) }] }
}

///|
/// Dispatch a message after a delay in milliseconds.
pub fn[Msg] Cmd::after(ms : Int, msg : Msg) -> Cmd[Msg] {
  Cmd::task(fn(dispatch) {
    let handler = @webapi.Function::new(fn(_) {
      dispatch(msg)
      @webapi.JsValue::undefined()
    })
    @webapi.window.set_timeout(handler, timeout=ms, []) |> ignore
  })
}

///|
extern "js" fn js_error_message(reason : @webapi.JsValue) -> String = "(r) => r instanceof Error ? r.message : String(r)"

///|
/// Perform an HTTP GET request. Dispatches `on_result(Ok(body))` on success
/// or `on_result(Err(message))` on failure.
pub fn[Msg] Cmd::http_get(
  url : String,
  on_result : (Result[String, String]) -> Msg,
) -> Cmd[Msg] {
  Cmd::task(fn(dispatch) {
    @webapi.window
    .fetch(url)
    .then(fn(
      response : @webapi.Response,
    ) -> @webapi.JsPromise[@webapi.JsValue] {
      if response.ok() {
        response
        .text()
        .then(fn(body : String) -> @webapi.JsValue {
          dispatch(on_result(Ok(body)))
          @webapi.JsValue::undefined()
        })
      } else {
        dispatch(on_result(Err("HTTP " + response.status().to_string())))
        @webapi.JsPromise::resolve(@webapi.JsValue::undefined())
      }
    })
    .catch_(fn(reason : @webapi.JsValue) -> @webapi.JsPromise[@webapi.JsValue] {
      dispatch(on_result(Err(js_error_message(reason))))
      @webapi.JsPromise::resolve(@webapi.JsValue::undefined())
    })
    |> ignore
  })
}
