///|
/// Active subscription with its cleanup function.
priv struct ActiveSub {
  identity : String
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
  let root_el = @webapi.document().query_selector_opt(selector)
  guard root_el is Some(el) else {
    abort("chai: no element matches selector \"" + selector + "\"")
  }
  let root_node : @webapi.Node = @webapi.TJsValue::to_js(el).into()
  let runtime = new_component_runtime()
  let active_subs : Map[String, ActiveSub] = {}
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
    begin_render_pass_for(runtime)
    let new_vdom = with_component_runtime(runtime, fn() { view(state.val) })
    diff(runtime, root_node, 0, current_vdom.val, new_vdom, dispatch)
    current_vdom.val = new_vdom
    remove_unused_component_slots_for(runtime)
    drain_pending_init_cmds_for(runtime)
    update_subs(subscriptions(state.val), active_subs, dispatch)
  }

  fn process_queue() -> Unit {
    if is_updating.val {
      return
    }
    is_updating.val = true
    while msg_queue.length() > 0 || needs_render.val {
      for cursor = 0; cursor < msg_queue.length(); cursor = cursor + 1 {
        let msg = msg_queue[cursor]
        let (new_model, cmd) = update(state.val, msg)
        state.val = new_model
        cmd.run(dispatch)
      }
      msg_queue.clear()
      needs_render.val = false
      do_render()
    }
    is_updating.val = false
  }

  dispatch_ref.val = fn(msg) {
    msg_queue.push(msg)
    process_queue()
  }
  runtime.trigger_render.val = fn() {
    needs_render.val = true
    process_queue()
  }
  reset_component_state_for(runtime)
  let initial_vdom = with_component_runtime(runtime, fn() { view(init_model) })
  replace_children(runtime, root_node, [initial_vdom], dispatch)
  current_vdom.val = initial_vdom
  drain_pending_init_cmds_for(runtime)
  init_cmd.run(dispatch)
  update_subs(subscriptions(init_model), active_subs, dispatch)
}

///|
/// Update active subscriptions based on new subscription definitions
fn[Msg] update_subs(
  new_sub : Sub[Msg],
  active_subs : Map[String, ActiveSub],
  dispatch : (Msg) -> Unit,
) -> Unit {
  if new_sub.subs.length() == 0 && active_subs.length() == 0 {
    return
  }
  let new_keys : @hashset.HashSet[String] = @hashset.new()
  for sd in new_sub.subs {
    new_keys.add(sd.key)
    match active_subs.get(sd.key) {
      Some(active) =>
        if active.identity != sd.identity {
          (active.cleanup)()
          active_subs[sd.key] = {
            identity: sd.identity,
            cleanup: (sd.start)(dispatch),
          }
        }
      None =>
        active_subs[sd.key] = {
          identity: sd.identity,
          cleanup: (sd.start)(dispatch),
        }
    }
  }
  let to_remove : Array[String] = []
  active_subs.each(fn(k, _v) {
    if not(new_keys.contains(k)) {
      to_remove.push(k)
    }
  })
  for key in to_remove {
    match active_subs.get(key) {
      Some(sub) => (sub.cleanup)()
      None => ()
    }
    active_subs.remove(key)
  }
}
