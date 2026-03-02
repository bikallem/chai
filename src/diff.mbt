///|
fn get_child(parent : @webapi.Node, index : Int) -> @webapi.Node {
  parent.child_nodes().item(index.reinterpret_as_uint())
}

///|
/// Set a DOM Level 0 event handler (e.g., el.onclick = fn)
extern "js" fn set_event_handler_ffi(
  el : @webapi.JsValue,
  name : String,
  handler : (@webapi.Event) -> Unit,
) -> Unit = "(el, name, handler) => { el['on' + name] = handler; }"

///|
/// Remove a DOM Level 0 event handler (e.g., el.onclick = null)
extern "js" fn remove_event_handler_ffi(
  el : @webapi.JsValue,
  name : String,
) -> Unit = "(el, name) => { el['on' + name] = null; }"

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
  let js_el = @webapi.TJsValue::to_js(el)
  for attr in attrs {
    match attr {
      Attribute(name, val) => apply_attribute(el, name, val)
      Event(name, handler) =>
        set_event_handler_ffi(js_el, name, fn(e) { dispatch(handler(e)) })
      BoundEvent(name, handler) => set_event_handler_ffi(js_el, name, handler)
      Style(name, val) => {
        let html_el : @webapi.HTMLElement = js_el.into()
        html_el.style().set_property(name, val)
      }
    }
  }
}

///|
fn as_input(el : @webapi.Element) -> @webapi.HTMLInputElement {
  @webapi.TJsValue::to_js(el).into()
}

///|
/// Apply an attribute, using typed webapi setters for DOM properties
fn apply_attribute(el : @webapi.Element, name : String, val : String) -> Unit {
  if name == "value" {
    as_input(el).set_value(val)
  } else if name == "checked" {
    as_input(el).set_checked(val == "true")
  } else if name == "disabled" {
    as_input(el).set_disabled(val == "true")
  } else {
    el.set_attribute(name, val)
  }
}

///|
/// Remove an attribute, using typed webapi setters to clear DOM properties
fn remove_attribute_value(el : @webapi.Element, name : String) -> Unit {
  if name == "value" {
    as_input(el).set_value("")
  } else if name == "checked" {
    as_input(el).set_checked(false)
  } else if name == "disabled" {
    as_input(el).set_disabled(false)
  } else {
    el.remove_attribute(name)
  }
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
/// Diff children using sequential index-based comparison
fn[Msg] diff_children(
  parent : @webapi.Node,
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  // Detect keyed mode from new children
  if new_children.length() > 0 {
    match new_children[0] {
      Keyed(_) => {
        diff_children_keyed(parent, old_children, new_children, dispatch)
        return
      }
      _ => ()
    }
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
  // Track which old indices are reused
  let used : Array[Bool] = []
  for i = 0; i < old_len; i = i + 1 {
    used.push(false)
  }
  // Process new children left to right
  for i = 0; i < new_len; i = i + 1 {
    match new_children[i] {
      Keyed(new_key, new_inner) =>
        match old_key_map.get(new_key) {
          Some((old_idx, old_inner)) => {
            used[old_idx] = true
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
  // Remove unused old nodes
  for i = 0; i < old_len; i = i + 1 {
    if not(used[i]) {
      parent.remove_child(old_dom[i]) |> ignore
    }
  }
}

///|
/// Diff attributes between old and new vnodes
fn[Msg] diff_attrs(
  el : @webapi.Element,
  old_attrs : Array[Attr[Msg]],
  new_attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  let js_el = @webapi.TJsValue::to_js(el)
  // Build maps of old attributes for diffing
  let old_attributes : Map[String, String] = {}
  let old_events : @hashset.HashSet[String] = @hashset.new()
  let old_styles : Map[String, String] = {}
  for attr in old_attrs {
    match attr {
      Attribute(k, v) => old_attributes[k] = v
      Event(name, _) => old_events.add(name)
      BoundEvent(name, _) => old_events.add(name)
      Style(k, v) => old_styles[k] = v
    }
  }
  // Track which old attrs are still present
  let new_attribute_keys : @hashset.HashSet[String] = @hashset.new()
  let new_event_keys : @hashset.HashSet[String] = @hashset.new()
  let new_style_keys : @hashset.HashSet[String] = @hashset.new()
  // Apply new attributes
  for attr in new_attrs {
    match attr {
      Attribute(name, value) => {
        new_attribute_keys.add(name)
        match old_attributes.get(name) {
          Some(old_val) =>
            if old_val != value {
              apply_attribute(el, name, value)
            }
          None => apply_attribute(el, name, value)
        }
      }
      Event(name, handler) => {
        // Always replace event handlers (closures are not comparable)
        new_event_keys.add(name)
        set_event_handler_ffi(js_el, name, fn(e) { dispatch(handler(e)) })
      }
      BoundEvent(name, handler) => {
        new_event_keys.add(name)
        set_event_handler_ffi(js_el, name, handler)
      }
      Style(name, value) => {
        new_style_keys.add(name)
        if old_styles.get(name) != Some(value) {
          let html_el : @webapi.HTMLElement = js_el.into()
          html_el.style().set_property(name, value)
        }
      }
    }
  }
  // Remove old attributes that are no longer present
  old_attributes.each(fn(k, _v) {
    if not(new_attribute_keys.contains(k)) {
      remove_attribute_value(el, k)
    }
  })
  old_events.each(fn(k) {
    if not(new_event_keys.contains(k)) {
      remove_event_handler_ffi(js_el, k)
    }
  })
  old_styles.each(fn(k, _v) {
    if not(new_style_keys.contains(k)) {
      let html_el : @webapi.HTMLElement = js_el.into()
      html_el.style().remove_property(k) |> ignore
    }
  })
}
