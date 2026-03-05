///|
fn get_child(parent : @webapi.Node, index : Int) -> @webapi.Node {
  parent.child_nodes().item(index.reinterpret_as_uint())
}

///|
/// Cast a closure to JsValue (on the JS target, closures are JS functions).
fn handler_to_js(handler : (@webapi.Event) -> Unit) -> @webapi.JsValue = "%identity"

///|
/// Set a DOM Level 0 event handler (e.g., el.onclick = fn)
fn set_event_handler(
  el : @webapi.Element,
  name : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit {
  set_prop(el, "on" + name, handler_to_js(handler))
}

///|
/// Remove a DOM Level 0 event handler (e.g., el.onclick = null)
fn remove_event_handler(el : @webapi.Element, name : String) -> Unit {
  set_prop(el, "on" + name, @webapi.JsValue::null())
}

///|
/// Create a real DOM node from a virtual node
fn[Msg] create_dom_node(
  vnode : VNode[Msg],
  dispatch : (Msg) -> Unit,
) -> @webapi.Node {
  match vnode {
    Text(s) => {
      let text_node = @webapi.document.create_text_node(s)
      @webapi.TJsValue::to_js(text_node).into()
    }
    Element(tag, attrs, children) => {
      let el = @webapi.document.create_element(tag)
      apply_attrs(el, attrs, dispatch)
      let el_node : @webapi.Node = @webapi.TJsValue::to_js(el).into()
      for child in children {
        let child_node = create_dom_node(child, dispatch)
        el_node.append_child(child_node) |> ignore
      }
      el_node
    }
    Component(comp) =>
      match component_slots.get(comp.id) {
        Some(slot) => create_dom_node(slot.current_expanded.val, fn(_) {  })
        None => {
          let empty : VNode[Msg] = Text("")
          create_dom_node(empty, dispatch)
        }
      }
    Keyed(_k, child) => create_dom_node(child, dispatch)
  }
}

///|
/// Apply attributes, events, and styles to an element
fn[Msg] apply_attrs(
  el : @webapi.Element,
  attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  for attr in attrs {
    match attr {
      Attribute(name, val) => el.set_attribute(name, val)
      Property(name, val) => set_prop(el, name, val)
      Event(name, handler) =>
        set_event_handler(el, name, fn(e) { dispatch(handler(e)) })
      EventMaybe(name, handler) =>
        set_event_handler(el, name, fn(e) {
          match handler(e) {
            Some(msg) => dispatch(msg)
            None => ()
          }
        })
      BoundEvent(name, handler) => set_event_handler(el, name, handler)
      Style(name, val) => {
        let html_el : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).into()
        html_el.style().set_property(name, val)
      }
    }
  }
}

///|
fn set_prop(el : @webapi.Element, name : String, val : @webapi.JsValue) -> Unit {
  let obj : @webapi.JsObject = @webapi.TJsValue::to_js(el).into()
  obj.set(name, val) |> ignore
}

///|
fn[Msg] replace_child_at(
  parent : @webapi.Node,
  index : Int,
  new_ : VNode[Msg],
  dispatch : (Msg) -> Unit,
) -> Unit {
  let new_node = create_dom_node(new_, dispatch)
  let old_node = get_child(parent, index)
  parent.replace_child(new_node, old_node) |> ignore
}

///|
/// Diff and patch the DOM in a single pass
fn[Msg] diff(
  parent : @webapi.Node,
  index : Int,
  old : VNode[Msg],
  new_ : VNode[Msg],
  dispatch : (Msg) -> Unit,
) -> Unit {
  match (old, new_) {
    (Text(old_text), Text(new_text)) =>
      if old_text != new_text {
        get_child(parent, index).set_node_value(new_text)
      }
    (
      Element(old_tag, old_attrs, old_children),
      Element(new_tag, new_attrs, new_children),
    ) =>
      if old_tag == new_tag {
        let child = get_child(parent, index)
        let el : @webapi.Element = @webapi.TJsValue::to_js(child).into()
        diff_attrs(el, old_attrs, new_attrs, dispatch)
        diff_children(child, old_children, new_children, dispatch)
      } else {
        replace_child_at(
          parent,
          index,
          Element(new_tag, new_attrs, new_children),
          dispatch,
        )
      }
    (Keyed(_, old_inner), Keyed(_, new_inner)) =>
      diff(parent, index, old_inner, new_inner, dispatch)
    (Component(old_comp), Component(new_comp)) =>
      if old_comp.id == new_comp.id {
        match component_slots.get(new_comp.id) {
          Some(slot) =>
            diff(
              parent,
              index,
              slot.previous_expanded.val,
              slot.current_expanded.val,
              fn(_) {  },
            )
          None => ()
        }
      } else {
        let noop : (Unit) -> Unit = fn(_) {  }
        replace_child_at(parent, index, Component(new_comp), noop)
      }
    _ => replace_child_at(parent, index, new_, dispatch)
  }
}

///|
priv enum ChildListMode {
  Empty
  NonKeyed
  AllKeyed
} derive(Eq)

///|
fn[Msg] child_list_mode(
  children : Array[VNode[Msg]],
  label : String,
) -> ChildListMode {
  if children.length() == 0 {
    return Empty
  }
  let first_is_keyed = match children[0] {
    Keyed(_, _) => true
    _ => false
  }
  for i = 1; i < children.length(); i = i + 1 {
    let is_keyed = match children[i] {
      Keyed(_, _) => true
      _ => false
    }
    if is_keyed != first_is_keyed {
      abort(
        "chai: " +
        label +
        " mix Keyed and non-Keyed vnodes. Wrap all siblings with keyed() or none.",
      )
    }
  }
  if first_is_keyed {
    AllKeyed
  } else {
    NonKeyed
  }
}

///|
fn[Msg] should_replace_children_on_mode_switch(
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
) -> Bool {
  let old_mode = child_list_mode(old_children, "old children")
  let new_mode = child_list_mode(new_children, "new children")
  let old_is_keyed = old_mode == AllKeyed
  let new_is_keyed = new_mode == AllKeyed
  old_is_keyed != new_is_keyed && old_mode != Empty && new_mode != Empty
}

///|
fn[Msg] first_duplicate_key(children : Array[VNode[Msg]]) -> String? {
  let seen : @hashset.HashSet[String] = @hashset.new()
  for child in children {
    match child {
      Keyed(k, _) => {
        if seen.contains(k) {
          return Some(k)
        }
        seen.add(k)
      }
      _ => ()
    }
  }
  None
}

///|
fn[Msg] replace_children(
  parent : @webapi.Node,
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  let old_len = parent.child_nodes().length().reinterpret_as_int()
  for i = old_len - 1; i >= 0; i = i - 1 {
    let child = get_child(parent, i)
    parent.remove_child(child) |> ignore
  }
  for child in new_children {
    parent.append_child(create_dom_node(child, dispatch)) |> ignore
  }
}

///|
/// Diff children using sequential index-based comparison
fn[Msg] diff_children(
  parent : @webapi.Node,
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  // If sibling mode switches between keyed and non-keyed, replace the list to
  // keep DOM order/state correct.
  if should_replace_children_on_mode_switch(old_children, new_children) {
    replace_children(parent, new_children, dispatch)
    return
  }
  let new_is_keyed = child_list_mode(new_children, "new children") == AllKeyed
  if new_is_keyed {
    diff_children_keyed(parent, old_children, new_children, dispatch)
    return
  }
  let old_len = old_children.length()
  let new_len = new_children.length()
  let min_len = if old_len < new_len { old_len } else { new_len }
  // Patch common prefix
  for i = 0; i < min_len; i = i + 1 {
    diff(parent, i, old_children[i], new_children[i], dispatch)
  }
  // Remove extras from end (backwards to preserve indices)
  if old_len > new_len {
    for i = old_len - 1; i >= new_len; i = i - 1 {
      let child = get_child(parent, i)
      parent.remove_child(child) |> ignore
    }
  }
  // Append new ones
  if new_len > old_len {
    for i = old_len; i < new_len; i = i + 1 {
      let new_node = create_dom_node(new_children[i], dispatch)
      parent.append_child(new_node) |> ignore
    }
  }
}

///|
/// Insert a node at the given child index, or append if past the end.
fn insert_at(parent : @webapi.Node, index : Int, node : @webapi.Node) -> Unit {
  if index < parent.child_nodes().length().reinterpret_as_int() {
    let ref_node = get_child(parent, index)
    if not(node.is_same_node(ref_node)) {
      parent.insert_before(node, ref_node) |> ignore
    }
  } else {
    parent.append_child(node) |> ignore
  }
}

///|
/// Diff children using key-based reconciliation. Each child must be a
/// Keyed(key, vnode) wrapper. Matches old and new children by key,
/// moves reused DOM nodes into place, and removes unused ones.
fn[Msg] diff_children_keyed(
  parent : @webapi.Node,
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  match first_duplicate_key(old_children) {
    Some(k) =>
      abort("chai: duplicate keyed child \"" + k + "\" in old children")
    None => ()
  }
  match first_duplicate_key(new_children) {
    Some(k) =>
      abort("chai: duplicate keyed child \"" + k + "\" in new children")
    None => ()
  }
  let old_len = old_children.length()
  let new_len = new_children.length()
  // Build old key -> (index, inner vnode) map
  let old_key_map : Map[String, (Int, VNode[Msg])] = {}
  for i = 0; i < old_len; i = i + 1 {
    match old_children[i] {
      Keyed(k, inner) => old_key_map[k] = (i, inner)
      _ => ()
    }
  }
  // Snapshot old DOM child nodes
  let old_dom : Array[@webapi.Node] = []
  for i = 0; i < old_len; i = i + 1 {
    old_dom.push(get_child(parent, i))
  }
  // Process new children left to right, removing matched keys from old_key_map
  for i = 0; i < new_len; i = i + 1 {
    match new_children[i] {
      Keyed(new_key, new_inner) =>
        match old_key_map.get(new_key) {
          Some((old_idx, old_inner)) => {
            old_key_map.remove(new_key)
            insert_at(parent, i, old_dom[old_idx])
            diff(parent, i, old_inner, new_inner, dispatch)
          }
          None => {
            let new_node = create_dom_node(new_inner, dispatch)
            insert_at(parent, i, new_node)
          }
        }
      _ => ()
    }
  }
  // Remove unused old nodes (those still in old_key_map)
  old_key_map.each(fn(_k, v) { parent.remove_child(old_dom[v.0]) |> ignore })
}

///|
/// Diff attributes between old and new vnodes
fn[Msg] diff_attrs(
  el : @webapi.Element,
  old_attrs : Array[Attr[Msg]],
  new_attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  if old_attrs.length() == 0 && new_attrs.length() == 0 {
    return
  }
  // Build maps of old attributes for diffing
  let old_attributes : Map[String, String] = {}
  let old_properties : @hashset.HashSet[String] = @hashset.new()
  let old_events : @hashset.HashSet[String] = @hashset.new()
  let old_styles : Map[String, String] = {}
  for attr in old_attrs {
    match attr {
      Attribute(k, v) => old_attributes[k] = v
      Property(k, _) => old_properties.add(k)
      Event(name, _) => old_events.add(name)
      EventMaybe(name, _) => old_events.add(name)
      BoundEvent(name, _) => old_events.add(name)
      Style(k, v) => old_styles[k] = v
    }
  }
  // Track which old keys are still present
  let new_attribute_keys : @hashset.HashSet[String] = @hashset.new()
  let new_property_keys : @hashset.HashSet[String] = @hashset.new()
  let new_event_keys : @hashset.HashSet[String] = @hashset.new()
  let new_style_keys : @hashset.HashSet[String] = @hashset.new()
  // Apply new attributes
  for attr in new_attrs {
    match attr {
      Attribute(name, value) => {
        new_attribute_keys.add(name)
        match old_attributes.get(name) {
          Some(old_val) => if old_val != value { el.set_attribute(name, value) }
          None => el.set_attribute(name, value)
        }
      }
      Property(name, value) => {
        // Always set properties (JsValue not comparable)
        new_property_keys.add(name)
        set_prop(el, name, value)
      }
      Event(name, handler) => {
        // Always replace event handlers (closures are not comparable)
        new_event_keys.add(name)
        set_event_handler(el, name, fn(e) { dispatch(handler(e)) })
      }
      EventMaybe(name, handler) => {
        new_event_keys.add(name)
        set_event_handler(el, name, fn(e) {
          match handler(e) {
            Some(msg) => dispatch(msg)
            None => ()
          }
        })
      }
      BoundEvent(name, handler) => {
        new_event_keys.add(name)
        set_event_handler(el, name, handler)
      }
      Style(name, value) => {
        new_style_keys.add(name)
        if old_styles.get(name) != Some(value) {
          let html_el : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).into()
          html_el.style().set_property(name, value)
        }
      }
    }
  }
  // Remove old attributes that are no longer present
  old_attributes.each(fn(k, _v) {
    if not(new_attribute_keys.contains(k)) {
      el.remove_attribute(k)
    }
  })
  old_properties.each(fn(k) {
    if not(new_property_keys.contains(k)) {
      set_prop(el, k, @webapi.JsValue::null())
    }
  })
  old_events.each(fn(k) {
    if not(new_event_keys.contains(k)) {
      remove_event_handler(el, k)
    }
  })
  old_styles.each(fn(k, _v) {
    if not(new_style_keys.contains(k)) {
      let html_el : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).into()
      html_el.style().remove_property(k) |> ignore
    }
  })
}
