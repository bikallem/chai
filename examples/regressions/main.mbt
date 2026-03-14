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
  @chai.li([@chai.class("item")], [@chai.text(item.label)])
}

///|
fn view_list(model : Model) -> @chai.VNode[Msg] {
  let children = if model.mode == Keyed {
    if model.duplicate_keys {
      @chai.keyed_list([
        ("dup", view_item(model.items[0])),
        ("dup", view_item(model.items[1])),
      ])
    } else {
      @chai.keyed_list(
        model.items.map(fn(item) { (item.key, view_item(item)) }),
      )
    }
  } else {
    model.items.map(view_item)
  }
  @chai.ul([@chai.class("items")], children)
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
  @chai.div([@chai.class("regressions-app")], [
    @chai.h1([], [@chai.text("Regression Harness")]),
    @chai.h2([], [@chai.text("Keyed Diff")]),
    @chai.p([@chai.class("mode")], [
      @chai.text("Mode: " + mode_label(model.mode)),
    ]),
    view_list(model),
    @chai.div([@chai.class("controls")], [
      @chai.button(
        [@chai.class("to-keyed"), @chai.on_click(fn(_) { SwitchToKeyedSingle })],
        [@chai.text("Switch To Keyed Single")],
      ),
      @chai.button(
        [@chai.class("to-plain"), @chai.on_click(fn(_) { SwitchToPlainPair })],
        [@chai.text("Switch To Plain Pair")],
      ),
      @chai.button(
        [@chai.class("set-dup"), @chai.on_click(fn(_) { TriggerDuplicateKeys })],
        [@chai.text("Trigger Duplicate Keys")],
      ),
    ]),
    @chai.h2([], [@chai.text("Link Interception")]),
    @chai.p([@chai.class("link-count")], [
      @chai.text(model.link_activations.to_string()),
    ]),
    @chai.link(
      "/regressions/same-tab",
      [@chai.class("spa-link")],
      [@chai.text("SPA Link")],
      on_nav=ActivateLink,
    ),
    @chai.link(
      "/regressions/new-tab",
      [@chai.class("spa-link-blank"), @chai.attr("target", "_blank")],
      [@chai.text("Blank Target Link")],
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
