///|
pub fn[Msg] text(s : String) -> @chai.VNode[Msg] {
  @chai.text(s)
}

///|
pub fn[Msg] el(
  tag : String,
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el(tag, attrs, children)
}

///|
pub fn[Msg] keyed(key : String, child : @chai.VNode[Msg]) -> @chai.VNode[Msg] {
  @chai.keyed(key, child)
}

///|
pub fn[Msg] keyed_list(
  items : Array[(String, @chai.VNode[Msg])],
) -> Array[@chai.VNode[Msg]] {
  @chai.keyed_list(items)
}
