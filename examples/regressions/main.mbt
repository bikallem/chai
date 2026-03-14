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
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  (
    {
      mode: Plain,
      items: pair_items(),
      duplicate_keys: false,
      link_activations: 0,
    },
    @chai.Cmd::none(),
  )
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    SwitchToKeyedSingle =>
      (
        {
          mode: Keyed,
          items: [{ key: "c", label: "C" }],
          duplicate_keys: false,
          link_activations: model.link_activations,
        },
        @chai.Cmd::none(),
      )
    SwitchToPlainPair =>
      (
        {
          mode: Plain,
          items: pair_items(),
          duplicate_keys: false,
          link_activations: model.link_activations,
        },
        @chai.Cmd::none(),
      )
    TriggerDuplicateKeys =>
      (
        {
          mode: Keyed,
          duplicate_keys: true,
          link_activations: model.link_activations,
          items: [{ key: "dup", label: "X" }, { key: "dup", label: "Y" }],
        },
        @chai.Cmd::none(),
      )
    ActivateLink =>
      (
        { ..model, link_activations: model.link_activations + 1 },
        @chai.Cmd::none(),
      )
  }
}

///|
fn view_item(item : Item) -> @chai.VNode[Msg] {
  @h.li([@h.class("item")], [@h.text(item.label)])
}

///|
fn view_list(model : Model) -> @chai.VNode[Msg] {
  let children = if model.mode == Keyed {
    if model.duplicate_keys {
      @h.keyed_list([
        ("dup", view_item(model.items[0])),
        ("dup", view_item(model.items[1])),
      ])
    } else {
      @h.keyed_list(model.items.map(fn(item) { (item.key, view_item(item)) }))
    }
  } else {
    model.items.map(view_item)
  }
  @h.ul([@h.class("items")], children)
}

///|
fn mode_label(mode : ListMode) -> String {
  match mode {
    Plain => "plain"
    Keyed => "keyed"
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("regressions-app")], [
    @h.h1([], [@h.text("Regression Harness")]),
    @h.h2([], [@h.text("Keyed Diff")]),
    @h.p([@h.class("mode")], [@h.text("Mode: " + mode_label(model.mode))]),
    view_list(model),
    @h.div([@h.class("controls")], [
      @h.button(
        [@h.class("to-keyed"), @h.on_click(fn(_) { SwitchToKeyedSingle })],
        [@h.text("Switch To Keyed Single")],
      ),
      @h.button(
        [@h.class("to-plain"), @h.on_click(fn(_) { SwitchToPlainPair })],
        [@h.text("Switch To Plain Pair")],
      ),
      @h.button(
        [@h.class("set-dup"), @h.on_click(fn(_) { TriggerDuplicateKeys })],
        [@h.text("Trigger Duplicate Keys")],
      ),
    ]),
    @h.h2([], [@h.text("Link Interception")]),
    @h.p([@h.class("link-count")], [@h.text(model.link_activations.to_string())]),
    @chai.link(
      "/regressions/same-tab",
      [@h.class("spa-link")],
      [@h.text("SPA Link")],
      on_nav=ActivateLink,
    ),
    @chai.link(
      "/regressions/new-tab",
      [@h.class("spa-link-blank"), @h.attr("target", "_blank")],
      [@h.text("Blank Target Link")],
      on_nav=ActivateLink,
    ),
  ])
}

///|
fn subscriptions(_model : Model) -> @chai.Sub[Msg] {
  @chai.Sub::none()
}

///|
fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
