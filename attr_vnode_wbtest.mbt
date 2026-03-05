///|
test "class_list keeps only enabled classes" {
  let classes : Attr[Unit] = class_list([
    ("active", true),
    ("hidden", false),
    ("primary", true),
  ])
  match classes {
    Attribute("class", value) => assert_eq(value, "active primary")
    _ => panic()
  }
}

///|
test "on_input and on_check extract values from event target" {
  let input_attr = on_input(fn(s) { s })
  match input_attr {
    Event("input", handler) =>
      assert_eq(handler(make_input_event("hello", false)), "hello")
    _ => panic()
  }
  let check_attr = on_check(fn(v) { v })
  match check_attr {
    Event("change", handler) =>
      assert_eq(handler(make_input_event("", true)), true)
    _ => panic()
  }
}

///|
test "on_keydown and on_submit decode event payloads" {
  let key_attr = on_keydown(fn(k) { k })
  match key_attr {
    Event("keydown", handler) =>
      assert_eq(handler(make_key_event("Escape")), "Escape")
    _ => panic()
  }

  let submit_attr = on_submit(fn(_e) { 99 })
  match submit_attr {
    Event("submit", handler) => {
      let e = make_click_event(0, false, false, false, false, false, "")
      assert_eq(handler(e), 99)
      assert_eq(e.default_prevented(), true)
    }
    _ => panic()
  }
}

///|
test "Attr::map remaps event payload" {
  let mapped = on_click(fn(_e) { 1 }).map(fn(x) { x + 10 })
  match mapped {
    Event("click", handler) =>
      assert_eq(
        handler(make_click_event(0, false, false, false, false, false, "")),
        11,
      )
    _ => panic()
  }
}

///|
test "VNode::map remaps nested keyed event handlers" {
  let vnode = keyed("k1", button([on_click(fn(_e) { 2 })], [text("tap")]))
  let mapped = vnode.map(fn(x) { x * 10 })
  match mapped {
    Keyed("k1", Element("button", attrs, children)) => {
      assert_eq(children.length(), 1)
      match children[0] {
        Text("tap") => ()
        _ => panic()
      }
      match attrs[0] {
        Event("click", handler) =>
          assert_eq(
            handler(make_click_event(0, false, false, false, false, false, "")),
            20,
          )
        _ => panic()
      }
    }
    _ => panic()
  }
}

///|
test "keyed_list wraps pairs into keyed children" {
  let children : Array[VNode[Unit]] = keyed_list([
    ("a", text("A")),
    ("b", text("B")),
  ])
  assert_eq(children.length(), 2)
  match children[0] {
    Keyed("a", Text("A")) => ()
    _ => panic()
  }
  match children[1] {
    Keyed("b", Text("B")) => ()
    _ => panic()
  }
}
