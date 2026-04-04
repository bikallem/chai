///|
let svg_ns : String = "http://www.w3.org/2000/svg"

///|
fn node_first_child(n : @webapi.Node) -> @webapi.Node? {
  if n.has_child_nodes() {
    Some(n.first_child())
  } else {
    None
  }
}

///|
fn node_last_child(n : @webapi.Node) -> @webapi.Node? {
  if n.has_child_nodes() {
    Some(n.last_child())
  } else {
    None
  }
}

///|
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
    Fragment(children) => {
      let frag = @webapi.document().create_document_fragment()
      let frag_node : @webapi.Node = @webapi.TJsValue::to_js(frag).unsafe_into()
      for child in children {
        frag_node.append_child(create_dom_node(runtime, child, dispatch, ns))
        |> ignore
      }
      frag_node
    }
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
    // Type mismatch: old and new are different VNode variants — full replace.
    // Enumerating all old variants ensures a new VNode variant triggers a
    // compile error here instead of silently falling through.
    (Null, _)
    | (Text(_), _)
    | (Element(_, _, _), _)
    | (Component(_), _)
    | (Keyed(_, _), _)
    | (Lazy(_, _), _)
    | (Fragment(_), _) => {
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
  for i, child in children {
    if i > 0 && (child is Keyed(_, _)) != first_is_keyed {
      abort(
        "chai: " +
        label +
        " mix Keyed and non-Keyed vnodes. Wrap all siblings with keyed() or none.",
      )
    }
  }
  match first_is_keyed {
    true => AllKeyed
    false => NonKeyed
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
/// Remove all child nodes from a parent by setting textContent to empty string.
fn clear_children(parent : @webapi.Node) -> Unit {
  let obj : @webapi.JsObject = @webapi.TJsValue::to_js(parent).unsafe_into()
  obj.set("textContent", @webapi.TJsValue::to_js("")) |> ignore
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
  let old_children = flatten_children(old_children)
  let new_children = flatten_children(new_children)
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
  // Fast path: clear all children at once
  if new_len == 0 {
    if old_len > 0 {
      clear_children(parent)
    }
    return
  }
  let min_len = @cmp.minimum(old_len, new_len)
  // Patch common prefix using sibling cursor
  for i = 0, cursor = node_first_child(parent); i < min_len; {
    guard cursor is Some(node) else { break }
    let next = node_next_sibling(node)
    diff(runtime, parent, node, old_children[i], new_children[i], dispatch, ns)
    continue i + 1, next
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
  let result : @hashset.HashSet[Int] = @hashset.new()
  if arr.length() == 0 {
    return result
  }
  // tails[i] = smallest tail element of all increasing subsequences of length i+1
  let tails : Array[Int] = []
  // indices[i] = index in arr of tails[i]
  let indices : Array[Int] = []
  // parent[i] = index in arr of predecessor of arr[i] in the LIS
  let parent : Array[Int] = Array::make(arr.length(), -1)
  for i, x in arr {
    if x < 0 {
      continue
    }
    // Binary search for the leftmost tail >= x
    let lo = for lo = 0, hi = tails.length(); lo < hi; {
      let mid = (lo + hi) / 2
      if tails[mid] < x {
        continue mid + 1, hi
      } else {
        continue lo, mid
      }
    } nobreak {
      lo
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
  for _j = tails.length(), k = indices[indices.length() - 1]; _j > 0; {
    result.add(k)
    continue _j - 1, parent[k]
  }
  result
}

///|
fn insert_node(
  parent : @webapi.Node,
  node : @webapi.Node,
  before : @webapi.Node?,
) -> Unit {
  match before {
    Some(ref_) => parent.insert_before(node, ref_) |> ignore
    None => parent.append_child(node) |> ignore
  }
}

///|
/// Diff children using key-based reconciliation with LIS optimization.
/// Each child must be a Keyed(key, vnode) wrapper. Matches old and new
/// children by key, uses LIS to minimize DOM moves, and removes unused ones.
/// Uses a common-prefix scan to avoid HashMap/LIS overhead when key order is
/// stable (the common case for select, partial update, append, etc.).
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
  // Fast path: clear all children
  if new_len == 0 {
    if old_len > 0 {
      clear_children(parent)
    }
    return
  }
  // Fast path: all new children (empty old)
  if old_len == 0 {
    for child in new_children {
      guard child is Keyed(_, inner) else { continue }
      parent.append_child(create_dom_node(runtime, inner, dispatch, ns))
      |> ignore
    }
    return
  }
  // Common prefix: diff matching keys from the start, walking the DOM cursor
  let min_len = @cmp.minimum(old_len, new_len)
  let (prefix_len, prefix_cursor) = for i = 0, cursor = node_first_child(parent); i <
                                       min_len; {
    guard cursor is Some(node) else { break (i, cursor) }
    guard old_children[i] is Keyed(old_key, old_inner) else {
      break (i, cursor)
    }
    guard new_children[i] is Keyed(new_key, new_inner) else {
      break (i, cursor)
    }
    if old_key != new_key {
      break (i, Some(node))
    }
    let next = node_next_sibling(node)
    diff(runtime, parent, node, old_inner, new_inner, dispatch, ns)
    continue i + 1, next
  } nobreak {
    (min_len, cursor)
  }
  // All keys matched in prefix — handle tail
  if prefix_len == old_len && prefix_len == new_len {
    return
  }
  // Only old tail remains — remove extras
  if prefix_len == new_len {
    for _i = prefix_len, cursor = prefix_cursor; _i < old_len; {
      guard cursor is Some(node) else { break }
      let next = node_next_sibling(node)
      parent.remove_child(node) |> ignore
      continue _i + 1, next
    }
    return
  }
  // Only new tail remains — append extras
  if prefix_len == old_len {
    for i = prefix_len; i < new_len; i = i + 1 {
      guard new_children[i] is Keyed(_, inner) else { continue }
      parent.append_child(create_dom_node(runtime, inner, dispatch, ns))
      |> ignore
    }
    return
  }
  // General case: build HashMap/LIS for remaining items after prefix
  let rem_old = old_len - prefix_len
  let rem_new = new_len - prefix_len
  let old_key_map : @hashmap.HashMap[String, (Int, VNode[Msg], @webapi.Node)] = @hashmap.new(
    capacity=rem_old,
  )
  for i = prefix_len, cursor = prefix_cursor; i < old_len; {
    guard cursor is Some(node) else { break }
    let next = node_next_sibling(node)
    guard old_children[i] is Keyed(k, inner) else { continue i + 1, next }
    old_key_map[k] = (i, inner, node)
    continue i + 1, next
  }
  let new_to_old : Array[Int] = Array::make(rem_new, -1)
  let matched : Array[(VNode[Msg], @webapi.Node)?] = Array::make(rem_new, None)
  for j = 0; j < rem_new; j = j + 1 {
    guard new_children[j + prefix_len] is Keyed(new_key, _) else { continue }
    match old_key_map.get(new_key) {
      Some((old_idx, old_inner, dom_node)) => {
        new_to_old[j] = old_idx
        matched[j] = Some((old_inner, dom_node))
        old_key_map.remove(new_key)
      }
      None => ()
    }
  }
  let lis_set = lis(new_to_old)
  old_key_map.each(fn(_k, v) { parent.remove_child(v.2) |> ignore })
  let init_next : @webapi.Node? = None
  for j = rem_new - 1, next_node = init_next; j >= 0; {
    guard new_children[j + prefix_len] is Keyed(_, new_inner) else {
      continue j - 1, next_node
    }
    match matched[j] {
      Some((old_inner, dom_node)) => {
        if !lis_set.contains(j) {
          insert_node(parent, dom_node, next_node)
        }
        diff(runtime, parent, dom_node, old_inner, new_inner, dispatch, ns)
        continue j - 1, Some(dom_node)
      }
      None => {
        let new_dom = create_dom_node(runtime, new_inner, dispatch, ns)
        insert_node(parent, new_dom, next_node)
        continue j - 1, Some(new_dom)
      }
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
    let fast_ok = for i, new_attr in new_attrs {
      if !same_attr_slot(old_attrs[i], new_attr) {
        break false
      }
      if attr_needs_update(old_attrs[i], new_attr) {
        apply_attr(el, new_attr, dispatch)
      }
    } nobreak {
      true
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
fn to_html_element(el : @webapi.Element) -> @webapi.HTMLElement {
  @webapi.TJsValue::to_js(el).unsafe_into()
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
  // Apply new attrs, skipping unchanged ones found in old
  for new_attr in new_attrs {
    let name = attr_name(new_attr)
    let kind = attr_slot_kind(new_attr)
    let found = for old_attr in old_attrs {
      if attr_name(old_attr) == name && attr_slot_kind(old_attr) == kind {
        if attr_needs_update(old_attr, new_attr) {
          apply_attr(el, new_attr, dispatch)
        }
        break true
      }
    } nobreak {
      false
    }
    if !found {
      apply_attr(el, new_attr, dispatch)
    }
  }
  // Remove old attrs not present in new
  for old_attr in old_attrs {
    let name = attr_name(old_attr)
    let kind = attr_slot_kind(old_attr)
    let found = for new_attr in new_attrs {
      if attr_name(new_attr) == name && attr_slot_kind(new_attr) == kind {
        break true
      }
    } nobreak {
      false
    }
    if !found {
      match kind {
        AttributeSlot => el.remove_attribute(name)
        PropertySlot => set_prop(el, name, @webapi.JsValue::null())
        EventSlot => remove_event_handler(el, name)
        StyleSlot => to_html_element(el).style().remove_property(name) |> ignore
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
    if !seen_keys.contains(key) {
      let name = attr_name(attr)
      match attr_slot_kind(attr) {
        AttributeSlot => el.remove_attribute(name)
        PropertySlot => set_prop(el, name, @webapi.JsValue::null())
        EventSlot => remove_event_handler(el, name)
        StyleSlot => to_html_element(el).style().remove_property(name) |> ignore
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
