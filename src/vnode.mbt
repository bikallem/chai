///|
enum VNode[Msg] {
  Text(String)
  Element(String, Array[Attr[Msg]], Array[VNode[Msg]])
  Embed(ComponentNode)
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
    Embed(comp) => Embed(comp)
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
      let new_attrs = attrs.map(fn(a) {
        match a {
          Attribute(k, v) => Attribute(k, v)
          Event(name, handler) =>
            BoundEvent(name, fn(e) { dispatch(handler(e)) })
          BoundEvent(name, handler) => BoundEvent(name, handler)
          Style(k, v) => Style(k, v)
        }
      })
      let new_children = children.map(fn(c) { bind_events(c, dispatch) })
      Element(tag, new_attrs, new_children)
    }
    Embed(comp) => Embed(comp)
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

///|
pub fn[Msg] div(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("div", attrs, children)
}

///|
pub fn[Msg] span(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("span", attrs, children)
}

///|
pub fn[Msg] button(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("button", attrs, children)
}

///|
pub fn[Msg] input_(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("input", attrs, [])
}

///|
pub fn[Msg] h1(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h1", attrs, children)
}

///|
pub fn[Msg] h2(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h2", attrs, children)
}

///|
pub fn[Msg] h3(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h3", attrs, children)
}

///|
pub fn[Msg] p(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("p", attrs, children)
}

///|
pub fn[Msg] ul(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("ul", attrs, children)
}

///|
pub fn[Msg] li(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("li", attrs, children)
}

///|
pub fn[Msg] label(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("label", attrs, children)
}

///|
pub fn[Msg] section(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("section", attrs, children)
}

///|
pub fn[Msg] header(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("header", attrs, children)
}

///|
pub fn[Msg] footer(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("footer", attrs, children)
}

///|
pub fn[Msg] a(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("a", attrs, children)
}

///|
pub fn[Msg] form(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("form", attrs, children)
}
