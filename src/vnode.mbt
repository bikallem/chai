///|
pub(all) enum VNode[Msg] {
  Text(String)
  Element(String, Array[Attr[Msg]], Array[VNode[Msg]])
  Embed(Component)
}

///|
pub(all) enum Attr[Msg] {
  Attribute(String, String)
  Property(String, String)
  BoolProperty(String, Bool)
  Event(String, (@webapi.Event) -> Msg)
  Style(String, String)
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
pub fn[A, B] Attr::map(self : Attr[A], f : (A) -> B) -> Attr[B] {
  match self {
    Attribute(k, v) => Attribute(k, v)
    Property(k, v) => Property(k, v)
    BoolProperty(k, v) => BoolProperty(k, v)
    Event(name, handler) => Event(name, fn(e) { f(handler(e)) })
    Style(k, v) => Style(k, v)
  }
}

///|
pub fn[Msg] text(s : String) -> VNode[Msg] {
  Text(s)
}

///|
pub fn[Msg] node(
  tag : String,
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element(tag, attrs, children)
}
