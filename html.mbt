// HTML element helpers
//
// Normal elements take (attrs, children). Void elements take (attrs) only.

// -- Sectioning / Structure --

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
pub fn[Msg] main_(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("main", attrs, children)
}

///|
pub fn[Msg] section(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("section", attrs, children)
}

///|
pub fn[Msg] article(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("article", attrs, children)
}

///|
pub fn[Msg] aside(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("aside", attrs, children)
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
pub fn[Msg] nav(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("nav", attrs, children)
}

// -- Headings --

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
pub fn[Msg] h4(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h4", attrs, children)
}

///|
pub fn[Msg] h5(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h5", attrs, children)
}

///|
pub fn[Msg] h6(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("h6", attrs, children)
}

// -- Text content --

///|
pub fn[Msg] p(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("p", attrs, children)
}

///|
pub fn[Msg] pre(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("pre", attrs, children)
}

///|
pub fn[Msg] blockquote(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("blockquote", attrs, children)
}

///|
pub fn[Msg] ol(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("ol", attrs, children)
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
pub fn[Msg] dl(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("dl", attrs, children)
}

///|
pub fn[Msg] dt(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("dt", attrs, children)
}

///|
pub fn[Msg] dd(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("dd", attrs, children)
}

///|
pub fn[Msg] figure(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("figure", attrs, children)
}

///|
pub fn[Msg] figcaption(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("figcaption", attrs, children)
}

// -- Inline text --

///|
pub fn[Msg] a(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("a", attrs, children)
}

///|
pub fn[Msg] strong(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("strong", attrs, children)
}

///|
pub fn[Msg] em(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("em", attrs, children)
}

///|
pub fn[Msg] code(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("code", attrs, children)
}

///|
pub fn[Msg] small(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("small", attrs, children)
}

///|
pub fn[Msg] sub(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("sub", attrs, children)
}

///|
pub fn[Msg] sup(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("sup", attrs, children)
}

///|
pub fn[Msg] mark(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("mark", attrs, children)
}

///|
pub fn[Msg] abbr(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("abbr", attrs, children)
}

///|
pub fn[Msg] time(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("time", attrs, children)
}

///|
pub fn[Msg] kbd(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("kbd", attrs, children)
}

///|
pub fn[Msg] samp(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("samp", attrs, children)
}

///|
pub fn[Msg] var_(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("var", attrs, children)
}

///|
pub fn[Msg] cite(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("cite", attrs, children)
}

// -- Forms --

///|
pub fn[Msg] form(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("form", attrs, children)
}

///|
pub fn[Msg] button(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("button", attrs, children)
}

///|
pub fn[Msg] label(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("label", attrs, children)
}

///|
pub fn[Msg] fieldset(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("fieldset", attrs, children)
}

///|
pub fn[Msg] legend(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("legend", attrs, children)
}

///|
pub fn[Msg] textarea(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("textarea", attrs, children)
}

///|
pub fn[Msg] select(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("select", attrs, children)
}

///|
pub fn[Msg] option(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("option", attrs, children)
}

///|
pub fn[Msg] optgroup(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("optgroup", attrs, children)
}

///|
pub fn[Msg] output(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("output", attrs, children)
}

///|
pub fn[Msg] progress(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("progress", attrs, children)
}

///|
pub fn[Msg] meter(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("meter", attrs, children)
}

///|
pub fn[Msg] datalist(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("datalist", attrs, children)
}

// -- Table --

///|
pub fn[Msg] table(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("table", attrs, children)
}

///|
pub fn[Msg] thead(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("thead", attrs, children)
}

///|
pub fn[Msg] tbody(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("tbody", attrs, children)
}

///|
pub fn[Msg] tfoot(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("tfoot", attrs, children)
}

///|
pub fn[Msg] tr(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("tr", attrs, children)
}

///|
pub fn[Msg] td(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("td", attrs, children)
}

///|
pub fn[Msg] th(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("th", attrs, children)
}

///|
pub fn[Msg] caption(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("caption", attrs, children)
}

///|
pub fn[Msg] colgroup(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("colgroup", attrs, children)
}

// -- Media / Embedded --

///|
pub fn[Msg] audio(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("audio", attrs, children)
}

///|
pub fn[Msg] video(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("video", attrs, children)
}

///|
pub fn[Msg] canvas(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("canvas", attrs, children)
}

///|
pub fn[Msg] iframe(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("iframe", attrs, children)
}

///|
pub fn[Msg] picture(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("picture", attrs, children)
}

///|
pub fn[Msg] svg(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("svg", attrs, children)
}

// -- Interactive --

///|
pub fn[Msg] details(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("details", attrs, children)
}

///|
pub fn[Msg] summary(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("summary", attrs, children)
}

///|
pub fn[Msg] dialog(
  attrs : Array[Attr[Msg]],
  children : Array[VNode[Msg]],
) -> VNode[Msg] {
  el("dialog", attrs, children)
}

// -- Void elements (no children) --

///|
pub fn[Msg] input(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("input", attrs, [])
}

///|
pub fn[Msg] img(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("img", attrs, [])
}

///|
pub fn[Msg] br(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("br", attrs, [])
}

///|
pub fn[Msg] hr(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("hr", attrs, [])
}

///|
pub fn[Msg] col(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("col", attrs, [])
}

///|
pub fn[Msg] embed(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("embed", attrs, [])
}

///|
pub fn[Msg] source(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("source", attrs, [])
}

///|
pub fn[Msg] track(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("track", attrs, [])
}

///|
pub fn[Msg] wbr(attrs : Array[Attr[Msg]]) -> VNode[Msg] {
  el("wbr", attrs, [])
}
