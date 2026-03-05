# Chai

A [TEA (The Elm Architecture)](https://guide.elm-lang.org/architecture/) framework for [MoonBit](https://www.moonbitlang.com/), targeting JavaScript/browser with virtual DOM diffing and encapsulated components.

## Table of Contents

- [Quick Start](#quick-start)
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
- [Examples](#examples)
- [License](#license)

## Quick Start

A minimal counter app:

```moonbit
struct Model { count : Int }

enum Msg { Increment; Decrement }

fn app_init() -> (Model, Cmd[Msg]) {
  ({ count: 0 }, Cmd::none())
}

fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    Increment => ({ count: model.count + 1 }, Cmd::none())
    Decrement => ({ count: model.count - 1 }, Cmd::none())
  }
}

fn view(model : Model) -> VNode[Msg] {
  div([], [
    button([on_click(fn(_e) { Decrement })], [text("-")]),
    span([], [text(model.count.to_string())]),
    button([on_click(fn(_e) { Increment })], [text("+")]),
  ])
}

fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::none()
}

fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
```

## Core Concepts

Every Chai app follows the TEA pattern:

- **Model** — your application state
- **Msg** — messages that describe state changes
- **init** — returns the initial `(Model, Cmd[Msg])`
- **update** — takes `(Model, Msg)`, returns the new `(Model, Cmd[Msg])`
- **view** — takes `Model`, returns `VNode[Msg]`
- **subscriptions** — takes `Model`, returns `Sub[Msg]` for external events

Call `start()` with these five functions and a CSS `selector` to mount the app.

## API Reference

### Elements

Build virtual DOM trees with element constructors. Each takes `(attrs, children)`:

`div`, `span`, `button`, `h1`, `h2`, `h3`, `p`, `ul`, `li`, `label`, `section`, `header`, `footer`, `a`, `form`, `nav`, `pre`, `code`, `em`, `strong`, `table`, `tr`, `td`, `th`, `textarea`, `select`, `option`

Self-closing elements take `(attrs)` only: `input_`, `img`, `br`, `hr`

Use `el(tag, attrs, children)` for any HTML tag, or `text(s)` for text nodes.

#### Keyed Lists

For efficient list diffing, wrap children with keys:

```moonbit
ul([], keyed_list(
  items.map(fn(item) { (item.id.to_string(), view_item(item)) })
))
```

### Attributes

```moonbit
class("my-class")        // HTML class
class_list([("active", is_active), ("hidden", is_hidden)]) // conditional classes
id("my-id")              // HTML id
type_("checkbox")        // HTML type
value("hello")           // input value (property)
checked(true)            // checkbox checked (property)
placeholder("Type...")   // placeholder
disabled(true)           // disabled (property)
href("/page")            // link href
for_("input-id")         // label for
style("color", "red")    // inline style
attr("data-x", "value") // any attribute
```

### Events

Convenience helpers extract common values from the event:

```moonbit
on_click(fn(event) { MyMsg })           // click (receives Event)
on_input(fn(value) { Input(value) })     // input (receives String value)
on_change(fn(value) { Changed(value) })  // change (receives String value)
on_check(fn(checked) { Toggle(checked) }) // checkbox (receives Bool)
on_keydown(fn(key) { KeyPress(key) })    // keydown (receives String key name)
on_submit(fn(event) { Submit })          // form submit (calls preventDefault)
```

For full event access on any event type, use the generic handler:

```moonbit
on("mousemove", fn(event) { Move(event) })
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

Each subscription takes a `key` string for identity — subscriptions with the same key are kept alive across renders, and removed when no longer returned.

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
hash_link("/about", [class("nav-link")], [text("About")])

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

link("/about", [class("nav-link")], [text("About")], on_nav=GoAbout)
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
./scripts/test-unit.sh
```

Full local suite (unit + Playwright smoke tests):

```bash
./scripts/test-all.sh
```

Detailed unit coverage and regression mapping live in [`docs/testing-matrix.md`](docs/testing-matrix.md).

## Examples

See the [`examples/`](examples/) directory:

- **todo** — TodoMVC-style app with input, filtering, and keyed list diffing
- **counters** — Encapsulated counter components with parent-to-child messaging via `Handle`
- **clock** — Stopwatch demonstrating `Sub::every`, `Sub::on_key_down`, and `Cmd::after`
- **router** — Hash-based routing with `Sub::on_hash_change` and `hash_link`
- **fetch** — HTTP requests with `Cmd::http_get`
- **canvas** — Canvas drawing with mouse event subscriptions

## License

MIT
