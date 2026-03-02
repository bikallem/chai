///|
priv struct SubDef[Msg] {
  key : String
  start : ((Msg) -> Unit) -> () -> Unit
}

///|
struct Sub[Msg] {
  subs : Array[SubDef[Msg]]
}

///|
pub fn[Msg] Sub::none() -> Sub[Msg] {
  { subs: [] }
}

///|
pub fn[Msg] Sub::batch(subs : Array[Sub[Msg]]) -> Sub[Msg] {
  let all : Array[SubDef[Msg]] = []
  for sub in subs {
    for s in sub.subs {
      all.push(s)
    }
  }
  { subs: all }
}

///|
pub fn[A, B] Sub::map(self : Sub[A], f : (A) -> B) -> Sub[B] {
  let new_subs : Array[SubDef[B]] = self.subs.map(fn(sd) {
    {
      key: sd.key,
      start: fn(dispatch : (B) -> Unit) { (sd.start)(fn(a) { dispatch(f(a)) }) },
    }
  })
  { subs: new_subs }
}

///|
pub fn[Msg] Sub::sub(
  key : String,
  start : ((Msg) -> Unit) -> () -> Unit,
) -> Sub[Msg] {
  { subs: [{ key, start }] }
}

///|
/// Subscribe to a recurring timer. Fires `to_msg()` every `ms` milliseconds.
pub fn[Msg] Sub::every(ms : Int, key : String, to_msg : () -> Msg) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler = @webapi.Function::new(fn(_) {
      dispatch(to_msg())
      @webapi.JsValue::undefined()
    })
    let id = @webapi.window.set_interval(handler, timeout=ms, [])
    fn() { @webapi.window.clear_interval(id~) }
  })
}

///|
extern "js" fn add_event_listener_ffi(
  target : @webapi.JsValue,
  event : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit = "(t, e, h) => t.addEventListener(e, h)"

///|
extern "js" fn remove_event_listener_ffi(
  target : @webapi.JsValue,
  event : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit = "(t, e, h) => t.removeEventListener(e, h)"

///|
/// Subscribe to `keydown` events on the document.
/// Set `prevent_default` to stop the browser from also activating focused
/// buttons or scrolling when shortcut keys are pressed.
pub fn[Msg] Sub::on_key_down(
  key : String,
  to_msg : (String) -> Msg,
  prevent_default? : Bool = false,
) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler : (@webapi.Event) -> Unit = fn(e) {
      if prevent_default {
        e.prevent_default()
      }
      let ke : @webapi.KeyboardEvent = @webapi.TJsValue::to_js(e).into()
      dispatch(to_msg(ke.key()))
    }
    let doc = @webapi.TJsValue::to_js(@webapi.document)
    add_event_listener_ffi(doc, "keydown", handler)
    fn() { remove_event_listener_ffi(doc, "keydown", handler) }
  })
}

///|
/// Subscribe to `resize` events on the window.
pub fn[Msg] Sub::on_window_resize(
  key : String,
  to_msg : (Int, Int) -> Msg,
) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler : (@webapi.Event) -> Unit = fn(_e) {
      dispatch(
        to_msg(@webapi.window.inner_width(), @webapi.window.inner_height()),
      )
    }
    let win = @webapi.TJsValue::to_js(@webapi.window)
    add_event_listener_ffi(win, "resize", handler)
    fn() { remove_event_listener_ffi(win, "resize", handler) }
  })
}
