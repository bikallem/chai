///|
test "child_list_mode detects empty keyed and non-keyed lists" {
  let empty : Array[VNode[Unit]] = []
  let plain : Array[VNode[Unit]] = [text("a"), text("b")]
  let keyed_children : Array[VNode[Unit]] = [
    keyed("1", text("a")),
    keyed("2", text("b")),
  ]
  match child_list_mode(empty, "empty") {
    Empty => ()
    _ => panic()
  }
  match child_list_mode(plain, "plain") {
    NonKeyed => ()
    _ => panic()
  }
  match child_list_mode(keyed_children, "keyed") {
    AllKeyed => ()
    _ => panic()
  }
}

///|
test "child_list_mode treats Null as non-keyed" {
  let with_null : Array[VNode[Unit]] = [null(), text("a")]
  match child_list_mode(with_null, "with_null") {
    NonKeyed => ()
    _ => panic()
  }
  let only_null : Array[VNode[Unit]] = [null()]
  match child_list_mode(only_null, "only_null") {
    NonKeyed => ()
    _ => panic()
  }
}

///|
test "should_replace_children_on_mode_switch only flips for non-empty mode changes" {
  let plain : Array[VNode[Unit]] = [text("a")]
  let keyed_children : Array[VNode[Unit]] = [keyed("1", text("a"))]
  let empty : Array[VNode[Unit]] = []

  assert_eq(should_replace_children_on_mode_switch(plain, keyed_children), true)
  assert_eq(should_replace_children_on_mode_switch(keyed_children, plain), true)
  assert_eq(
    should_replace_children_on_mode_switch(empty, keyed_children),
    false,
  )
  assert_eq(
    should_replace_children_on_mode_switch(keyed_children, empty),
    false,
  )
  assert_eq(should_replace_children_on_mode_switch(plain, plain), false)
  assert_eq(
    should_replace_children_on_mode_switch(keyed_children, keyed_children),
    false,
  )
}

///|
test "first_duplicate_key detects duplicate keyed children" {
  let none : Array[VNode[Unit]] = [keyed("a", text("1")), keyed("b", text("2"))]
  let dup : Array[VNode[Unit]] = [
    keyed("a", text("1")),
    keyed("a", text("2")),
    keyed("b", text("3")),
  ]
  assert_eq(first_duplicate_key(none), None)
  assert_eq(first_duplicate_key(dup), Some("a"))
}
