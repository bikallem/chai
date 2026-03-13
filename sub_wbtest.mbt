///|
test "Sub::none has no entries" {
  let none : Sub[Unit] = Sub::none()
  assert_eq(none.subs.length(), 0)
}

///|
test "Sub::batch concatenates entries" {
  let batched : Sub[Unit] = Sub::batch([
    Sub::sub("a", fn(_dispatch) { fn() {  } }),
    Sub::sub("b", fn(_dispatch) { fn() {  } }),
  ])
  assert_eq(batched.subs.length(), 2)
  assert_eq(batched.subs[0].key, "a")
  assert_eq(batched.subs[1].key, "b")
}

///|
test "Sub::map transforms emitted messages" {
  let seen : Array[String] = []
  let sub = Sub::sub("k", fn(dispatch) {
    dispatch(3)
    fn() {  }
  }).map(fn(x) { "m" + x.to_string() })
  let cleanup = (sub.subs[0].start)(fn(msg) { seen.push(msg) })
  cleanup()
  assert_eq(seen.length(), 1)
  assert_eq(seen[0], "m3")
}

///|
test "Sub::sub cleanup function is returned by start" {
  let cleaned = Ref::new(0)
  let sub : Sub[Unit] = Sub::sub("x", fn(_dispatch) {
    fn() { cleaned.val += 1 }
  })
  let cleanup = (sub.subs[0].start)(fn(_msg) {  })
  assert_eq(cleaned.val, 0)
  cleanup()
  assert_eq(cleaned.val, 1)
}
