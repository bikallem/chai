///|
/// Active subscription with its cleanup function
priv struct ActiveSub {
  cleanup : () -> Unit
}

///|
/// Core TEA runtime loop. Sets up state, dispatch, message queue, and
/// initial render into the given root node.
fn[Model, Msg] boot(
  root_node : @webapi.Node,
  init : () -> (Model, Cmd[Msg]),
  update : (Model, Msg) -> (Model, Cmd[Msg]),
  view : (Model) -> VNode[Msg],
  after_update : (Model, (Msg) -> Unit) -> Unit,
) -> Unit {
  let (init_model, init_cmd) = init()
  let state : Ref[Model] = Ref::new(init_model)
  let current_vdom : Ref[VNode[Msg]] = Ref::new(Text(""))
  let msg_queue : Array[Msg] = []
  let is_updating : Ref[Bool] = Ref::new(false)
  let needs_render : Ref[Bool] = Ref::new(false)
  let dispatch_ref : Ref[(Msg) -> Unit] = Ref::new(fn(_msg) {  })
  fn dispatch(msg : Msg) -> Unit {
    (dispatch_ref.val)(msg)
  }

  fn do_render() -> Unit {
    component_counter.val = 0
    let new_vdom = view(state.val)
    diff(root_node, 0, current_vdom.val, new_vdom, dispatch)
    current_vdom.val = new_vdom
    // Process any init cmds from newly created components
    while pending_init_cmds.length() > 0 {
      let cmd_fn = pending_init_cmds.remove(0)
      cmd_fn()
    }
    after_update(state.val, dispatch)
  }

  fn process_queue() -> Unit {
    if is_updating.val {
      return
    }
    is_updating.val = true
    while msg_queue.length() > 0 || needs_render.val {
      // Process all queued messages first
      while msg_queue.length() > 0 {
        let msg = msg_queue.remove(0)
        let (new_model, cmd) = update(state.val, msg)
        state.val = new_model
        for task in cmd.tasks {
          task(dispatch)
        }
      }
      // Render once after processing messages (or if component triggered render)
      needs_render.val = false
      do_render()
    }
    is_updating.val = false
  }

  dispatch_ref.val = fn(msg) {
    msg_queue.push(msg)
    process_queue()
  }
  // Set trigger_render so components can request re-renders
  trigger_render.val = fn() {
    needs_render.val = true
    process_queue()
  }
  // Clear component state for fresh start
  component_slots.clear()
  component_counter.val = 0
  // Initial render
  let initial_vdom = view(init_model)
  let dom_node = create_dom_node(initial_vdom, dispatch)
  root_node.append_child(dom_node) |> ignore
  current_vdom.val = initial_vdom
  // Process init cmds from components created during initial render
  while pending_init_cmds.length() > 0 {
    let cmd_fn = pending_init_cmds.remove(0)
    cmd_fn()
  }
  for task in init_cmd.tasks {
    task(dispatch)
  }
  after_update(init_model, dispatch)
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
  let root_el = @webapi.document.query_selector_opt(selector)
  guard root_el is Some(el) else { return }
  let root_node : @webapi.Node = @webapi.TJsValue::to_js(el).into()
  let active_subs : Map[String, ActiveSub] = {}
  boot(root_node, init, update, view, fn(model, dispatch) {
    update_subs(subscriptions(model), active_subs, dispatch)
  })
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
