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
test "on_input/on_change work for textarea and select value events" {
  let textarea_vnode = textarea([on_input(fn(value) { value })], [])
  match textarea_vnode {
    Element("textarea", attrs, children) => {
      assert_eq(children.length(), 0)
      match attrs[0] {
        Event("input", handler) =>
          assert_eq(handler(make_input_event("notes", false)), "notes")
        _ => panic()
      }
    }
    _ => panic()
  }

  let select_vnode = select([on_change(fn(value) { value })], [option([], [text("A")])])
  match select_vnode {
    Element("select", attrs, children) => {
      assert_eq(children.length(), 1)
      match attrs[0] {
        Event("change", handler) =>
          assert_eq(handler(make_input_event("selected", false)), "selected")
        _ => panic()
      }
    }
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
test "bind_attr normalizes event handlers into bound DOM handlers" {
  let seen : Array[Int] = []
  let bound = bind_attr(on_click(fn(_e) { 7 }), fn(msg) { seen.push(msg) })
  match bound {
    BoundEvent("click", handler) => {
      handler(make_click_event(0, false, false, false, false, false, ""))
      assert_eq(seen.length(), 1)
      assert_eq(seen[0], 7)
    }
    _ => panic()
  }
}

///|
test "attr slot helpers treat event variants as the same DOM slot" {
  let event_attr : Attr[Unit] = Event("click", fn(_e) {  })
  let maybe_attr : Attr[Unit] = EventMaybe("click", fn(_e) { Some(()) })
  let bound_attr = bind_attr(event_attr, fn(_msg) {  })
  let class_a : Attr[Unit] = class("a")
  let class_b : Attr[Unit] = class("b")

  assert_eq(same_attr_slot(event_attr, maybe_attr), true)
  assert_eq(same_attr_slot(maybe_attr, bound_attr), true)
  assert_eq(attr_needs_update(event_attr, maybe_attr), true)
  assert_eq(attr_needs_update(class_a, class_a), false)
  assert_eq(attr_needs_update(class_a, class_b), true)
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
