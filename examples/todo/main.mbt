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
  li([class_(item_class)], [
    label([class_("todo-label")], [
      input_([
        type_("checkbox"),
        checked(todo.completed),
        on_check(fn(_checked) { ToggleTodo(todo.id) }),
      ]),
      span([class_("todo-text")], [text(todo.text)]),
    ]),
    button([class_("delete-btn"), on_click(fn(_e) { DeleteTodo(todo.id) })], [
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
  button([class_(cls), on_click(fn(_e) { SetFilter(filter) })], [
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
  div([class_("todo-app")], [
    header([class_("todo-header")], [
      h1([], [text("todos")]),
      div([class_("input-row")], [
        input_([
          class_("todo-input"),
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
        button([class_("add-btn"), on_click(fn(_e) { AddTodo })], [text("Add")]),
      ]),
    ]),
    section([class_("todo-list-section")], [
      ul([class_("todo-list")], visible_todos.map(fn(t) { view_todo(t) })),
    ]),
    footer([class_("todo-footer")], [
      span([class_("todo-count")], [
        text(items_left.to_string() + " " + items_text),
      ]),
      div([class_("filters")], [
        view_filter_btn(model.filter, All, "All"),
        view_filter_btn(model.filter, Active, "Active"),
        view_filter_btn(model.filter, Completed, "Completed"),
      ]),
      button([class_("clear-btn"), on_click(fn(_e) { ClearCompleted })], [
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
