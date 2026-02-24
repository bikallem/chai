///|
pub fn[Msg] div(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("div", attrs, children)
}

///|
pub fn[Msg] span(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("span", attrs, children)
}

///|
pub fn[Msg] button(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("button", attrs, children)
}

///|
pub fn[Msg] input_(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  Element("input", attrs, [])
}

///|
pub fn[Msg] h1(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("h1", attrs, children)
}

///|
pub fn[Msg] h2(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("h2", attrs, children)
}

///|
pub fn[Msg] h3(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("h3", attrs, children)
}

///|
pub fn[Msg] p(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("p", attrs, children)
}

///|
pub fn[Msg] ul(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("ul", attrs, children)
}

///|
pub fn[Msg] li(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("li", attrs, children)
}

///|
pub fn[Msg] label(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("label", attrs, children)
}

///|
pub fn[Msg] section(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("section", attrs, children)
}

///|
pub fn[Msg] header(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("header", attrs, children)
}

///|
pub fn[Msg] footer(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("footer", attrs, children)
}

///|
pub fn[Msg] a(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("a", attrs, children)
}

///|
pub fn[Msg] form(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  Element("form", attrs, children)
}
