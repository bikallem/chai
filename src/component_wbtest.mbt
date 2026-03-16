///|
fn[Msg] render_in_runtime(
  runtime : ComponentRuntime,
  render : () -> VNode[Msg],
) -> VNode[Msg] {
  begin_render_pass_for(runtime)
  with_component_runtime(runtime, render)
}

///|
test "component with explicit id reuses slot and keeps state via handle dispatch" {
  let runtime = new_component_runtime()
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

  let first : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(id="counter", handle~, init~, update~, view~)
  })
  ignore(first)
  (handle.dispatch.val)(2)
  let second : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(id="counter", handle~, init~, update~, view~)
  })
  ignore(second)

  assert_eq(updates.length(), 1)
  assert_eq(updates[0], 2)
  assert_eq(runtime.component_slots.length(), 1)
  match runtime.component_slots.get("id:counter") {
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
  let runtime = new_component_runtime()
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

  let first : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(id="counter", handle~, init~, update~, view~)
  })
  ignore(first)
  begin_render_pass_for(runtime)
  remove_unused_component_slots_for(runtime)
  assert_eq(runtime.component_slots.length(), 0)

  (handle.dispatch.val)(5)
  assert_eq(updates.length(), 0)
}

///|
test "pending init commands are drained exactly once" {
  let runtime = new_component_runtime()
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

  let vnode : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(id="with-init", init~, update~, view~)
  })
  ignore(vnode)
  assert_eq(runtime.pending_init_cmds.length(), 1)
  drain_pending_init_cmds_for(runtime)
  assert_eq(ran.val, 1)
  assert_eq(runtime.pending_init_cmds.length(), 0)
}

///|
test "reused component slot keeps the original closures and handle binding" {
  let runtime = new_component_runtime()
  let first_handle = Handle::new()
  let second_handle = Handle::new()
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::none())
  }
  fn make_update(multiplier : Int) -> (Int, Int) -> (Int, Cmd[Int]) {
    fn(model, msg) { (model + msg * multiplier, Cmd::none()) }
  }
  fn make_view(prefix : String) -> (Int) -> VNode[Int] {
    fn(model) { text(prefix + model.to_string()) }
  }

  let first : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(
      id="counter",
      handle=first_handle,
      init~,
      update=make_update(1),
      view=make_view("first:"),
    )
  })
  ignore(first)
  (first_handle.dispatch.val)(2)

  let second : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(
      id="counter",
      handle=second_handle,
      init~,
      update=make_update(10),
      view=make_view("second:"),
    )
  })
  ignore(second)

  (first_handle.dispatch.val)(5)
  (second_handle.dispatch.val)(1)

  let third : VNode[Unit] = render_in_runtime(runtime, fn() {
    component(
      id="counter",
      handle=second_handle,
      init~,
      update=make_update(10),
      view=make_view("second:"),
    )
  })
  ignore(third)

  match runtime.component_slots.get("id:counter") {
    Some(slot) =>
      match slot.current_expanded.val {
        Text("first:7") => ()
        _ => panic()
      }
    None => panic()
  }
}

///|
test "separate component runtimes isolate slots with the same id" {
  let runtime_a = new_component_runtime()
  let runtime_b = new_component_runtime()
  let handle_a = Handle::new()
  let handle_b = Handle::new()
  fn init() -> (Int, Cmd[Int]) {
    (0, Cmd::none())
  }
  fn update(model : Int, msg : Int) -> (Int, Cmd[Int]) {
    (model + msg, Cmd::none())
  }
  fn make_view(prefix : String) -> (Int) -> VNode[Int] {
    fn(model) { text(prefix + model.to_string()) }
  }

  let first_a : VNode[Unit] = render_in_runtime(runtime_a, fn() {
    component(
      id="shared",
      handle=handle_a,
      init~,
      update~,
      view=make_view("a:"),
    )
  })
  ignore(first_a)
  let first_b : VNode[Unit] = render_in_runtime(runtime_b, fn() {
    component(
      id="shared",
      handle=handle_b,
      init~,
      update~,
      view=make_view("b:"),
    )
  })
  ignore(first_b)

  (handle_a.dispatch.val)(2)
  (handle_b.dispatch.val)(5)

  let second_a : VNode[Unit] = render_in_runtime(runtime_a, fn() {
    component(
      id="shared",
      handle=handle_a,
      init~,
      update~,
      view=make_view("a:"),
    )
  })
  ignore(second_a)
  let second_b : VNode[Unit] = render_in_runtime(runtime_b, fn() {
    component(
      id="shared",
      handle=handle_b,
      init~,
      update~,
      view=make_view("b:"),
    )
  })
  ignore(second_b)

  assert_eq(runtime_a.component_slots.length(), 1)
  assert_eq(runtime_b.component_slots.length(), 1)
  match runtime_a.component_slots.get("id:shared") {
    Some(slot) =>
      match slot.current_expanded.val {
        Text("a:2") => ()
        _ => panic()
      }
    None => panic()
  }
  match runtime_b.component_slots.get("id:shared") {
    Some(slot) =>
      match slot.current_expanded.val {
        Text("b:5") => ()
        _ => panic()
      }
    None => panic()
  }
}
