///|
let svg_ns : String = "http://www.w3.org/2000/svg"

///|
#cfg(target="js")
extern "js" fn node_first_child_ffi(n : @webapi.JsValue) -> @webapi.JsValue = "(n) => n.firstChild"

///|
#cfg(target="js")
fn node_first_child(n : @webapi.Node) -> @webapi.Node? {
  let v = node_first_child_ffi(@webapi.TJsValue::to_js(n))
  if v.is_null() {
    None
  } else {
    Some(v.unsafe_into())
  }
}

///|
#cfg(target="wasm-gc")
fn node_first_child(n : @webapi.Node) -> @webapi.Node? {
  if n.has_child_nodes() {
    Some(n.first_child())
  } else {
    None
  }
}

///|
#cfg(target="js")
extern "js" fn node_last_child_ffi(n : @webapi.JsValue) -> @webapi.JsValue = "(n) => n.lastChild"

///|
#cfg(target="js")
fn node_last_child(n : @webapi.Node) -> @webapi.Node? {
  let v = node_last_child_ffi(@webapi.TJsValue::to_js(n))
  if v.is_null() {
    None
  } else {
    Some(v.unsafe_into())
  }
}

///|
#cfg(target="wasm-gc")
fn node_last_child(n : @webapi.Node) -> @webapi.Node? {
  if n.has_child_nodes() {
    Some(n.last_child())
  } else {
    None
  }
}

///|
#cfg(target="js")
extern "js" fn node_next_sibling_ffi(n : @webapi.JsValue) -> @webapi.JsValue = "(n) => n.nextSibling"

///|
#cfg(target="js")
fn node_next_sibling(n : @webapi.Node) -> @webapi.Node? {
  let v = node_next_sibling_ffi(@webapi.TJsValue::to_js(n))
  if v.is_null() {
    None
  } else {
    Some(v.unsafe_into())
  }
}

///|
#cfg(target="wasm-gc")
fn node_next_sibling(n : @webapi.Node) -> @webapi.Node? {
  let result = @webapi.TJsValue::to_js(n.next_sibling())
  if result.is_null() {
    None
  } else {
    Some(result.unsafe_into())
  }
}

///|
/// Create a real DOM node from a virtual node
fn[Msg] create_dom_node(
  runtime : ComponentRuntime,
  vnode : VNode[Msg],
  dispatch : (Msg) -> Unit,
  ns : String,
) -> @webapi.Node {
  match vnode {
    Text(s) => {
      let text_node = @webapi.document().create_text_node(s)
      @webapi.TJsValue::to_js(text_node).unsafe_into()
    }
    Element(tag, attrs, children) => {
      let child_ns = if tag == "svg" { svg_ns } else { ns }
      let el = if child_ns.length() > 0 {
        @webapi.document().create_element_ns(child_ns, tag)
      } else {
        @webapi.document().create_element(tag)
      }
      apply_attrs(el, attrs, dispatch)
      let el_node : @webapi.Node = @webapi.TJsValue::to_js(el).unsafe_into()
      for child in children {
        let child_node = create_dom_node(runtime, child, dispatch, child_ns)
        el_node.append_child(child_node) |> ignore
      }
      el_node
    }
    Component(comp) =>
      match runtime.component_slots.get(comp.id) {
        Some(slot) =>
          create_dom_node(runtime, slot.current_expanded.val, fn(_) {  }, ns)
        None => create_dom_node(runtime, Text(""), dispatch, ns)
      }
    Keyed(_k, child) => create_dom_node(runtime, child, dispatch, ns)
    Lazy(_hash, thunk) => create_dom_node(runtime, thunk(), dispatch, ns)
    Null => {
      let comment = @webapi.document().create_comment("")
      @webapi.TJsValue::to_js(comment).unsafe_into()
    }
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
    apply_attr(el, attr, dispatch)
  }
}

///|
/// Diff and patch the DOM in a single pass
fn[Msg] diff(
  runtime : ComponentRuntime,
  parent : @webapi.Node,
  child_node : @webapi.Node,
  old : VNode[Msg],
  new_ : VNode[Msg],
  dispatch : (Msg) -> Unit,
  ns : String,
) -> Unit {
  match (old, new_) {
    (Null, Null) => ()
    (Text(old_text), Text(new_text)) =>
      if old_text != new_text {
        child_node.set_node_value(new_text)
      }
    (
      Element(old_tag, old_attrs, old_children),
      Element(new_tag, new_attrs, new_children),
    ) =>
      if old_tag == new_tag {
        let el : @webapi.Element = @webapi.TJsValue::to_js(child_node).unsafe_into()
        let child_ns = if new_tag == "svg" { svg_ns } else { ns }
        diff_attrs(el, old_attrs, new_attrs, dispatch)
        diff_children(
          runtime, child_node, old_children, new_children, dispatch, child_ns,
        )
      } else {
        let new_node = create_dom_node(
          runtime,
          Element(new_tag, new_attrs, new_children),
          dispatch,
          ns,
        )
        parent.replace_child(new_node, child_node) |> ignore
      }
    (Keyed(_, old_inner), Keyed(_, new_inner)) =>
      diff(runtime, parent, child_node, old_inner, new_inner, dispatch, ns)
    (Lazy(old_hash, old_thunk), Lazy(new_hash, new_thunk)) =>
      if old_hash != new_hash {
        diff(
          runtime,
          parent,
          child_node,
          old_thunk(),
          new_thunk(),
          dispatch,
          ns,
        )
      }
    (Component(old_comp), Component(new_comp)) =>
      if old_comp.id == new_comp.id {
        match runtime.component_slots.get(new_comp.id) {
          Some(slot) =>
            diff(
              runtime,
              parent,
              child_node,
              slot.previous_expanded.val,
              slot.current_expanded.val,
              fn(_) {  },
              ns,
            )
          None => ()
        }
      } else {
        let noop : (Unit) -> Unit = fn(_) {  }
        let new_node = create_dom_node(runtime, Component(new_comp), noop, ns)
        parent.replace_child(new_node, child_node) |> ignore
      }
    _ => {
      let new_node = create_dom_node(runtime, new_, dispatch, ns)
      parent.replace_child(new_node, child_node) |> ignore
    }
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
  let first_is_keyed = children[0] is Keyed(_, _)
  for i = 1; i < children.length(); i = i + 1 {
    if (children[i] is Keyed(_, _)) != first_is_keyed {
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
fn[Msg] replace_children(
  runtime : ComponentRuntime,
  parent : @webapi.Node,
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
  ns : String,
) -> Unit {
  let old_len = parent.child_nodes().length().reinterpret_as_int()
  for i = old_len - 1; i >= 0; i = i - 1 {
    parent.remove_child(parent.child_nodes().item(i.reinterpret_as_uint()))
    |> ignore
  }
  for child in new_children {
    parent.append_child(create_dom_node(runtime, child, dispatch, ns)) |> ignore
  }
}

///|
/// Diff children using sequential comparison with sibling cursor
fn[Msg] diff_children(
  runtime : ComponentRuntime,
  parent : @webapi.Node,
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
  ns : String,
) -> Unit {
  let old_mode = child_list_mode(old_children, "old children")
  let new_mode = child_list_mode(new_children, "new children")
  let old_is_keyed = old_mode == AllKeyed
  let new_is_keyed = new_mode == AllKeyed
  if old_is_keyed != new_is_keyed && old_mode != Empty && new_mode != Empty {
    replace_children(runtime, parent, new_children, dispatch, ns)
    return
  }
  if new_is_keyed {
    diff_children_keyed(
      runtime, parent, old_children, new_children, dispatch, ns,
    )
    return
  }
  let old_len = old_children.length()
  let new_len = new_children.length()
  let min_len = @cmp.minimum(old_len, new_len)
  // Patch common prefix using sibling cursor
  let mut cursor = node_first_child(parent)
  for i = 0; i < min_len; i = i + 1 {
    guard cursor is Some(node) else { break }
    let next = node_next_sibling(node)
    diff(runtime, parent, node, old_children[i], new_children[i], dispatch, ns)
    cursor = next
  }
  // Remove extras from end
  if old_len > new_len {
    for _i = 0; _i < old_len - new_len; _i = _i + 1 {
      guard node_last_child(parent) is Some(child) else { break }
      parent.remove_child(child) |> ignore
    }
  }
  // Append new ones
  if new_len > old_len {
    for i = old_len; i < new_len; i = i + 1 {
      let new_node = create_dom_node(runtime, new_children[i], dispatch, ns)
      parent.append_child(new_node) |> ignore
    }
  }
}

///|
/// Compute the longest increasing subsequence of indices.
/// Returns indices into the input array that form the LIS.
fn lis(arr : Array[Int]) -> @hashset.HashSet[Int] {
  let n = arr.length()
  let result : @hashset.HashSet[Int] = @hashset.new()
  if n == 0 {
    return result
  }
  // tails[i] = smallest tail element of all increasing subsequences of length i+1
  let tails : Array[Int] = []
  // indices[i] = index in arr of tails[i]
  let indices : Array[Int] = []
  // parent[i] = index in arr of predecessor of arr[i] in the LIS
  let parent : Array[Int] = Array::make(n, -1)
  for i = 0; i < n; i = i + 1 {
    let x = arr[i]
    if x < 0 {
      continue i + 1
    }
    // Binary search for the leftmost tail >= x
    let mut lo = 0
    let mut hi = tails.length()
    while lo < hi {
      let mid = (lo + hi) / 2
      if tails[mid] < x {
        lo = mid + 1
      } else {
        hi = mid
      }
    }
    if lo == tails.length() {
      tails.push(x)
      indices.push(i)
    } else {
      tails[lo] = x
      indices[lo] = i
    }
    if lo > 0 {
      parent[i] = indices[lo - 1]
    }
  }
  // Trace back from the last element
  if indices.length() == 0 {
    return result
  }
  let mut k = indices[indices.length() - 1]
  for _j = tails.length(); _j > 0; _j = _j - 1 {
    result.add(k)
    k = parent[k]
  }
  result
}

///|
/// Diff children using key-based reconciliation with LIS optimization.
/// Each child must be a Keyed(key, vnode) wrapper. Matches old and new
/// children by key, uses LIS to minimize DOM moves, and removes unused ones.
fn[Msg] diff_children_keyed(
  runtime : ComponentRuntime,
  parent : @webapi.Node,
  old_children : Array[VNode[Msg]],
  new_children : Array[VNode[Msg]],
  dispatch : (Msg) -> Unit,
  ns : String,
) -> Unit {
  let old_len = old_children.length()
  let new_len = new_children.length()
  // Build old key -> (index, inner vnode, dom node) map via sibling cursor
  let old_key_map : @hashmap.HashMap[String, (Int, VNode[Msg], @webapi.Node)] = @hashmap.new()
  let mut cursor = node_first_child(parent)
  for i = 0; i < old_len; i = i + 1 {
    guard cursor is Some(node) else { break }
    let next = node_next_sibling(node)
    match old_children[i] {
      Keyed(k, inner) => old_key_map[k] = (i, inner, node)
      _ => ()
    }
    cursor = next
  }
  // Build new-to-old index mapping; -1 for new items
  // matched[i] = (old_inner, dom_node) for reused items, None for new
  let new_to_old : Array[Int] = Array::make(new_len, -1)
  let matched : Array[(VNode[Msg], @webapi.Node)?] = Array::make(new_len, None)
  for i = 0; i < new_len; i = i + 1 {
    match new_children[i] {
      Keyed(new_key, _) =>
        match old_key_map.get(new_key) {
          Some((old_idx, old_inner, dom_node)) => {
            new_to_old[i] = old_idx
            matched[i] = Some((old_inner, dom_node))
            old_key_map.remove(new_key)
          }
          None => ()
        }
      _ => ()
    }
  }
  // Compute LIS of old indices to find items that don't need moving
  let lis_set = lis(new_to_old)
  // Remove unused old nodes first
  old_key_map.each(fn(_k, v) { parent.remove_child(v.2) |> ignore })
  // Process new children right to left, using next_node as insertBefore reference
  let mut next_node : @webapi.Node? = None
  for i = new_len - 1; i >= 0; i = i - 1 {
    match new_children[i] {
      Keyed(_new_key, new_inner) =>
        match matched[i] {
          Some((old_inner, dom_node)) => {
            // Reused item: move if not in LIS
            if not(lis_set.contains(i)) {
              match next_node {
                Some(ref_) => parent.insert_before(dom_node, ref_) |> ignore
                None => parent.append_child(dom_node) |> ignore
              }
            }
            diff(runtime, parent, dom_node, old_inner, new_inner, dispatch, ns)
            next_node = Some(dom_node)
          }
          None => {
            // New item: create and insert
            let new_dom = create_dom_node(runtime, new_inner, dispatch, ns)
            match next_node {
              Some(ref_) => parent.insert_before(new_dom, ref_) |> ignore
              None => parent.append_child(new_dom) |> ignore
            }
            next_node = Some(new_dom)
          }
        }
      _ => ()
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
  if old_attrs.length() == 0 && new_attrs.length() == 0 {
    return
  }
  // Fast path: same-length attrs, apply new values directly without maps.
  // Events/properties are always re-set (not comparable), attributes/styles
  // are compared pairwise.
  if old_attrs.length() == new_attrs.length() {
    let mut fast_ok = true
    for i = 0; i < new_attrs.length() && fast_ok; i = i + 1 {
      let old_attr = old_attrs[i]
      let new_attr = new_attrs[i]
      if not(same_attr_slot(old_attr, new_attr)) {
        fast_ok = false
      } else if attr_needs_update(old_attr, new_attr) {
        apply_attr(el, new_attr, dispatch)
      }
    }
    if fast_ok {
      return
    }
  }
  // Slow path: build maps for diffing.
  // For small attr lists (< 8), use linear scan to avoid hash overhead.
  if new_attrs.length() < 8 && old_attrs.length() < 8 {
    diff_attrs_linear(el, old_attrs, new_attrs, dispatch)
    return
  }
  diff_attrs_maps(el, old_attrs, new_attrs, dispatch)
}

///|
/// Linear-scan slow path for small attr lists (< 8 elements).
/// Avoids allocating hash structures.
fn[Msg] diff_attrs_linear(
  el : @webapi.Element,
  old_attrs : Array[Attr[Msg]],
  new_attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  let html_el_ref : Ref[@webapi.HTMLElement?] = Ref::new(None)
  fn get_html_el() -> @webapi.HTMLElement {
    match html_el_ref.val {
      Some(h) => h
      None => {
        let h : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).unsafe_into()
        html_el_ref.val = Some(h)
        h
      }
    }
  }
  // Apply new attrs, skipping unchanged ones found in old
  for new_attr in new_attrs {
    let name = attr_name(new_attr)
    let kind = attr_slot_kind(new_attr)
    let mut found_old = false
    for old_attr in old_attrs {
      if attr_name(old_attr) == name && attr_slot_kind(old_attr) == kind {
        found_old = true
        if attr_needs_update(old_attr, new_attr) {
          apply_attr(el, new_attr, dispatch)
        }
        break
      }
    }
    if not(found_old) {
      apply_attr(el, new_attr, dispatch)
    }
  }
  // Remove old attrs not present in new
  for old_attr in old_attrs {
    let name = attr_name(old_attr)
    let kind = attr_slot_kind(old_attr)
    let mut found_new = false
    for new_attr in new_attrs {
      if attr_name(new_attr) == name && attr_slot_kind(new_attr) == kind {
        found_new = true
        break
      }
    }
    if not(found_new) {
      match kind {
        AttributeSlot => el.remove_attribute(name)
        PropertySlot => set_prop(el, name, @webapi.JsValue::null())
        EventSlot => remove_event_handler(el, name)
        StyleSlot => get_html_el().style().remove_property(name) |> ignore
      }
    }
  }
}

///|
/// Map-based slow path for larger attr lists.
fn[Msg] diff_attrs_maps(
  el : @webapi.Element,
  old_attrs : Array[Attr[Msg]],
  new_attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  // Build a single combined key set for tracking old attrs
  let old_keys : @hashmap.HashMap[String, Attr[Msg]] = @hashmap.new()
  for attr in old_attrs {
    let key = attr_combined_key(attr)
    old_keys[key] = attr
  }
  let seen_keys : @hashset.HashSet[String] = @hashset.new()
  let html_el_ref : Ref[@webapi.HTMLElement?] = Ref::new(None)
  fn get_html_el() -> @webapi.HTMLElement {
    match html_el_ref.val {
      Some(h) => h
      None => {
        let h : @webapi.HTMLElement = @webapi.TJsValue::to_js(el).unsafe_into()
        html_el_ref.val = Some(h)
        h
      }
    }
  }
  // Apply new attributes
  for attr in new_attrs {
    let key = attr_combined_key(attr)
    seen_keys.add(key)
    match old_keys.get(key) {
      Some(old_attr) =>
        if attr_needs_update(old_attr, attr) {
          apply_attr(el, attr, dispatch)
        }
      None => apply_attr(el, attr, dispatch)
    }
  }
  // Remove old attributes that are no longer present
  old_keys.each(fn(key, attr) {
    if not(seen_keys.contains(key)) {
      let name = attr_name(attr)
      match attr_slot_kind(attr) {
        AttributeSlot => el.remove_attribute(name)
        PropertySlot => set_prop(el, name, @webapi.JsValue::null())
        EventSlot => remove_event_handler(el, name)
        StyleSlot => get_html_el().style().remove_property(name) |> ignore
      }
    }
  })
}

///|
/// Combined key for attr dedup: prefix by slot kind to avoid collisions
/// between attributes, properties, events, and styles with the same name.
fn[Msg] attr_combined_key(attr : Attr[Msg]) -> String {
  let prefix = match attr_slot_kind(attr) {
    AttributeSlot => "a:"
    PropertySlot => "p:"
    EventSlot => "e:"
    StyleSlot => "s:"
  }
  prefix + attr_name(attr)
}
