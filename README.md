# Chai

Chai is a [MoonBit](https://www.moonbitlang.com/) library for browser applications with a virtual DOM, browser-oriented commands and subscriptions, routing helpers, and encapsulated components.

It is inspired by the core TEA model of `Model`, `Msg`, `update`, and `view`, but it is not limited to a single flat application loop. Chai adds:

- stateful components with their own local `Model` and `Msg`
- parent/child messaging through `Handle` and `Cmd::send`
- built-in hash and `pushState` routing helpers
- browser-focused commands and subscriptions for timers, HTTP, keyboard, resize, and navigation events

## Table of Contents

- [Packages](#packages)
- [Benchmarks](#benchmarks)
- [Quick Start](#quick-start)
- [Examples](#examples)
- [Core Concepts](#core-concepts)
- [API Reference](#api-reference)
  - [Elements](#elements)
  - [Attributes](#attributes)
  - [Events](#events)
  - [Commands](#commands)
  - [Subscriptions](#subscriptions)
  - [Routing](#routing)
  - [Components](#components)
- [Testing](#testing)
- [License](#license)

## Packages

Chai is split into two packages:

| Package | Import | Purpose |
|---------|--------|---------|
| `bikallem/chai` | `@chai` | Runtime — `start`, `Cmd`, `Sub`, `Handle`, `component`, routing, `VNode`, `Attr` types |
| [`bikallem/chai/h`](h/README.md) | `@h` | View helpers — `div`, `text`, `el`, `attr`, `class`, `on_click`, and all other HTML/attribute/event constructors |

Add both to your `moon.pkg`:

```
import {
  "bikallem/chai",
  "bikallem/chai/h",
}
```

See the [`h` package README](h/README.md) for the complete list of elements, attributes, and events.

## Benchmarks

Performance on the [js-framework-benchmark](https://github.com/krausest/js-framework-benchmark) operations (median of 5 runs, headless Chromium, lower is better):

| Operation | Chai JS | Chai WASM | Vanilla JS | React 18 | Preact |
|---|--:|--:|--:|--:|--:|
| Create 1,000 rows | **45ms** | **44ms** | 61ms | 55ms | 51ms |
| Create 10,000 rows | 518ms | **483ms** | **483ms** | 620ms | 558ms |
| Append 1,000 rows | 58ms | 57ms | **47ms** | 81ms | 74ms |
| Partial update (every 10th) | 23ms | 24ms | **21ms** | 30ms | 12ms |
| Clear rows | **5.4ms** | **5.4ms** | **5.4ms** | 12ms | 7.7ms |
| Swap rows | **8.4ms** | **7.7ms** | 11ms | 52ms | 13ms |
| Replace 1,000 rows | 44ms | **42ms** | **44ms** | 55ms | 66ms |
| Select row | 3.8ms | 3.3ms | **1.6ms** | 4.9ms | 4.6ms |
| Remove row | **10ms** | 11ms | **11ms** | 14ms | 14ms |

Chai uses keyed virtual DOM diffing with three key optimizations:

- **Bulk clear** — removes all children in a single `textContent = ""` call instead of one-by-one `removeChild`
- **Common-prefix scan** — skips HashMap/LIS overhead when key order is stable (the common case for select, update, append)
- **`lazy_`** — skips both vdom creation and diffing for rows whose hash hasn't changed

Run the benchmarks yourself:

```bash
make bench
```

## Quick Start

A minimal counter app:

```moonbit
struct Model { count : Int }

enum Msg { Increment; Decrement }

fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ count: 0 }, @chai.Cmd::none())
}

fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, @chai.Cmd::none())
    Decrement => ({ count: model.count - 1 }, @chai.Cmd::none())
  }
}

fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([], [
    @h.button([@h.on_click(fn(_e) { Decrement })], [@h.text("-")]),
    @h.span([], [@h.text(model.count.to_string())]),
    @h.button([@h.on_click(fn(_e) { Increment })], [@h.text("+")]),
  ])
}

fn subscriptions(_model : Model) -> @chai.Sub[Msg] {
  @chai.Sub::none()
}

fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
```

## Examples

See the [`examples/`](examples/) directory:

- **todo** — TodoMVC-style app with input, filtering, and keyed list diffing
- **counters** — Encapsulated counter components with parent-to-child messaging via `Handle`
- **clock** — Stopwatch demonstrating `Sub::every`, `Sub::on_key_down`, and `Cmd::after`
- **router** — Hash-based routing with `Sub::on_hash_change` and `hash_link`
- **fetch** — HTTP requests with `Cmd::http_get`
- **canvas** — Canvas drawing with mouse event subscriptions

## Core Concepts

Every Chai app starts from the familiar TEA-style state transition pattern:

- **Model** — your application state
- **Msg** — messages that describe state changes
- **init** — returns the initial `(Model, Cmd[Msg])`
- **update** — takes `(Model, Msg)`, returns the new `(Model, Cmd[Msg])`
- **view** — takes `Model`, returns `VNode[Msg]`
- **subscriptions** — takes `Model`, returns `Sub[Msg]` for external events

Call `start()` with these five functions and a CSS `selector` to mount the app.

## API Reference

### Elements

Build virtual DOM trees with element constructors from `@h`. Each takes `(attrs, children)`:

```moonbit
@h.div([@h.class("container")], [
  @h.h1([], [@h.text("Title")]),
  @h.p([], [@h.text("Content")]),
])
```

Use `@h.el(tag, attrs, children)` for any HTML tag, or `@h.text(s)` for text nodes.

#### Keyed Lists

For efficient list diffing, wrap children with keys:

```moonbit
@h.ul([], @h.keyed_list(
  items.map(fn(item) { (item.id.to_string(), view_item(item)) })
))
```

#### Null Nodes

Use `@h.null()` when a branch should render nothing. This produces no DOM output — the differ treats it as a no-op.

```moonbit
// Conditional rendering
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([], [
    if model.show_banner {
      @h.div([@h.class("banner")], [@h.text("Welcome!")])
    } else {
      @h.null()
    },
    @h.p([], [@h.text("Content")]),
  ])
}

// Optional list items
@h.ul([], items.map(fn(item) {
  if item.visible { @h.li([], [@h.text(item.name)]) } else { @h.null() }
}))
```

### Attributes

```moonbit
@h.class("my-class")        // HTML class
@h.class_list([("active", is_active), ("hidden", is_hidden)])
@h.id("my-id")              // HTML id
@h.type_("checkbox")        // HTML type
@h.value("hello")           // input value (property)
@h.checked(true)            // checkbox checked (property)
@h.placeholder("Type...")   // placeholder
@h.disabled(true)           // disabled (property)
@h.href("/page")            // link href
@h.style("color", "red")    // inline style
@h.attr("data-x", "value") // any attribute
```

### Events

Convenience helpers extract common values from the event:

```moonbit
@h.on_click(fn(event) { MyMsg })           // click (receives Event)
@h.on_input(fn(value) { Input(value) })     // input (receives String value)
@h.on_change(fn(value) { Changed(value) })  // change (receives String value)
@h.on_check(fn(checked) { Toggle(checked) }) // checkbox (receives Bool)
@h.on_keydown(fn(key) { KeyPress(key) })    // keydown (receives String key name)
@h.on_submit(fn(event) { Submit })          // form submit (calls preventDefault)
```

For full event access on any event type, use the generic handler:

```moonbit
@h.on("mousemove", fn(event) { Move(event) })
```

### Commands

```moonbit
Cmd::none()                       // no side effects
Cmd::batch([cmd1, cmd2])          // combine commands
Cmd::task(fn(dispatch) { ... })   // custom async task
Cmd::after(500, DelayedMsg)       // dispatch after delay (ms)
Cmd::http_get(url, fn(result) { GotResponse(result) }) // HTTP GET
Cmd::send(handle, child_msg)      // send message to child component
Cmd::push_url("/path")            // pushState navigation (see Routing)
Cmd::replace_url("/path")         // replaceState navigation (see Routing)
Cmd::push_hash("/path")           // hash navigation (see Routing)
cmd.map(fn(msg) { Wrapped(msg) }) // transform message type
```

`Cmd::http_get` dispatches `Ok(body)` on success or `Err(message)` on failure.

### Subscriptions

```moonbit
Sub::none()
Sub::batch([sub1, sub2])
Sub::every(1000, "tick", fn() { Tick })  // recurring timer (ms)
Sub::on_key_down("keys", fn(key) { KeyDown(key) }) // document keydown
Sub::on_window_resize("resize", fn(w, h) { Resized(w, h) }) // window resize
Sub::on_hash_change("url", fn(url) { UrlChanged(url) })    // hash routing (see Routing)
Sub::on_url_change("url", fn(url) { UrlChanged(url) })     // pushState routing (see Routing)
sub.map(fn(msg) { Wrapped(msg) })        // transform message type
```

Each subscription takes a `key` string to match it across renders.

Built-in subscriptions (`Sub::every`, `Sub::on_key_down`, `Sub::on_window_resize`, `Sub::on_hash_change`, `Sub::on_url_change`) keep the underlying listener/timer alive for the same key and refresh their message-producing behavior in place.

Custom `Sub::sub` subscriptions are re-initialized when returned again, so captured setup logic stays fresh; they are cleaned up when no longer returned.

For `on_key_down`, pass `prevent_default=fn(key) { ... }` to selectively prevent default browser behavior (for example, `fn(key) { key == " " }` to stop spacebar scrolling).

For custom subscriptions, use `Sub::sub` directly:

```moonbit
Sub::sub("my-sub", fn(dispatch) {
  // set up listener, return cleanup function
  fn() { /* cleanup */ }
})
```

### Routing

Chai provides hash-based and pushState-based routing as subscriptions and commands.

#### Hash-based routing (recommended for static hosting)

```moonbit
// Read the initial URL
fn app_init() -> (Model, Cmd[Msg]) {
  ({ route: to_route(hash_url()) }, Cmd::none())
}

// Subscribe to hash changes
fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::on_hash_change("url", fn(url) { UrlChanged(url) })
}

// Navigate with hash links
@chai.hash_link("/about", [@h.class("nav-link")], [@h.text("About")])

// Or navigate programmatically
Cmd::push_hash("/about")
```

#### pushState routing (requires server-side URL rewriting)

```moonbit
fn app_init() -> (Model, Cmd[Msg]) {
  ({ route: to_route(url()) }, Cmd::none())
}

fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::on_url_change("url", fn(url) { UrlChanged(url) })
}

@chai.link("/about", [@h.class("nav-link")], [@h.text("About")], on_nav=GoAbout)
Cmd::push_url("/about")
Cmd::replace_url("/about")
```

#### Url type

The `Url` struct is passed to your message handler on every navigation:

```moonbit
pub struct Url {
  path : Array[String]   // "/foo/bar" → ["foo", "bar"]
  query : String          // "?x=1" (raw, including ?)
  hash : String           // "#section" (raw, including #)
}
```

Match on `url.path` to select routes:

```moonbit
fn to_route(url : Url) -> Route {
  match url.path {
    [] => Home
    ["about"] => About
    ["posts", id] => Post(id)
    _ => NotFound
  }
}
```

### Components

Components are self-contained TEA loops with their own `Model` and `Msg` types, embedded as a `VNode` in the parent tree:

```moonbit
fn counter[ParentMsg]() -> VNode[ParentMsg] {
  component(
    init=fn() { ({ count: 0 }, Cmd::none()) },
    update~,
    view~,
  )
}
```

Pass `id` for stable identity in keyed lists. Use `Handle` for parent-to-child messaging:

```moonbit
let handle = Handle::new()
// In view: component(handle~, init~, update~, view~)
// In update: Cmd::send(handle, ChildMsg)
```

## Testing

Fast local unit checks:

```bash
make check
```

Full local suite (build + unit + Playwright smoke tests):

```bash
make test
```

Detailed unit coverage and regression mapping live in [`docs/testing-matrix.md`](docs/testing-matrix.md).

## License

MIT
