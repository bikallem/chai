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
  assert_eq(child_list_mode(plain, "p1") != child_list_mode(plain, "p2"), false)
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

///|
test "lis returns empty for empty array" {
  let result = lis([])
  assert_eq(result.length(), 0)
}

///|
test "lis returns single element for single-element array" {
  let result = lis([5])
  assert_eq(result.length(), 1)
  assert_eq(result.contains(0), true)
}

///|
test "lis returns correct result for sorted array" {
  let result = lis([0, 1, 2, 3])
  assert_eq(result.length(), 4)
  for i = 0; i < 4; i = i + 1 {
    assert_eq(result.contains(i), true)
  }
}

///|
test "lis skips negative values" {
  let result = lis([-1, 0, -1, 2])
  assert_eq(result.contains(1), true) // index 1: value 0
  assert_eq(result.contains(3), true) // index 3: value 2
  assert_eq(result.length(), 2)
}

///|
test "lis handles reverse order" {
  let result = lis([3, 2, 1, 0])
  assert_eq(result.length(), 1)
}

///|
test "lis handles interleaved sequence" {
  // Values: [2, 0, 3, 1, 4]
  // LIS: [0, 1, 4] at indices [1, 3, 4] or [0, 3, 4] or [0, 2, 4]
  let result = lis([2, 0, 3, 1, 4])
  assert_eq(result.length(), 3)
  // Index 4 (value 4) must be in the LIS
  assert_eq(result.contains(4), true)
}

///|
test "lazy_ constructor creates Lazy variant" {
  let v : VNode[Unit] = lazy_(42, fn() { text("hi") })
  match v {
    Lazy(hash, _thunk) => assert_eq(hash, 42)
    _ => panic()
  }
}

///|
test "VNode::map on Lazy wraps thunk" {
  let v : VNode[Int] = lazy_(1, fn() { text("x") })
  let mapped = v.map(fn(x) { x + 10 })
  match mapped {
    Lazy(1, thunk) =>
      match thunk() {
        Text("x") => ()
        _ => panic()
      }
    _ => panic()
  }
}

///|
test "bind_events on Lazy wraps thunk" {
  let v : VNode[Int] = lazy_(7, fn() { text("ok") })
  let bound = bind_events(v, fn(_) {  })
  match bound {
    Lazy(7, thunk) =>
      match thunk() {
        Text("ok") => ()
        _ => panic()
      }
    _ => panic()
  }
}
