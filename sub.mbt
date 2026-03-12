///|
priv struct SubDef[Msg] {
  key : String
  identity : String
  behavior : @webapi.JsValue
  start : ((Msg) -> Unit, @webapi.JsValue) -> ActiveSub
}

///|
struct Sub[Msg] {
  subs : Array[SubDef[Msg]]
}

///|
priv struct KeyDownBehavior[Msg] {
  to_msg : (String) -> Msg
  prevent_default : ((String) -> Bool)?
}

///|
let sub_identity_counter : Ref[Int] = Ref::new(0)

///|
fn[A] erase_sub_behavior(value : A) -> @webapi.JsValue = "%identity"

///|
fn[A] unerase_sub_behavior(value : @webapi.JsValue) -> A = "%identity"

///|
fn fresh_sub_identity(prefix : String) -> String {
  let next_id = sub_identity_counter.val
  sub_identity_counter.val = next_id + 1
  prefix + ":" + next_id.to_string()
}

///|
fn[Behavior, Msg] refreshable_sub(
  key : String,
  identity : String,
  behavior : Behavior,
  start : ((Msg) -> Unit, Ref[Behavior]) -> () -> Unit,
) -> Sub[Msg] {
  {
    subs: [{
      key,
      identity,
      behavior: erase_sub_behavior(behavior),
      start: fn(dispatch, behavior_js) {
        let behavior_ref : Ref[Behavior] = Ref::new(unerase_sub_behavior(behavior_js))
        let cleanup = start(dispatch, behavior_ref)
        { identity, cleanup, refresh: fn(next_behavior_js) {
          behavior_ref.val = unerase_sub_behavior(next_behavior_js)
        } }
      },
    }],
  }
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
      identity: sd.identity,
      behavior: sd.behavior,
      start: fn(dispatch : (B) -> Unit, behavior_js : @webapi.JsValue) {
        (sd.start)(fn(a) { dispatch(f(a)) }, behavior_js)
      },
    }
  })
  { subs: new_subs }
}

///|
pub fn[Msg] Sub::sub(
  key : String,
  start : ((Msg) -> Unit) -> () -> Unit,
) -> Sub[Msg] {
  let identity = fresh_sub_identity("custom")
  {
    subs: [{
      key,
      identity,
      behavior: @webapi.JsValue::undefined(),
      start: fn(dispatch, _behavior_js) {
        let cleanup = start(dispatch)
        { identity, cleanup, refresh: fn(_) {  } }
      },
    }],
  }
}

///|
/// Subscribe to a recurring timer. Fires `to_msg()` every `ms` milliseconds.
pub fn[Msg] Sub::every(ms : Int, key : String, to_msg : () -> Msg) -> Sub[Msg] {
  refreshable_sub(
    key,
    "every:" + ms.to_string(),
    to_msg,
    fn(dispatch, behavior_ref) {
      let id = @webapi.window.set_interval(
        js_callback(fn() { dispatch((behavior_ref.val)()) }),
        timeout=ms,
        [],
      )
      fn() { @webapi.window.clear_interval(id~) }
    },
  )
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
  refreshable_sub(
    key,
    "document:keydown",
    { to_msg, prevent_default },
    fn(dispatch, behavior_ref) {
      let handler : (@webapi.Event) -> Unit = fn(e) {
        let ke : @webapi.KeyboardEvent = e.into()
        let pressed = ke.key()
        let behavior = behavior_ref.val
        match behavior.prevent_default {
          Some(pred) => if pred(pressed) { e.prevent_default() }
          None => ()
        }
        dispatch((behavior.to_msg)(pressed))
      }
      @webapi.document.add_event_listener("keydown", handler)
      fn() { @webapi.document.remove_event_listener("keydown", handler) }
    },
  )
}

///|
/// Subscribe to `resize` events on the window.
pub fn[Msg] Sub::on_window_resize(
  key : String,
  to_msg : (Int, Int) -> Msg,
) -> Sub[Msg] {
  refreshable_sub(
    key,
    "window:resize",
    to_msg,
    fn(dispatch, behavior_ref) {
      let handler : (@webapi.Event) -> Unit = fn(_e) {
        dispatch(
          (behavior_ref.val)(
            @webapi.window.inner_width(),
            @webapi.window.inner_height(),
          ),
        )
      }
      @webapi.window.add_event_listener("resize", handler)
      fn() { @webapi.window.remove_event_listener("resize", handler) }
    },
  )
}
