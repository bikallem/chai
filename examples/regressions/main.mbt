///|
using @chai {
  type VNode,
  type Cmd,
  type Sub,
  start,
  div,
  h1,
  h2,
  p,
  ul,
  li,
  button,
  text,
  class,
  attr,
  on_click,
  keyed_list,
  link,
}

///|
enum ListMode {
  Plain
  Keyed
} derive(Eq)

///|
struct Item {
  key : String
  label : String
}

///|
struct Model {
  mode : ListMode
  items : Array[Item]
  duplicate_keys : Bool
  link_activations : Int
}

///|
enum Msg {
  SwitchToKeyedSingle
  SwitchToPlainPair
  TriggerDuplicateKeys
  ActivateLink
}

///|
fn pair_items() -> Array[Item] {
  [{ key: "a", label: "A" }, { key: "b", label: "B" }]
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  (
    {
      mode: Plain,
      items: pair_items(),
      duplicate_keys: false,
      link_activations: 0,
    },
    Cmd::none(),
  )
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    SwitchToKeyedSingle =>
      (
        {
          mode: Keyed,
          items: [{ key: "c", label: "C" }],
          duplicate_keys: false,
          link_activations: model.link_activations,
        },
        Cmd::none(),
      )
    SwitchToPlainPair =>
      (
        {
          mode: Plain,
          items: pair_items(),
          duplicate_keys: false,
          link_activations: model.link_activations,
        },
        Cmd::none(),
      )
    TriggerDuplicateKeys =>
      (
        {
          mode: Keyed,
          duplicate_keys: true,
          link_activations: model.link_activations,
          items: [{ key: "dup", label: "X" }, { key: "dup", label: "Y" }],
        },
        Cmd::none(),
      )
    ActivateLink =>
      ({ ..model, link_activations: model.link_activations + 1 }, Cmd::none())
  }
}

///|
fn view_item(item : Item) -> VNode[Msg] {
  li([class("item")], [text(item.label)])
}

///|
fn view_list(model : Model) -> VNode[Msg] {
  let children = if model.mode == Keyed {
    if model.duplicate_keys {
      keyed_list([
        ("dup", view_item(model.items[0])),
        ("dup", view_item(model.items[1])),
      ])
    } else {
      keyed_list(model.items.map(fn(item) { (item.key, view_item(item)) }))
    }
  } else {
    model.items.map(view_item)
  }
  ul([class("items")], children)
}

///|
fn mode_label(mode : ListMode) -> String {
  match mode {
    Plain => "plain"
    Keyed => "keyed"
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class("regressions-app")], [
    h1([], [text("Regression Harness")]),
    h2([], [text("Keyed Diff")]),
    p([class("mode")], [text("Mode: " + mode_label(model.mode))]),
    view_list(model),
    div([class("controls")], [
      button([class("to-keyed"), on_click(fn(_) { SwitchToKeyedSingle })], [
        text("Switch To Keyed Single"),
      ]),
      button([class("to-plain"), on_click(fn(_) { SwitchToPlainPair })], [
        text("Switch To Plain Pair"),
      ]),
      button([class("set-dup"), on_click(fn(_) { TriggerDuplicateKeys })], [
        text("Trigger Duplicate Keys"),
      ]),
    ]),
    h2([], [text("Link Interception")]),
    p([class("link-count")], [text(model.link_activations.to_string())]),
    link(
      "/regressions/same-tab",
      [class("spa-link")],
      [text("SPA Link")],
      on_nav=ActivateLink,
    ),
    link(
      "/regressions/new-tab",
      [class("spa-link-blank"), attr("target", "_blank")],
      [text("Blank Target Link")],
      on_nav=ActivateLink,
    ),
  ])
}

///|
fn subscriptions(_model : Model) -> Sub[Msg] {
  Sub::none()
}

///|
fn main {
  start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
