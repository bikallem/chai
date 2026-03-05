///|
test "component with explicit id reuses slot and keeps state via handle dispatch" {
  reset_component_state()
  let updates : Array[Int] = []
  let handle = Handle::new()
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::none())
  }
  fn update(model : Int, msg : Int) -> (Int, Cmd[Int]) {
    updates.push(msg)
    (model + msg, Cmd::none())
  }
  fn view(model : Int) -> VNode[Int] {
    text(model.to_string())
  }

  let first : VNode[Unit] = component(
    id="counter",
    handle~,
    init~,
    update~,
    view~,
  )
  ignore(first)
  (handle.dispatch.val)(2)
  let second : VNode[Unit] = component(
    id="counter",
    handle~,
    init~,
    update~,
    view~,
  )
  ignore(second)

  assert_eq(updates.length(), 1)
  assert_eq(updates[0], 2)
  assert_eq(component_slots.length(), 1)
  match component_slots.get("id:counter") {
    Some(slot) =>
      match slot.current_expanded.val {
        Text("2") => ()
        _ => panic()
      }
    None => panic()
  }
}

///|
test "removing unused component slot disconnects handle dispatch" {
  reset_component_state()
  let updates : Array[Int] = []
  let handle = Handle::new()
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::none())
  }
  fn update(model : Int, msg : Int) -> (Int, Cmd[Int]) {
    updates.push(msg)
    (model + msg, Cmd::none())
  }
  fn view(model : Int) -> VNode[Int] {
    text(model.to_string())
  }

  let first : VNode[Unit] = component(
    id="counter",
    handle~,
    init~,
    update~,
    view~,
  )
  ignore(first)
  begin_render_pass()
  remove_unused_component_slots()
  assert_eq(component_slots.length(), 0)

  (handle.dispatch.val)(5)
  assert_eq(updates.length(), 0)
}

///|
test "pending init commands are drained exactly once" {
  reset_component_state()
  let ran = Ref::new(0)
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::task(fn(_dispatch) { ran.val += 1 }))
  }
  fn update(model : Int, _msg : Int) -> (Int, Cmd[Int]) {
    (model, Cmd::none())
  }
  fn view(_model : Int) -> VNode[Int] {
    text("ok")
  }

  let vnode : VNode[Unit] = component(id="with-init", init~, update~, view~)
  ignore(vnode)
  assert_eq(pending_init_cmds.length(), 1)
  drain_pending_init_cmds()
  assert_eq(ran.val, 1)
  assert_eq(pending_init_cmds.length(), 0)
}
