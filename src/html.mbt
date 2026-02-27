///|
pub fn[Msg] h(
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
  h("div", attrs, children)
}

///|
pub fn[Msg] span(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("span", attrs, children)
}

///|
pub fn[Msg] button(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("button", attrs, children)
}

///|
pub fn[Msg] input_(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  h("input", attrs, [])
}

///|
pub fn[Msg] h1(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("h1", attrs, children)
}

///|
pub fn[Msg] h2(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("h2", attrs, children)
}

///|
pub fn[Msg] h3(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("h3", attrs, children)
}

///|
pub fn[Msg] p(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("p", attrs, children)
}

///|
pub fn[Msg] ul(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("ul", attrs, children)
}

///|
pub fn[Msg] li(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("li", attrs, children)
}

///|
pub fn[Msg] label(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("label", attrs, children)
}

///|
pub fn[Msg] section(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("section", attrs, children)
}

///|
pub fn[Msg] header(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("header", attrs, children)
}

///|
pub fn[Msg] footer(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("footer", attrs, children)
}

///|
pub fn[Msg] a(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("a", attrs, children)
}

///|
pub fn[Msg] form(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  h("form", attrs, children)
}
