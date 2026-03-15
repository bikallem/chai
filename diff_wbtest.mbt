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
test "mode switch detection via child_list_mode" {
  let plain : Array[VNode[Unit]] = [text("a")]
  let keyed_children : Array[VNode[Unit]] = [keyed("1", text("a"))]
  let empty : Array[VNode[Unit]] = []

  // Different non-empty modes should trigger replacement
  assert_eq(
    child_list_mode(plain, "p") != child_list_mode(keyed_children, "k") &&
    child_list_mode(plain, "p") != Empty &&
    child_list_mode(keyed_children, "k") != Empty,
    true,
  )
  // Same mode should not
  assert_eq(
    child_list_mode(plain, "p1") != child_list_mode(plain, "p2"),
    false,
  )
  // Empty vs non-empty should not trigger replacement
  assert_eq(child_list_mode(empty, "e") == Empty, true)
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
