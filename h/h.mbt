///|
/// A VNode that renders nothing. Useful for conditional rendering where a branch
/// should produce no output, e.g. `if show { div([], [text("hi")]) } else { null() }`.
/// Also handy for optional list items: `items.map(fn(i) { if i.visible { li([], [text(i.name)]) } else { null() } })`.
pub fn[Msg] null() -> @chai.VNode[Msg] {
  @chai.null()
}

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
