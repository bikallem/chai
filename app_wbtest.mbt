///|
test "update_subs restarts custom subscriptions with the same key" {
  let starts = Ref::new(0)
  let cleans = Ref::new(0)
  let received : Array[Int] = []
  let active : Map[String, ActiveSub] = {}

  fn custom_sub(msg : Int) -> Sub[Int] {
    Sub::sub("a", fn(dispatch) {
      starts.val += 1
      dispatch(msg)
      fn() { cleans.val += 1 }
    })
  }

  update_subs(custom_sub(1), active, fn(msg) { received.push(msg) })
  assert_eq(starts.val, 1)
  assert_eq(cleans.val, 0)
  assert_eq(received.length(), 1)
  assert_eq(received[0], 1)
  assert_eq(active.length(), 1)

  update_subs(custom_sub(2), active, fn(msg) { received.push(msg) })
  assert_eq(starts.val, 2)
  assert_eq(cleans.val, 1)
  assert_eq(received.length(), 2)
  assert_eq(received[1], 2)
  assert_eq(active.length(), 1)

  let none : Sub[Int] = Sub::none()
  update_subs(none, active, fn(_msg) {  })
  assert_eq(cleans.val, 2)
  assert_eq(active.length(), 0)
}

///|
test "update_subs refreshes same-identity subscriptions in place" {
  let starts = Ref::new(0)
  let cleans = Ref::new(0)
  let received : Array[Int] = []
  let active : Map[String, ActiveSub] = {}
  let trigger : Ref[() -> Unit] = Ref::new(fn() {  })

  fn refreshable(value : Int) -> Sub[Int] {
    refreshable_sub("timer", "every:10", value, fn(dispatch, behavior_ref) {
      starts.val += 1
      trigger.val = fn() { dispatch(behavior_ref.val) }
      fn() {
        cleans.val += 1
        trigger.val = fn() {  }
      }
    })
  }

  update_subs(refreshable(1), active, fn(msg) { received.push(msg) })
  (trigger.val)()
  assert_eq(starts.val, 1)
  assert_eq(cleans.val, 0)
  assert_eq(received.length(), 1)
  assert_eq(received[0], 1)
  assert_eq(active.length(), 1)

  update_subs(refreshable(2), active, fn(msg) { received.push(msg) })
  (trigger.val)()
  assert_eq(starts.val, 1)
  assert_eq(cleans.val, 0)
  assert_eq(received.length(), 2)
  assert_eq(received[1], 2)
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
  assert_eq(cleaned_b.val, 1)

  let none : Sub[Unit] = Sub::none()
  update_subs(none, active, fn(_msg) {  })
  assert_eq(active.length(), 0)
  assert_eq(cleaned_b.val, 11)
}
