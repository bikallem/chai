///|
priv struct Example {
  id : String
  title : String
  desc : String
}

///|
let examples : Array[Example] = [
  {
    id: "todo",
    title: "Todo",
    desc: "TodoMVC-style app with input, filtering, and keyed list diffing",
  },
  {
    id: "counters",
    title: "Counters",
    desc: "Encapsulated counter components with parent-to-child messaging via Handle",
  },
  {
    id: "clock",
    title: "Clock",
    desc: "Stopwatch with Sub::every, Sub::on_key_down, and Cmd::after",
  },
  {
    id: "router",
    title: "Router",
    desc: "Hash-based routing with Sub::on_hash_change and hash_link",
  },
  { id: "fetch", title: "Fetch", desc: "HTTP requests with Cmd::http_get" },
  {
    id: "canvas",
    title: "Canvas",
    desc: "Canvas drawing with mouse event subscriptions",
  },
]

///|
priv enum Target {
  JS
  WASM
} derive(Eq)

///|
fn Target::to_string(self : Target) -> String {
  match self {
    JS => "js"
    WASM => "wasm"
  }
}

///|
fn target_from_string(s : String) -> Target {
  if s == "wasm" {
    WASM
  } else {
    JS
  }
}

///|
priv struct Model {
  selected : String
  target : Target
}

///|
priv enum Msg {
  Select(String)
  SetTarget(Target)
  UrlChanged(@chai.Url)
}

///|
fn parse_url(url : @chai.Url) -> (String, Target) {
  match url.path {
    [id, t] => (id, target_from_string(t))
    [id] => (id, JS)
    _ => (examples[0].id, JS)
  }
}

///|
fn push_hash(id : String, target : Target) -> @chai.Cmd[Msg] {
  @chai.Cmd::push_hash("/" + id + "/" + target.to_string())
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  let (id, target) = parse_url(@chai.hash_url())
  ({ selected: id, target }, @chai.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    Select(id) => ({ ..model, selected: id }, push_hash(id, model.target))
    SetTarget(t) => ({ ..model, target: t }, push_hash(model.selected, t))
    UrlChanged(url) => {
      let (id, target) = parse_url(url)
      ({ selected: id, target }, @chai.Cmd::none())
    }
  }
}

///|
fn find_example(id : String) -> Example? {
  for ex in examples {
    if ex.id == id {
      return Some(ex)
    }
  }
  None
}

///|
fn base_url() -> String {
  let path = @webapi.window().location().pathname()
  if path.has_suffix("/") {
    path
  } else {
    path + "/"
  }
}

///|
fn iframe_src(id : String, target : Target) -> String {
  let base = base_url()
  match target {
    JS => base + "examples/" + id + ".html"
    WASM => base + "examples/wasm/" + id + ".html"
  }
}

///|
fn view_sidebar_btn(ex : Example, selected : String) -> @chai.VNode[Msg] {
  let is_active = ex.id == selected
  let cls = if is_active {
    "text-left px-3 py-1.5 rounded-md text-sm transition-colors cursor-pointer bg-stone-100 text-stone-900 font-medium"
  } else {
    "text-left px-3 py-1.5 rounded-md text-sm transition-colors cursor-pointer text-stone-600 hover:bg-stone-50"
  }
  @h.button([@h.class(cls), @h.on_click(fn(_e) { Select(ex.id) })], [
    @h.text(ex.title),
  ])
}

///|
fn toggle_cls(is_active : Bool) -> String {
  if is_active {
    "px-2.5 py-1 rounded text-xs font-medium bg-stone-800 text-white"
  } else {
    "px-2.5 py-1 rounded text-xs font-medium text-stone-500 hover:text-stone-700 cursor-pointer"
  }
}

///|
fn view_target_toggle(target : Target) -> @chai.VNode[Msg] {
  @h.div([@h.class("flex items-center gap-1 bg-stone-100 rounded-md p-0.5")], [
    @h.button(
      [
        @h.class(toggle_cls(target == JS)),
        @h.on_click(fn(_e) { SetTarget(JS) }),
      ],
      [@h.text("JS")],
    ),
    @h.button(
      [
        @h.class(toggle_cls(target == WASM)),
        @h.on_click(fn(_e) { SetTarget(WASM) }),
      ],
      [@h.text("WASM")],
    ),
  ])
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  let (title, desc) = match find_example(model.selected) {
    Some(ex) => (ex.title, ex.desc)
    None => ("", "")
  }
  let src = iframe_src(model.selected, model.target)
  @h.div([@h.class("h-screen flex flex-col")], [
    // Header
    @h.header(
      [
        @h.class(
          "bg-white border-b border-stone-200 px-6 py-3 flex items-center justify-between shrink-0",
        ),
      ],
      [
        @h.div([@h.class("flex items-center gap-3")], [
          @h.h1([@h.class("text-xl font-semibold tracking-tight")], [
            @h.text("Chai"),
          ]),
          @h.span([@h.class("text-stone-400 text-sm")], [
            @h.text("TEA framework for MoonBit"),
          ]),
        ]),
        @h.div([@h.class("flex items-center gap-4")], [
          view_target_toggle(model.target),
          @h.a(
            [
              @h.href("https://github.com/bikallem/chai"),
              @h.target("_blank"),
              @h.attr("rel", "noopener"),
              @h.class(
                "text-sm text-stone-500 hover:text-stone-800 transition-colors",
              ),
            ],
            [@h.text("GitHub")],
          ),
        ]),
      ],
    ),
    // Body
    @h.div([@h.class("flex flex-1 min-h-0")], [
      // Sidebar
      @h.nav(
        [
          @h.class(
            "w-56 shrink-0 bg-white border-r border-stone-200 py-4 px-3 flex flex-col gap-1 overflow-y-auto",
          ),
        ],
        examples.map(fn(ex) { view_sidebar_btn(ex, model.selected) }),
      ),
      // Main content
      @h.main_([@h.class("flex-1 flex flex-col min-w-0")], [
        @h.div(
          [@h.class("px-6 py-3 bg-white border-b border-stone-200 shrink-0")],
          [
            @h.h2([@h.class("text-lg font-medium")], [@h.text(title)]),
            @h.p([@h.class("text-sm text-stone-500 mt-0.5")], [@h.text(desc)]),
          ],
        ),
        @h.div([@h.class("flex-1 min-h-0 p-4")], [
          @h.iframe(
            [
              @h.attr("src", src),
              @h.class(
                "w-full h-full rounded-lg border border-stone-200 bg-white",
              ),
            ],
            [],
          ),
        ]),
      ]),
    ]),
  ])
}

///|
fn subscriptions(_model : Model) -> @chai.Sub[Msg] {
  @chai.Sub::on_hash_change("url", fn(url) { UrlChanged(url) })
}

///|
fn main {
  @chai.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
