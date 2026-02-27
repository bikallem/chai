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
  - [Components](#components)
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

`div`, `span`, `button`, `input_`, `h1`, `h2`, `h3`, `p`, `ul`, `li`, `label`, `section`, `header`, `footer`, `a`, `form`

Use `el(tag, attrs, children)` for any HTML tag, or `text(s)` for text nodes.

### Attributes

```moonbit
class_("my-class")       // HTML class (trailing _ avoids reserved word)
id("my-id")              // HTML id
type_("checkbox")        // HTML type
value("hello")           // input value (property)
checked(true)            // checkbox checked (property)
placeholder("Type...")   // placeholder
disabled(true)           // disabled (property)
href("/page")            // link href
for_("input-id")         // label for
style("color", "red")    // inline style
at("data-x", "value")   // any attribute
```

### Events

```moonbit
on_click(fn(event) { MyMsg })      // click
on_input(fn(value) { Input(value) }) // input (receives String)
on_change(fn(value) { Changed(value) }) // change (receives String)
on_check(fn(checked) { Toggle(checked) }) // checkbox (receives Bool)
on_keydown(fn(key) { KeyPress(key) })  // keydown (receives String key name)
on_submit(fn(event) { Submit })    // form submit
```

### Commands

```moonbit
Cmd::none()           // no side effects
Cmd::task(fn(dispatch) { ... }) // async task
Cmd::batch([cmd1, cmd2])       // combine commands
cmd.map(fn(msg) { Wrapped(msg) }) // transform message type
```

### Subscriptions

```moonbit
Sub::none()
Sub::sub("timer", fn(dispatch) {
  let id = set_interval(fn() { dispatch(Tick) }, 1000)
  fn() { clear_interval(id) }  // cleanup
})
Sub::batch([sub1, sub2])
sub.map(fn(msg) { Wrapped(msg) })
```

### Components

Components run their own TEA loop:

```moonbit
fn widget[ParentMsg](reset_gen : Int) -> VNode[ParentMsg] {
  component(
    props_fingerprint=reset_gen,
    init=fn() { ({ count: 0 }, Cmd::none()) },
    update~,
    view~,
  )
}
```

When `props_fingerprint` changes, the component is destroyed and remounted.

## Examples

See the [`examples/`](examples/) directory:

- **todo** — TodoMVC-style app with input, filtering, and keyboard events
- **counters** — Multiple encapsulated counter components with parent reset

## License

MIT
