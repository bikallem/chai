///|
enum VNode[Msg] {
  Text(String)
  Element(String, Array[Attr[Msg]], Array[VNode[Msg]])
  Component(ComponentNode)
  Keyed(String, VNode[Msg])
  Lazy(Int, () -> VNode[Msg])
  Fragment(Array[VNode[Msg]])
  Null
}

///|
pub fn[A, B] VNode::map(self : VNode[A], f : (A) -> B) -> VNode[B] {
  match self {
    Text(s) => Text(s)
    Element(tag, attrs, children) => {
      let new_attrs = attrs.map(fn(a) { a.map(f) })
      let new_children = children.map(fn(c) { c.map(f) })
      Element(tag, new_attrs, new_children)
    }
    Component(comp) => Component(comp)
    Keyed(k, child) => Keyed(k, child.map(f))
    Lazy(hash, thunk) => Lazy(hash, fn() { thunk().map(f) })
    Fragment(children) => Fragment(children.map(fn(c) { c.map(f) }))
    Null => Null
  }
}

///|
/// A VNode that renders nothing. Useful for conditional rendering where a branch
/// should produce no output, e.g. `if show { div([], [text("hi")]) } else { null() }`.
pub fn[Msg] null() -> VNode[Msg] {
  Null
}

///|
pub fn[S : Show, Msg] text(s : S) -> VNode[Msg] {
  Text(s.to_string())
}

///|
/// Convert a typed VNode tree to VNode[Unit] by binding all Event handlers
/// through a dispatch function, turning them into BoundEvent closures.
fn[CMsg] bind_events(
  vnode : VNode[CMsg],
  dispatch : (CMsg) -> Unit,
) -> VNode[Unit] {
  match vnode {
    Text(s) => Text(s)
    Element(tag, attrs, children) => {
      let new_attrs = attrs.map(fn(a) { bind_attr(a, dispatch) })
      let new_children = children.map(fn(c) { bind_events(c, dispatch) })
      Element(tag, new_attrs, new_children)
    }
    Component(comp) => Component(comp)
    Keyed(k, child) => Keyed(k, bind_events(child, dispatch))
    Lazy(hash, thunk) => Lazy(hash, fn() { bind_events(thunk(), dispatch) })
    Fragment(children) =>
      Fragment(children.map(fn(c) { bind_events(c, dispatch) }))
    Null => Null
  }
}

///|
pub fn[Msg] keyed(key : String, child : VNode[Msg]) -> VNode[Msg] {
  Keyed(key, child)
}

///|
/// Wrap an array of (key, vnode) pairs into Keyed vnodes for use as
/// children of any container element: `ul([], keyed_list(items))`
pub fn[Msg] keyed_list(
  items : Array[(String, VNode[Msg])],
) -> Array[VNode[Msg]] {
  items.map(fn(pair) {
    let (k, v) = pair
    Keyed(k, v)
  })
}

///|
/// Skip diffing when `hash` matches the previous render. The `thunk` is only
/// called when the hash changes.
pub fn[Msg] lazy_(hash : Int, thunk : () -> VNode[Msg]) -> VNode[Msg] {
  Lazy(hash, thunk)
}

///|
#cfg(target="js")
extern "js" fn try_render(
  on_ok : () -> Unit,
  on_err : (String) -> Unit,
) -> Unit = "(ok, err) => { try { ok(); } catch(e) { err(String(e)); } }"

///|
#cfg(target="wasm-gc")
fn try_render(on_ok : () -> Unit, _on_err : (String) -> Unit) -> Unit {
  on_ok()
}

///|
/// Wrap a view thunk in an error boundary. If `child` panics, `fallback`
/// receives the error message and renders a replacement VNode.
/// On wasm-gc, only `raise` errors are recoverable; `abort` traps the module.
pub fn[Msg] error_boundary(
  fallback~ : (String) -> VNode[Msg],
  child~ : () -> VNode[Msg],
) -> VNode[Msg] {
  let result : Ref[VNode[Msg]] = Ref::new(Null)
  try_render(fn() { result.val = child() }, fn(msg) {
    result.val = fallback(msg)
  })
  result.val
}

///|
/// Group multiple VNodes without a wrapper element.
pub fn[Msg] fragment(children : Array[VNode[Msg]]) -> VNode[Msg] {
  Fragment(children)
}

///|
/// Flatten Fragment vnodes into a flat array. Non-fragment nodes pass through.
fn[Msg] flatten_children(children : Array[VNode[Msg]]) -> Array[VNode[Msg]] {
  let mut has_fragment = false
  for child in children {
    if child is Fragment(_) {
      has_fragment = true
      break
    }
  }
  if not(has_fragment) {
    return children
  }
  let result : Array[VNode[Msg]] = []
  for child in children {
    match child {
      Fragment(inner) => flatten_into(inner, result)
      _ => result.push(child)
    }
  }
  result
}

///|
fn[Msg] flatten_into(
  children : Array[VNode[Msg]],
  result : Array[VNode[Msg]],
) -> Unit {
  for child in children {
    match child {
      Fragment(inner) => flatten_into(inner, result)
      _ => result.push(child)
    }
  }
}

///|
pub fn[Msg] el(
  tag : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element(tag, attrs, children)
}
