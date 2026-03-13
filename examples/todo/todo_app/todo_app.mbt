///|
pub using @chai {
  type VNode,
  type Cmd,
  type Handle,
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
  component,
  type_,
  checked,
  on_click,
  on_check,
  keyed_list,
}

///|
using @todo_input { todo_input }

///|
pub(all) enum Filter {
  All
  Active
  Completed
} derive(Eq)

///|
priv struct Todo {
  id : Int
  text : String
  completed : Bool
}

///|
priv struct Model {
  todos : Array[Todo]
  next_id : Int
  filter : Filter
}

///|
pub(all) enum Msg {
  AddTodo(String)
  ToggleTodo(Int)
  DeleteTodo(Int)
  SetFilter(Filter)
  ClearCompleted
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ todos: [], next_id: 1, filter: All }, Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, Cmd[Msg]) {
  match msg {
    AddTodo(text) => {
      if text.length() == 0 {
        return (model, Cmd::none())
      }
      let todo : Todo = {
        id: model.next_id,
        text,
        completed: false,
      }
      let new_todos = model.todos.copy()
      new_todos.push(todo)
      ({ ..model, todos: new_todos, next_id: model.next_id + 1 }, Cmd::none())
    }
    ToggleTodo(id) => {
      let new_todos = model.todos.map(fn(todo) {
        if todo.id == id {
          { ..todo, completed: not(todo.completed) }
        } else {
          todo
        }
      })
      ({ ..model, todos: new_todos }, Cmd::none())
    }
    DeleteTodo(id) => {
      let new_todos = model.todos.filter(fn(todo) { todo.id != id })
      ({ ..model, todos: new_todos }, Cmd::none())
    }
    SetFilter(filter) => ({ ..model, filter }, Cmd::none())
    ClearCompleted => {
      let new_todos = model.todos.filter(fn(todo) { not(todo.completed) })
      ({ ..model, todos: new_todos }, Cmd::none())
    }
  }
}

///|
fn visible_todos(model : Model) -> Array[Todo] {
  model.todos.filter(fn(todo) {
    match model.filter {
      All => true
      Active => not(todo.completed)
      Completed => todo.completed
    }
  })
}

///|
fn items_left(todos : Array[Todo]) -> Int {
  todos.filter(fn(todo) { not(todo.completed) }).length()
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
fn view(model : Model, handle : Handle[Msg]) -> VNode[Msg] {
  let current_visible_todos = visible_todos(model)
  let current_items_left = items_left(model.todos)
  let items_text = if current_items_left == 1 {
    "item left"
  } else {
    "items left"
  }
  div([class("todo-app")], [
    header([class("todo-header")], [
      h1([], [text("todos")]),
      todo_input(fn(text) { Cmd::send(handle, AddTodo(text)) }),
    ]),
    section([class("todo-list-section")], [
      ul(
        [class("todo-list")],
        keyed_list(
          current_visible_todos.map(fn(todo) {
            (todo.id.to_string(), view_todo(todo))
          }),
        ),
      ),
    ]),
    footer([class("todo-footer")], [
      span([class("todo-count")], [
        text(current_items_left.to_string() + " " + items_text),
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
pub fn[ParentMsg] todo_app(handle : Handle[Msg]) -> VNode[ParentMsg] {
  component(
    id="todo-app",
    handle=handle,
    init=app_init,
    update~,
    view=fn(model) { view(model, handle) },
  )
}
