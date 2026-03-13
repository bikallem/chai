///|
test "parse_path splits and drops empty segments" {
  assert_eq(parse_path(""), [])
  assert_eq(parse_path("/"), [])
  assert_eq(parse_path("/a/b"), ["a", "b"])
  assert_eq(parse_path("//a///b/"), ["a", "b"])
}

///|
#cfg(target="js")
test "is_plain_primary_click enforces no modifiers and left button" {
  assert_eq(
    is_plain_primary_click(
      make_click_event(0, false, false, false, false, false, ""),
    ),
    true,
  )
  assert_eq(
    is_plain_primary_click(
      make_click_event(1, false, false, false, false, false, ""),
    ),
    false,
  )
  assert_eq(
    is_plain_primary_click(
      make_click_event(0, false, true, false, false, false, ""),
    ),
    false,
  )
}

///|
#cfg(target="js")
test "should_intercept_link_click matches same-tab plain click only" {
  assert_eq(
    should_intercept_link_click(
      make_click_event(0, false, false, false, false, false, ""),
    ),
    true,
  )
  assert_eq(
    should_intercept_link_click(
      make_click_event(0, false, false, false, false, false, "_self"),
    ),
    true,
  )
  assert_eq(
    should_intercept_link_click(
      make_click_event(0, false, false, false, false, false, "_blank"),
    ),
    false,
  )
  assert_eq(
    should_intercept_link_click(
      make_click_event(0, false, false, false, false, true, ""),
    ),
    false,
  )
}

///|
#cfg(target="js")
test "link emits EventMaybe click handler with interception rules" {
  let vnode = link("/next", [class("cta")], [text("go")], on_nav=7)
  match vnode {
    Element("a", attrs, children) => {
      assert_eq(children.length(), 1)
      assert_eq(attrs.length(), 3)
      match attrs[0] {
        Attribute("href", value) => assert_eq(value, "/next")
        _ => panic()
      }
      match attrs[1] {
        EventMaybe("click", handler) => {
          let plain = make_click_event(0, false, false, false, false, false, "")
          assert_eq(handler(plain), Some(7))
          assert_eq(plain.default_prevented(), true)

          let ctrl = make_click_event(0, false, true, false, false, false, "")
          assert_eq(handler(ctrl), None)
          assert_eq(ctrl.default_prevented(), false)
        }
        _ => panic()
      }
    }
    _ => panic()
  }
}
