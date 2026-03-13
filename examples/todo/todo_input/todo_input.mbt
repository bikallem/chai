///|
pub using @chai {
  type VNode,
  type Cmd,
  div,
  button,
  input_,
  text,
  class,
  component,
  type_,
  placeholder,
  value,
  on_click,
  on_input,
  on_keydown,
}

///|
priv struct Model {
  text : String
}

///|
pub(all) enum Msg {
  UpdateText(String)
  Submit
}

///|
fn app_init() -> (Model, Cmd[Msg]) {
  ({ text: "" }, Cmd::none())
}

///|
fn update(
  model : Model,
  msg : Msg,
  on_submit : (String) -> Cmd[Msg],
) -> (Model, Cmd[Msg]) {
  match msg {
    UpdateText(text) => ({ text, }, Cmd::none())
    Submit => {
      if model.text.length() == 0 {
        return (model, Cmd::none())
      }
      ({ text: "" }, on_submit(model.text))
    }
  }
}

///|
fn view(model : Model) -> VNode[Msg] {
  div([class("input-row")], [
    input_([
      class("todo-input"),
      type_("text"),
      placeholder("What needs to be done?"),
      value(model.text),
      on_input(fn(text) { UpdateText(text) }),
      on_keydown(fn(key) {
        if key == "Enter" {
          Submit
        } else {
          UpdateText(model.text)
        }
      }),
    ]),
    button([class("add-btn"), on_click(fn(_e) { Submit })], [text("Add")]),
  ])
}

///|
pub fn[ParentMsg] todo_input(
  on_submit : (String) -> Cmd[Msg],
) -> VNode[ParentMsg] {
  component(
    id="todo-input",
    init=app_init,
    update=fn(model, msg) { update(model, msg, on_submit) },
    view~,
  )
}
