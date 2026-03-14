# @chai/h — HTML View Helpers

`bikallem/chai/h` provides HTML element constructors, attribute helpers, and event handlers for building virtual DOM trees in [Chai](https://github.com/bikallem/chai).

This package contains all **view-related** functions. The core `bikallem/chai` package provides the runtime (`start`, `Cmd`, `Sub`, `component`, etc.), while `h` provides everything you need to describe what gets rendered.

## Setup

Add both packages to your `moon.pkg`:

```
import {
  "bikallem/chai",
  "bikallem/chai/h",
}
```

## Usage

```moonbit
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("app")], [
    @h.h1([], [@h.text("Hello")]),
    @h.input([
      @h.type_("text"),
      @h.placeholder("Type here..."),
      @h.value(model.input),
      @h.on_input(fn(value) { UpdateInput(value) }),
    ]),
    @h.button([@h.class("btn"), @h.on_click(fn(_e) { Submit })], [
      @h.text("Go"),
    ]),
    @h.ul([], items.map(fn(item) {
      @h.li([@h.class("item")], [@h.text(item)])
    })),
  ])
}
```

## Custom elements and attributes

Use `@h.el` and `@h.attr` for any HTML tag or attribute not covered by the named helpers:

```moonbit
// Any HTML element
@h.el("custom-widget", [@h.attr("data-mode", "compact")], [
  @h.text("content"),
])

// Any HTML attribute
@h.attr("aria-label", "Close")
@h.attr("data-testid", "submit-btn")
@h.attr("contenteditable", "true")

// DOM properties (set via JS property, not HTML attribute)
@h.property("indeterminate", @webapi.TJsValue::to_js(true))

// Inline styles
@h.style("background-color", "#f0f0f0")
@h.style("display", "flex")

// Generic event handler
@h.on("transitionend", fn(event) { AnimationDone })
```

## What's in each package

| Package | Contains |
|---------|----------|
| `@chai` | `start`, `Cmd`, `Sub`, `Handle`, `component`, `link`, `hash_link`, `url`, `hash_url`, `VNode`, `Attr`, `Url` |
| `@h` | `div`, `span`, `button`, `input`, `text`, `el`, `attr`, `class`, `id`, `value`, `style`, `on`, `on_click`, `on_input`, ... |

## Elements

Normal elements take `(attrs, children)`:

`div`, `span`, `main_`, `section`, `article`, `aside`, `header`, `footer`, `nav`, `h1`–`h6`, `p`, `pre`, `blockquote`, `ol`, `ul`, `li`, `dl`, `dt`, `dd`, `figure`, `figcaption`, `a`, `strong`, `em`, `code`, `small`, `sub`, `sup`, `mark`, `abbr`, `time`, `kbd`, `samp`, `var_`, `cite`, `form`, `button`, `label`, `fieldset`, `legend`, `textarea`, `select`, `option`, `optgroup`, `output`, `progress`, `meter`, `datalist`, `table`, `thead`, `tbody`, `tfoot`, `tr`, `td`, `th`, `caption`, `colgroup`, `audio`, `video`, `canvas`, `iframe`, `picture`, `svg`, `details`, `summary`, `dialog`

Void elements take `(attrs)` only:

`input`, `img`, `br`, `hr`, `col`, `embed`, `source`, `track`, `wbr`

Use `@h.el(tag, attrs, children)` for any tag not listed above.

## Attributes

```moonbit
@h.class("active")           // HTML attribute
@h.id("main")                // HTML attribute
@h.href("/about")            // HTML attribute
@h.value("hello")            // DOM property
@h.checked(true)             // DOM property
@h.disabled(false)           // DOM property
@h.attr("data-id", "42")    // generic — works for any attribute
@h.property("indeterminate", js_val)  // generic DOM property
@h.style("color", "red")    // inline style
@h.class_list([("active", true), ("hidden", false)])
```

## Events

```moonbit
@h.on_click(fn(event) { Clicked })
@h.on_input(fn(value) { Updated(value) })    // extracts string value
@h.on_change(fn(value) { Changed(value) })   // extracts string value
@h.on_check(fn(checked) { Toggled(checked) }) // extracts bool
@h.on_keydown(fn(key) { KeyPressed(key) })   // extracts key string
@h.on_submit(fn(event) { Submitted })         // calls preventDefault
@h.on("custom-event", fn(event) { Custom })   // generic — works for any event
```
