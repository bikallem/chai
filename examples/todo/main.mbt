///|
pub using @chai {
  type VNode,
  type Attr,
  type Cmd,
  type Sub,
  start,
  div,
  h1,
  span,
  button,
  input_,
  ul,
  li,
  label,
  header,
  section,
  footer,
  text,
  class,
  type_,
  checked,
  placeholder,
  value,
  on_click,
  on_input,
  on_check,
  on_keydown,
  keyed_list,
}

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
fn app_init() -> (Model, Cmd[Msg]) {
  let model : Model = { todos: [], input: "", next_id: 1, filter: All }
  (model, Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    UpdateInput(value) => ({ ..model, input: value }, Cmd::none())
    AddTodo => {
      if model.input.length() == 0 {
        return (model, Cmd::none())
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
        Cmd::none(),
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
      ({ ..model, todos: new_todos }, Cmd::none())
    }
    DeleteTodo(id) => {
      let new_todos = model.todos.filter(fn(t) { t.id != id })
      ({ ..model, todos: new_todos }, Cmd::none())
    }
    SetFilter(filter) => ({ ..model, filter, }, Cmd::none())
    ClearCompleted => {
      let new_todos = model.todos.filter(fn(t) { not(t.completed) })
      ({ ..model, todos: new_todos }, Cmd::none())
    }
  }
}

///|
fn view_todo(todo : Todo) -> VNode[Msg] {
  let item_class = if todo.completed {
    "todo-item completed"
  } else {
    "todo-item"
  }
  li([class(item_class)], [
    label([class("todo-label")], [
      input_([
        type_("checkbox"),
        checked(todo.completed),
        on_check(fn(_checked) { ToggleTodo(todo.id) }),
      ]),
      span([class("todo-text")], [text(todo.text)]),
    ]),
    button([class("delete-btn"), on_click(fn(_e) { DeleteTodo(todo.id) })], [
      text("\u{00D7}"),
    ]),
  ])
}

///|
fn view_filter_btn(
  current : Filter,
  filter : Filter,
  label_text : String,
) -> VNode[Msg] {
  let cls = if current == filter { "filter-btn active" } else { "filter-btn" }
  button([class(cls), on_click(fn(_e) { SetFilter(filter) })], [
    text(label_text),
  ])
}

///|
fn view(model : Model) -> VNode[Msg] {
  let visible_todos = model.todos.filter(fn(t) {
    match model.filter {
      All => true
      Active => not(t.completed)
      Completed => t.completed
    }
  })
  let items_left = model.todos.filter(fn(t) { not(t.completed) }).length()
  let items_text = if items_left == 1 { "item left" } else { "items left" }
  div([class("todo-app")], [
    header([class("todo-header")], [
      h1([], [text("todos")]),
      div([class("input-row")], [
        input_([
          class("todo-input"),
          type_("text"),
          placeholder("What needs to be done?"),
          value(model.input),
          on_input(fn(value) { UpdateInput(value) }),
          on_keydown(fn(key) {
            if key == "Enter" {
              AddTodo
            } else {
              UpdateInput(model.input)
            }
          }),
        ]),
        button([class("add-btn"), on_click(fn(_e) { AddTodo })], [text("Add")]),
      ]),
    ]),
    section([class("todo-list-section")], [
      ul(
        [class("todo-list")],
        keyed_list(
          visible_todos.map(fn(t) { (t.id.to_string(), view_todo(t)) }),
        ),
      ),
    ]),
    footer([class("todo-footer")], [
      span([class("todo-count")], [
        text(items_left.to_string() + " " + items_text),
      ]),
      div([class("filters")], [
        view_filter_btn(model.filter, All, "All"),
        view_filter_btn(model.filter, Active, "Active"),
        view_filter_btn(model.filter, Completed, "Completed"),
      ]),
      button([class("clear-btn"), on_click(fn(_e) { ClearCompleted })], [
        text("Clear completed"),
      ]),
    ]),
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
