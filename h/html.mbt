// HTML element helpers
//
// Normal elements take (attrs, children). Void elements take (attrs) only.

// -- Sectioning / Structure --

///|
pub fn[Msg] div(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("div", attrs, children)
}

///|
pub fn[Msg] span(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("span", attrs, children)
}

///|
pub fn[Msg] main_(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("main", attrs, children)
}

///|
pub fn[Msg] section(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("section", attrs, children)
}

///|
pub fn[Msg] article(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("article", attrs, children)
}

///|
pub fn[Msg] aside(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("aside", attrs, children)
}

///|
pub fn[Msg] header(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("header", attrs, children)
}

///|
pub fn[Msg] footer(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("footer", attrs, children)
}

///|
pub fn[Msg] nav(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("nav", attrs, children)
}

// -- Headings --

///|
pub fn[Msg] h1(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h1", attrs, children)
}

///|
pub fn[Msg] h2(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h2", attrs, children)
}

///|
pub fn[Msg] h3(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h3", attrs, children)
}

///|
pub fn[Msg] h4(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h4", attrs, children)
}

///|
pub fn[Msg] h5(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h5", attrs, children)
}

///|
pub fn[Msg] h6(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("h6", attrs, children)
}

// -- Text content --

///|
pub fn[Msg] p(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("p", attrs, children)
}

///|
pub fn[Msg] pre(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("pre", attrs, children)
}

///|
pub fn[Msg] blockquote(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("blockquote", attrs, children)
}

///|
pub fn[Msg] ol(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("ol", attrs, children)
}

///|
pub fn[Msg] ul(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("ul", attrs, children)
}

///|
pub fn[Msg] li(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("li", attrs, children)
}

///|
pub fn[Msg] dl(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("dl", attrs, children)
}

///|
pub fn[Msg] dt(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("dt", attrs, children)
}

///|
pub fn[Msg] dd(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("dd", attrs, children)
}

///|
pub fn[Msg] figure(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("figure", attrs, children)
}

///|
pub fn[Msg] figcaption(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("figcaption", attrs, children)
}

// -- Inline text --

///|
pub fn[Msg] a(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("a", attrs, children)
}

///|
pub fn[Msg] strong(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("strong", attrs, children)
}

///|
pub fn[Msg] em(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("em", attrs, children)
}

///|
pub fn[Msg] code(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("code", attrs, children)
}

///|
pub fn[Msg] small(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("small", attrs, children)
}

///|
pub fn[Msg] sub(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("sub", attrs, children)
}

///|
pub fn[Msg] sup(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("sup", attrs, children)
}

///|
pub fn[Msg] mark(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("mark", attrs, children)
}

///|
pub fn[Msg] abbr(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("abbr", attrs, children)
}

///|
pub fn[Msg] time(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("time", attrs, children)
}

///|
pub fn[Msg] kbd(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("kbd", attrs, children)
}

///|
pub fn[Msg] samp(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("samp", attrs, children)
}

///|
pub fn[Msg] var_(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("var", attrs, children)
}

///|
pub fn[Msg] cite(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("cite", attrs, children)
}

// -- Forms --

///|
pub fn[Msg] form(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("form", attrs, children)
}

///|
pub fn[Msg] button(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("button", attrs, children)
}

///|
pub fn[Msg] label(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("label", attrs, children)
}

///|
pub fn[Msg] fieldset(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("fieldset", attrs, children)
}

///|
pub fn[Msg] legend(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("legend", attrs, children)
}

///|
pub fn[Msg] textarea(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("textarea", attrs, children)
}

///|
pub fn[Msg] select(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("select", attrs, children)
}

///|
pub fn[Msg] option(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("option", attrs, children)
}

///|
pub fn[Msg] optgroup(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("optgroup", attrs, children)
}

///|
pub fn[Msg] output(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("output", attrs, children)
}

///|
pub fn[Msg] progress(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("progress", attrs, children)
}

///|
pub fn[Msg] meter(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("meter", attrs, children)
}

///|
pub fn[Msg] datalist(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("datalist", attrs, children)
}

// -- Table --

///|
pub fn[Msg] table(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("table", attrs, children)
}

///|
pub fn[Msg] thead(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("thead", attrs, children)
}

///|
pub fn[Msg] tbody(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("tbody", attrs, children)
}

///|
pub fn[Msg] tfoot(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("tfoot", attrs, children)
}

///|
pub fn[Msg] tr(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("tr", attrs, children)
}

///|
pub fn[Msg] td(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("td", attrs, children)
}

///|
pub fn[Msg] th(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("th", attrs, children)
}

///|
pub fn[Msg] caption(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("caption", attrs, children)
}

///|
pub fn[Msg] colgroup(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("colgroup", attrs, children)
}

// -- Media / Embedded --

///|
pub fn[Msg] audio(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("audio", attrs, children)
}

///|
pub fn[Msg] video(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("video", attrs, children)
}

///|
pub fn[Msg] canvas(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("canvas", attrs, children)
}

///|
pub fn[Msg] iframe(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("iframe", attrs, children)
}

///|
pub fn[Msg] picture(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("picture", attrs, children)
}

///|
pub fn[Msg] svg(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("svg", attrs, children)
}

// -- Interactive --

///|
pub fn[Msg] details(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("details", attrs, children)
}

///|
pub fn[Msg] summary(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("summary", attrs, children)
}

///|
pub fn[Msg] dialog(
  attrs : Array[@chai.Attr[Msg]],
  children : Array[@chai.VNode[Msg]],
) -> @chai.VNode[Msg] {
  @chai.el("dialog", attrs, children)
}

// -- Void elements (no children) --

///|
pub fn[Msg] input(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("input", attrs, [])
}

///|
pub fn[Msg] img(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("img", attrs, [])
}

///|
pub fn[Msg] br(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("br", attrs, [])
}

///|
pub fn[Msg] hr(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("hr", attrs, [])
}

///|
pub fn[Msg] col(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("col", attrs, [])
}

///|
pub fn[Msg] embed(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("embed", attrs, [])
}

///|
pub fn[Msg] source(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("source", attrs, [])
}

///|
pub fn[Msg] track(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("track", attrs, [])
}

///|
pub fn[Msg] wbr(attrs : Array[@chai.Attr[Msg]]) -> @chai.VNode[Msg] {
  @chai.el("wbr", attrs, [])
}
