///|
enum VNode[Msg] {
  Text(String)
  Element(String, Array[Attr[Msg]], Array[VNode[Msg]])
  Component(ComponentNode)
  Keyed(String, VNode[Msg])
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
  }
}

///|
pub fn[Msg] text(s : String) -> VNode[Msg] {
  Text(s)
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
  items.map(fn(pair) { Keyed(pair.0, pair.1) })
}

///|
pub fn[Msg] el(
  tag : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element(tag, attrs, children)
}
