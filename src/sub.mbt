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
    let id = @webapi.window.set_interval(
      js_callback(fn() { dispatch(to_msg()) }),
      timeout=ms,
      [],
    )
    fn() { @webapi.window.clear_interval(id~) }
  })
}

///|
/// Subscribe to `keydown` events on the document.
/// When `prevent_default` is given, only keys matching the predicate will
/// have their default browser action suppressed (e.g., scrolling, button
/// activation). Without it, no defaults are prevented.
pub fn[Msg] Sub::on_key_down(
  key : String,
  to_msg : (String) -> Msg,
  prevent_default? : (String) -> Bool,
) -> Sub[Msg] {
  Sub::sub(key, fn(dispatch) {
    let handler : (@webapi.Event) -> Unit = fn(e) {
      let ke : @webapi.KeyboardEvent = e.into()
      let pressed = ke.key()
      match prevent_default {
        Some(pred) => if pred(pressed) { e.prevent_default() }
        None => ()
      }
      dispatch(to_msg(pressed))
    }
    @webapi.document.add_event_listener("keydown", handler)
    fn() { @webapi.document.remove_event_listener("keydown", handler) }
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
    @webapi.window.add_event_listener("resize", handler)
    fn() { @webapi.window.remove_event_listener("resize", handler) }
  })
}
