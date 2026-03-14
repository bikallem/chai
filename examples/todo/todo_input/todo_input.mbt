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
fn app_init() -> (Model, @chai.Cmd[Msg]) {
  ({ text: "" }, @chai.Cmd::none())
}

///|
fn update(
  model : Model,
  msg : Msg,
  on_submit : (String) -> @chai.Cmd[Msg],
) -> (Model, @chai.Cmd[Msg]) {
  match msg {
    UpdateText(text) => ({ text, }, @chai.Cmd::none())
    Submit => {
      if model.text.length() == 0 {
        return (model, @chai.Cmd::none())
      }
      ({ text: "" }, on_submit(model.text))
    }
  }
}

///|
fn view(model : Model) -> @chai.VNode[Msg] {
  @chai.div([@chai.class("input-row")], [
    @chai.input([
      @chai.class("todo-input"),
      @chai.type_("text"),
      @chai.placeholder("What needs to be done?"),
      @chai.value(model.text),
      @chai.on_input(fn(text) { UpdateText(text) }),
      @chai.on_keydown(fn(key) {
        if key == "Enter" {
          Submit
        } else {
          UpdateText(model.text)
        }
      }),
    ]),
    @chai.button([@chai.class("add-btn"), @chai.on_click(fn(_e) { Submit })], [
      @chai.text("Add"),
    ]),
  ])
}

///|
pub fn[ParentMsg] todo_input(
  on_submit : (String) -> @chai.Cmd[Msg],
) -> @chai.VNode[ParentMsg] {
  @chai.component(
    id="todo-input",
    init=app_init,
    update=fn(model, msg) { update(model, msg, on_submit) },
    view~,
  )
}
