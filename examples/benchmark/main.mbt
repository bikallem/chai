///|
priv struct Row {
  id : Int
  label : String
}

///|
priv struct Model {
  rows : Array[Row]
  next_id : Int
  selected : Int
  seed : Int
}

///|
priv enum Msg {
  Create1k
  Create10k
  Append1k
  PartialUpdate
  Clear
  SwapRows
  Select(Int)
  Remove(Int)
}

// -- Random label generation (LCG) --

///|
let adjectives : Array[String] = [
  "pretty", "large", "big", "small", "tall", "short", "long", "handsome", "plain",
  "quaint", "clean", "elegant", "easy", "angry", "crazy", "helpful", "mushy", "odd",
  "unsightly", "adorable", "important", "inexpensive", "cheap", "expensive", "fancy",
]

///|
let colors : Array[String] = [
  "red", "yellow", "blue", "green", "pink", "brown", "purple", "brown", "white",
  "black", "orange",
]

///|
let nouns : Array[String] = [
  "table", "chair", "house", "bbq", "desk", "car", "pony", "cookie", "sandwich",
  "burger", "pizza", "mouse", "keyboard",
]

///|
fn next_random(seed : Int) -> (Int, Int) {
  let next = (seed * 1103515245 + 12345).land(0x7fffffff)
  (next, next)
}

///|
fn pick(arr : Array[String], seed : Int) -> (String, Int) {
  let (val, next) = next_random(seed)
  (arr[val % arr.length()], next)
}

///|
fn random_label(seed : Int) -> (String, Int) {
  let (adj, s1) = pick(adjectives, seed)
  let (col, s2) = pick(colors, s1)
  let (noun, s3) = pick(nouns, s2)
  (adj + " " + col + " " + noun, s3)
}

///|
fn build_rows(
  count : Int,
  start_id : Int,
  seed : Int,
) -> (Array[Row], Int, Int) {
  let rows : Array[Row] = Array::new(capacity=count)
  let mut s = seed
  let mut id = start_id
  for i = 0; i < count; i = i + 1 {
    let (label, ns) = random_label(s)
    rows.push({ id, label })
    s = ns
    id = id + 1
  }
  (rows, id, s)
}

// -- TEA --

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ rows: [], next_id: 1, selected: 0, seed: 42 }, @chai.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Create1k => {
      let (rows, next_id, seed) = build_rows(1000, model.next_id, model.seed)
      ({ rows, next_id, seed, selected: 0 }, @chai.Cmd::none())
    }
    Create10k => {
      let (rows, next_id, seed) = build_rows(10000, model.next_id, model.seed)
      ({ rows, next_id, seed, selected: 0 }, @chai.Cmd::none())
    }
    Append1k => {
      let (new_rows, next_id, seed) = build_rows(
        1000,
        model.next_id,
        model.seed,
      )
      let rows = model.rows.copy()
      for row in new_rows {
        rows.push(row)
      }
      ({ ..model, rows, next_id, seed }, @chai.Cmd::none())
    }
    PartialUpdate => {
      let rows = model.rows.copy()
      let mut i = 0
      while i < rows.length() {
        rows[i] = { ..rows[i], label: rows[i].label + " !!!" }
        i = i + 10
      }
      ({ ..model, rows, }, @chai.Cmd::none())
    }
    Clear => ({ ..model, rows: [], selected: 0 }, @chai.Cmd::none())
    SwapRows =>
      if model.rows.length() > 998 {
        let rows = model.rows.copy()
        let tmp = rows[1]
        rows[1] = rows[998]
        rows[998] = tmp
        ({ ..model, rows, }, @chai.Cmd::none())
      } else {
        (model, @chai.Cmd::none())
      }
    Select(id) => ({ ..model, selected: id }, @chai.Cmd::none())
    Remove(id) => {
      let rows = model.rows.filter(fn(r) { r.id != id })
      ({ ..model, rows, }, @chai.Cmd::none())
    }
  }
}

///|
fn view_row(row : Row, is_selected : Bool) -> (String, @chai.VNode[Msg]) {
  let row_id = row.id
  let row_label = row.label
  let hash = row_id.lxor(row_label.length() * 17) * 2 +
    (if is_selected { 1 } else { 0 })
  (
    row_id.to_string(),
    @h.lazy_(hash, fn() {
      let row_class = if is_selected { "danger" } else { "" }
      @h.tr([@h.class(row_class)], [
        @h.td([@h.class("col-md-1")], [@h.text(row_id.to_string())]),
        @h.td([@h.class("col-md-4")], [
          @h.a([@h.class("lbl"), @h.on_click(fn(_e) { Select(row_id) })], [
            @h.text(row_label),
          ]),
        ]),
        @h.td([@h.class("col-md-1")], [
          @h.a([@h.class("remove"), @h.on_click(fn(_e) { Remove(row_id) })], [
            @h.span(
              [
                @h.class("glyphicon glyphicon-remove remove"),
                @h.aria("hidden", "true"),
              ],
              [],
            ),
          ]),
        ]),
        @h.td([@h.class("col-md-6")], []),
      ])
    }),
  )
}

///|
fn action_btn(btn_id : String, label : String, msg : Msg) -> @chai.VNode[Msg] {
  @h.div([@h.class("col-sm-6 smallpad")], [
    @h.button(
      [
        @h.type_("button"),
        @h.class("btn btn-primary btn-block"),
        @h.id(btn_id),
        @h.on_click(fn(_e) { msg }),
      ],
      [@h.text(label)],
    ),
  ])
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @h.div([@h.class("container")], [
    @h.div([@h.class("jumbotron")], [
      @h.div([@h.class("row")], [
        @h.div([@h.class("col-md-6")], [@h.h1([], [@h.text("Chai (keyed)")])]),
        @h.div([@h.class("col-md-6")], [
          @h.div([@h.class("row")], [
            action_btn("run", "Create 1,000 rows", Create1k),
            action_btn("runlots", "Create 10,000 rows", Create10k),
            action_btn("add", "Append 1,000 rows", Append1k),
            action_btn("update", "Update every 10th row", PartialUpdate),
            action_btn("clear", "Clear", Clear),
            action_btn("swaprows", "Swap Rows", SwapRows),
          ]),
        ]),
      ]),
    ]),
    @h.table([@h.class("table table-hover table-striped test-data")], [
      @h.tbody(
        [@h.id("tbody")],
        @h.keyed_list(
          model.rows.map(fn(row) { view_row(row, row.id == model.selected) }),
        ),
      ),
    ]),
    @h.span(
      [
        @h.class("preloadicon glyphicon glyphicon-remove"),
        @h.aria("hidden", "true"),
      ],
      [],
    ),
  ])
}

///|
fn main {
  @chai.start(
    init=app_init,
    update~,
    view=fn(model) { view(model) },
    subscriptions=fn(_model : Model) -> @chai.Sub[Msg] { @chai.Sub::none() },
    selector="#app",
  )
}
