///|
test "class_list keeps only enabled classes" {
  let classes : Array[(String, Bool)] = [
    ("active", true),
    ("hidden", false),
    ("primary", true),
  ]
  let parts = classes.filter(fn(pair) { pair.1 }).map(fn(pair) { pair.0 })
  let result : Attr[Unit] = Attribute("class", parts.join(" "))
  match result {
    Attribute("class", value) => assert_eq(value, "active primary")
    _ => panic()
  }
}

///|
#cfg(target="js")
test "on_input and on_check extract values from event target" {
  let input_attr = on("input", fn(e) {
    let target : @webapi.JsObject = @webapi.TJsValue::to_js(e.target()).unsafe_into()
    target.get("value").to_string()
  })
  match input_attr {
    Event("input", handler) =>
      assert_eq(handler(make_input_event("hello", false)), "hello")
    _ => panic()
  }
  let check_attr = on("change", fn(e) {
    let el : @webapi.HTMLInputElement = e.target().unsafe_into()
    el.checked()
  })
  match check_attr {
    Event("change", handler) =>
      assert_eq(handler(make_input_event("", true)), true)
    _ => panic()
  }
}

///|
#cfg(target="js")
test "on_input/on_change work for textarea and select value events" {
  let textarea_vnode = el(
    "textarea",
    [
      on("input", fn(e) {
        let target : @webapi.JsObject = @webapi.TJsValue::to_js(e.target()).unsafe_into()
        target.get("value").to_string()
      }),
    ],
    [],
  )
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

  let select_vnode = el(
    "select",
    [
      on("change", fn(e) {
        let target : @webapi.JsObject = @webapi.TJsValue::to_js(e.target()).unsafe_into()
        target.get("value").to_string()
      }),
    ],
    [el("option", [], [text("A")])],
  )
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
#cfg(target="js")
test "on_keydown and on_submit decode event payloads" {
  let key_attr = on("keydown", fn(e) {
    let ke : @webapi.KeyboardEvent = e.unsafe_into()
    ke.key()
  })
  match key_attr {
    Event("keydown", handler) =>
      assert_eq(handler(make_key_event("Escape")), "Escape")
    _ => panic()
  }

  let submit_attr = on("submit", fn(e) {
    e.prevent_default()
    99
  })
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
#cfg(target="js")
test "Attr::map remaps event payload" {
  let mapped = on("click", fn(_e) { 1 }).map(fn(x) { x + 10 })
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
#cfg(target="js")
test "bind_attr normalizes event handlers into bound DOM handlers" {
  let seen : Array[Int] = []
  let bound = bind_attr(on("click", fn(_e) { 7 }), fn(msg) { seen.push(msg) })
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
  let class_a : Attr[Unit] = Attribute("class", "a")
  let class_b : Attr[Unit] = Attribute("class", "b")

  assert_eq(same_attr_slot(event_attr, maybe_attr), true)
  assert_eq(same_attr_slot(maybe_attr, bound_attr), true)
  assert_eq(attr_needs_update(event_attr, maybe_attr), true)
  assert_eq(attr_needs_update(class_a, class_a), false)
  assert_eq(attr_needs_update(class_a, class_b), true)
}

///|
#cfg(target="js")
test "VNode::map remaps nested keyed event handlers" {
  let vnode = keyed(
    "k1",
    el("button", [on("click", fn(_e) { 2 })], [text("tap")]),
  )
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
