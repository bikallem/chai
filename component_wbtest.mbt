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

///|
test "reused component slot refreshes captured closures and latest handle" {
  reset_component_state()
  let first_handle = Handle::new()
  let second_handle = Handle::new()
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::none())
  }
  fn make_update(multiplier : Int) -> (Int, Int) -> (Int, Cmd[Int]) {
    fn(model, msg) { (model + (msg * multiplier), Cmd::none()) }
  }
  fn make_view(prefix : String) -> (Int) -> VNode[Int] {
    fn(model) { text(prefix + model.to_string()) }
  }

  let first : VNode[Unit] = component(
    id="counter",
    handle=first_handle,
    init~,
    update=make_update(1),
    view=make_view("first:"),
  )
  ignore(first)
  (first_handle.dispatch.val)(2)

  let second : VNode[Unit] = component(
    id="counter",
    handle=second_handle,
    init~,
    update=make_update(10),
    view=make_view("second:"),
  )
  ignore(second)

  (first_handle.dispatch.val)(5)
  (second_handle.dispatch.val)(1)

  let third : VNode[Unit] = component(
    id="counter",
    handle=second_handle,
    init~,
    update=make_update(10),
    view=make_view("second:"),
  )
  ignore(third)

  match component_slots.get("id:counter") {
    Some(slot) =>
      match slot.current_expanded.val {
        Text("second:12") => ()
        _ => panic()
      }
    None => panic()
  }
}
