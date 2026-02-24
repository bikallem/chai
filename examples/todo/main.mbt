///|
pub(all) enum Filter {
  All
  Active
  Completed
} derive(Eq)

///|
pub(all) struct Todo {
  id : Int
  text : String
  completed : Bool
}

///|
struct Model {
  todos : Array[Todo]
  input : String
  next_id : Int
  filter : Filter
}

///|
pub(all) enum Msg {
  UpdateInput(String)
  AddTodo
  ToggleTodo(Int)
  DeleteTodo(Int)
  SetFilter(Filter)
  ClearCompleted
}

///|
fn app_init() -> (Model, @mvdom.Cmd[Msg]) {
  let model : Model = { todos: [], input: "", next_id: 1, filter: All }
  (model, @mvdom.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @mvdom.Cmd[Msg]) {
  match msg {
    UpdateInput(value) => ({ ..model, input: value }, @mvdom.Cmd::none())
    AddTodo => {
      if model.input.length() == 0 {
        return (model, @mvdom.Cmd::none())
      }
      let todo : Todo = {
        id: model.next_id,
        text: model.input,
        completed: false,
      }
      let new_todos = model.todos.copy()
      new_todos.push(todo)
      (
        { ..model, todos: new_todos, input: "", next_id: model.next_id + 1 },
        @mvdom.Cmd::none(),
      )
    }
    ToggleTodo(id) => {
      let new_todos = model.todos.map(fn(t) {
        if t.id == id {
          { ..t, completed: not(t.completed) }
        } else {
          t
        }
      })
      ({ ..model, todos: new_todos }, @mvdom.Cmd::none())
    }
    DeleteTodo(id) => {
      let new_todos = model.todos.filter(fn(t) { t.id != id })
      ({ ..model, todos: new_todos }, @mvdom.Cmd::none())
    }
    SetFilter(filter) => ({ ..model, filter, }, @mvdom.Cmd::none())
    ClearCompleted => {
      let new_todos = model.todos.filter(fn(t) { not(t.completed) })
      ({ ..model, todos: new_todos }, @mvdom.Cmd::none())
    }
  }
}

///|
fn view_todo(todo : Todo) -> @mvdom.VNode[Msg] {
  let item_class = if todo.completed {
    "todo-item completed"
  } else {
    "todo-item"
  }
  @mvdom.li([@mvdom.class_(item_class)], [
    @mvdom.label([@mvdom.class_("todo-label")], [
      @mvdom.input_([
        @mvdom.type__("checkbox"),
        @mvdom.checked_(todo.completed),
        @mvdom.on_check(fn(_checked) { ToggleTodo(todo.id) }),
      ]),
      @mvdom.span([@mvdom.class_("todo-text")], [@mvdom.text(todo.text)]),
    ]),
    @mvdom.button(
      [
        @mvdom.class_("delete-btn"),
        @mvdom.on_click(fn(_e) { DeleteTodo(todo.id) }),
      ],
      [@mvdom.text("\u{00D7}")],
    ),
  ])
}

///|
fn view_filter_btn(
  current : Filter,
  filter : Filter,
  label_text : String,
) -> @mvdom.VNode[Msg] {
  let cls = if current == filter { "filter-btn active" } else { "filter-btn" }
  @mvdom.button(
    [@mvdom.class_(cls), @mvdom.on_click(fn(_e) { SetFilter(filter) })],
    [@mvdom.text(label_text)],
  )
}

///|
fn view(model : Model) -> @mvdom.VNode[Msg] {
  let visible_todos = model.todos.filter(fn(t) {
    match model.filter {
      All => true
      Active => not(t.completed)
      Completed => t.completed
    }
  })
  let items_left = model.todos.filter(fn(t) { not(t.completed) }).length()
  let items_text = if items_left == 1 { "item left" } else { "items left" }
  @mvdom.div([@mvdom.class_("todo-app")], [
    @mvdom.header([@mvdom.class_("todo-header")], [
      @mvdom.h1([], [@mvdom.text("todos")]),
      @mvdom.div([@mvdom.class_("input-row")], [
        @mvdom.input_([
          @mvdom.class_("todo-input"),
          @mvdom.type__("text"),
          @mvdom.placeholder_("What needs to be done?"),
          @mvdom.value_(model.input),
          @mvdom.on_input(fn(value) { UpdateInput(value) }),
          @mvdom.on_keydown(fn(key) {
            if key == "Enter" {
              AddTodo
            } else {
              UpdateInput(model.input)
            }
          }),
        ]),
        @mvdom.button(
          [@mvdom.class_("add-btn"), @mvdom.on_click(fn(_e) { AddTodo })],
          [@mvdom.text("Add")],
        ),
      ]),
    ]),
    @mvdom.section([@mvdom.class_("todo-list-section")], [
      @mvdom.ul(
        [@mvdom.class_("todo-list")],
        visible_todos.map(fn(t) { view_todo(t) }),
      ),
    ]),
    @mvdom.footer([@mvdom.class_("todo-footer")], [
      @mvdom.span([@mvdom.class_("todo-count")], [
        @mvdom.text(items_left.to_string() + " " + items_text),
      ]),
      @mvdom.div([@mvdom.class_("filters")], [
        view_filter_btn(model.filter, All, "All"),
        view_filter_btn(model.filter, Active, "Active"),
        view_filter_btn(model.filter, Completed, "Completed"),
      ]),
      @mvdom.button(
        [@mvdom.class_("clear-btn"), @mvdom.on_click(fn(_e) { ClearCompleted })],
        [@mvdom.text("Clear completed")],
      ),
    ]),
  ])
}

///|
fn subscriptions(_model : Model) -> @mvdom.Sub[Msg] {
  @mvdom.Sub::none()
}

///|
fn main {
  @mvdom.start(init=app_init, update~, view~, subscriptions~, selector="#app")
}
