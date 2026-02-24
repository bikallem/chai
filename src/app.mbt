///|
/// Active subscription with its cleanup function
priv struct ActiveSub {
  cleanup : () -> Unit
}

///|
/// Start a TEA application
pub fn[Model, Msg] start(
  init~ : () -> (Model, Cmd[Msg]),
  update~ : (Model, Msg) -> (Model, Cmd[Msg]),
  view~ : (Model) -> VNode[Msg],
  subscriptions~ : (Model) -> Sub[Msg],
  selector~ : String,
) -> Unit {
  // Get root element
  let root_el = @webapi.document.query_selector(selector)
  guard root_el is Some(el) else { return }
  let root_node = jsvalue_to_node(@webapi.TJsValue::to_js(el))
  // Mutable state
  let state : Ref[Model] = match init() {
    (m, _) => Ref::new(m)
  }
  let current_vdom : Ref[VNode[Msg]] = Ref::new(Text(""))
  let msg_queue : Array[Msg] = []
  let is_updating : Ref[Bool] = Ref::new(false)
  let active_subs : Map[String, ActiveSub] = {}
  // Forward declare dispatch
  let dispatch_ref : Ref[(Msg) -> Unit] = Ref::new(fn(_msg) {  })
  fn dispatch(msg : Msg) -> Unit {
    (dispatch_ref.val)(msg)
  }

  fn process_queue() -> Unit {
    if is_updating.val {
      return
    }
    is_updating.val = true
    while msg_queue.length() > 0 {
      let msg = msg_queue.remove(0)
      let (new_model, cmd) = update(state.val, msg)
      state.val = new_model
      // Render
      let new_vdom = view(new_model)
      diff(root_node, 0, current_vdom.val, new_vdom, dispatch)
      current_vdom.val = new_vdom
      // Execute commands
      for task in cmd.tasks {
        task(dispatch)
      }
      // Update subscriptions
      update_subs(subscriptions(new_model), active_subs, dispatch)
    }
    is_updating.val = false
  }

  dispatch_ref.val = fn(msg) {
    msg_queue.push(msg)
    process_queue()
  }
  // Initial render
  let (init_model, init_cmd) = init()
  state.val = init_model
  let initial_vdom = view(init_model)
  let dom_node = create_dom_node(initial_vdom, dispatch)
  root_node.append_child(dom_node) |> ignore
  current_vdom.val = initial_vdom
  // Execute initial commands
  for task in init_cmd.tasks {
    task(dispatch)
  }
  // Start initial subscriptions
  update_subs(subscriptions(init_model), active_subs, dispatch)
}

///|
/// Update active subscriptions based on new subscription definitions
fn[Msg] update_subs(
  new_sub : Sub[Msg],
  active_subs : Map[String, ActiveSub],
  dispatch : (Msg) -> Unit,
) -> Unit {
  // Collect new sub keys
  let new_keys : Map[String, Bool] = {}
  for sd in new_sub.subs {
    new_keys[sd.key] = true
    // Start new subscriptions that aren't already active
    if not(active_subs.contains(sd.key)) {
      let cleanup = (sd.start)(dispatch)
      active_subs[sd.key] = { cleanup, }
    }
  }
  // Stop subscriptions that are no longer present
  let to_remove : Array[String] = []
  active_subs.each(fn(k, _v) {
    if not(new_keys.contains(k)) {
      to_remove.push(k)
    }
  })
  for key in to_remove {
    match active_subs.get(key) {
      Some(sub) => {
        (sub.cleanup)()
        active_subs.remove(key)
      }
      None => ()
    }
  }
}
