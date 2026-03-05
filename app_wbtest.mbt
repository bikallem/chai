///|
test "update_subs starts new keys, keeps existing, and cleans removed" {
  let starts = Ref::new(0)
  let cleans = Ref::new(0)
  let received : Array[Int] = []
  let active : Map[String, ActiveSub] = {}

  let sub_a = Sub::sub("a", fn(dispatch) {
    starts.val += 1
    dispatch(1)
    fn() { cleans.val += 1 }
  })

  update_subs(sub_a, active, fn(msg) { received.push(msg) })
  assert_eq(starts.val, 1)
  assert_eq(cleans.val, 0)
  assert_eq(received.length(), 1)
  assert_eq(received[0], 1)
  assert_eq(active.length(), 1)

  update_subs(sub_a, active, fn(msg) { received.push(msg) })
  assert_eq(starts.val, 1)
  assert_eq(cleans.val, 0)
  assert_eq(active.length(), 1)

  let none : Sub[Int] = Sub::none()
  update_subs(none, active, fn(_msg) {  })
  assert_eq(cleans.val, 1)
  assert_eq(active.length(), 0)
}

///|
test "update_subs handles multiple keys and selective removal" {
  let cleaned_a = Ref::new(0)
  let cleaned_b = Ref::new(0)
  let active : Map[String, ActiveSub] = {}

  let first : Sub[Unit] = Sub::batch([
    Sub::sub("a", fn(_dispatch) { fn() { cleaned_a.val += 1 } }),
    Sub::sub("b", fn(_dispatch) { fn() { cleaned_b.val += 1 } }),
  ])
  update_subs(first, active, fn(_msg) {  })
  assert_eq(active.length(), 2)

  let keep_b : Sub[Unit] = Sub::sub("b", fn(_dispatch) {
    fn() { cleaned_b.val += 10 }
  })
  update_subs(keep_b, active, fn(_msg) {  })
  assert_eq(active.length(), 1)
  assert_eq(cleaned_a.val, 1)
  assert_eq(cleaned_b.val, 0)

  let none : Sub[Unit] = Sub::none()
  update_subs(none, active, fn(_msg) {  })
  assert_eq(active.length(), 0)
  assert_eq(cleaned_b.val, 1)
}
