///|
priv enum Filter {
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
priv enum Msg {
  AddTodo(String)
  ToggleTodo(Int)
  DeleteTodo(Int)
  SetFilter(Filter)
  ClearCompleted
}

///|
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ todos: [], next_id: 1, filter: All }, @chai.Cmd::none())
}

///|
fn update(model : Model, msg : Msg) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    AddTodo(text) => {
      if text.length() == 0 {
        return (model, @chai.Cmd::none())
      }
      let todo : Todo = { id: model.next_id, text, completed: false }
      let new_todos = model.todos.copy()
      new_todos.push(todo)
      (
        { ..model, todos: new_todos, next_id: model.next_id + 1 },
        @chai.Cmd::none(),
      )
    }
    ToggleTodo(id) => {
      let new_todos = model.todos.map(fn(todo) {
        if todo.id == id {
          { ..todo, completed: not(todo.completed) }
        } else {
          todo
        }
      })
      ({ ..model, todos: new_todos }, @chai.Cmd::none())
    }
    DeleteTodo(id) => {
      let new_todos = model.todos.filter(fn(todo) { todo.id != id })
      ({ ..model, todos: new_todos }, @chai.Cmd::none())
    }
    SetFilter(filter) => ({ ..model, filter, }, @chai.Cmd::none())
    ClearCompleted => {
      let new_todos = model.todos.filter(fn(todo) { not(todo.completed) })
      ({ ..model, todos: new_todos }, @chai.Cmd::none())
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
fn view_todo(todo : Todo) -> @chai.VNode[Msg] {
  let item_class = if todo.completed {
    "todo-item completed"
  } else {
    "todo-item"
  }
  @chai.li([@chai.class(item_class)], [
    @chai.label([@chai.class("todo-label")], [
      @chai.input([
        @chai.type_("checkbox"),
        @chai.checked(todo.completed),
        @chai.on_check(fn(_checked) { ToggleTodo(todo.id) }),
      ]),
      @chai.span([@chai.class("todo-text")], [@chai.text(todo.text)]),
    ]),
    @chai.button(
      [
        @chai.class("delete-btn"),
        @chai.on_click(fn(_e) { DeleteTodo(todo.id) }),
      ],
      [@chai.text("\u{00D7}")],
    ),
  ])
}

///|
fn view_filter_btn(
  current : Filter,
  filter : Filter,
  label_text : String,
) -> @chai.VNode[Msg] {
  let cls = if current == filter { "filter-btn active" } else { "filter-btn" }
  @chai.button(
    [@chai.class(cls), @chai.on_click(fn(_e) { SetFilter(filter) })],
    [@chai.text(label_text)],
  )
}

///|
fn view(model : Model, dispatch : Ref[(Msg) -> Unit]) -> @chai.VNode[Msg] {
  let current_visible_todos = visible_todos(model)
  let current_items_left = items_left(model.todos)
  let items_text = if current_items_left == 1 {
    "item left"
  } else {
    "items left"
  }
  @chai.div([@chai.class("todo-app")], [
    @chai.header([@chai.class("todo-header")], [
      @chai.h1([], [@chai.text("todos")]),
      @todo_input.todo_input(fn(text) {
        @chai.Cmd::task(fn(_) { (dispatch.val)(AddTodo(text)) })
      }),
    ]),
    @chai.section([@chai.class("todo-list-section")], [
      @chai.ul(
        [@chai.class("todo-list")],
        @chai.keyed_list(
          current_visible_todos.map(fn(todo) {
            (todo.id.to_string(), view_todo(todo))
          }),
        ),
      ),
    ]),
    @chai.footer([@chai.class("todo-footer")], [
      @chai.span([@chai.class("todo-count")], [
        @chai.text(current_items_left.to_string() + " " + items_text),
      ]),
      @chai.div([@chai.class("filters")], [
        view_filter_btn(model.filter, All, "All"),
        view_filter_btn(model.filter, Active, "Active"),
        view_filter_btn(model.filter, Completed, "Completed"),
      ]),
      @chai.button(
        [@chai.class("clear-btn"), @chai.on_click(fn(_e) { ClearCompleted })],
        [@chai.text("Clear completed")],
      ),
    ]),
  ])
}

///|
fn main {
  let dispatch : Ref[(Msg) -> Unit] = Ref::new(fn(_) {  })
  @chai.start(
    init=fn() {
      let (model, cmd) = app_init()
      (
        model,
        @chai.Cmd::batch([cmd, @chai.Cmd::task(fn(d) { dispatch.val = d })]),
      )
    },
    update~,
    view=fn(model) { view(model, dispatch) },
    subscriptions=fn(_model : Model) -> @chai.Sub[Msg] { @chai.Sub::none() },
    selector="#app",
  )
}
