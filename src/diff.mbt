// Type cast FFIs: webapi has no Text -> Node or Node -> Element conversion.
// Child access FFI: published webapi 0.3.0 lacks NodeList.item().

///|
extern "js" fn jsvalue_to_node(v : @webapi.JsValue) -> @webapi.Node = "(v) => v"

///|
extern "js" fn jsvalue_to_element(v : @webapi.JsValue) -> @webapi.Element = "(v) => v"

///|
extern "js" fn get_child_node_ffi(
  parent : @webapi.JsValue,
  index : Int,
) -> @webapi.Node = "(parent, index) => parent.childNodes[index]"

///|
fn get_child(parent : @webapi.Node, index : Int) -> @webapi.Node {
  get_child_node_ffi(@webapi.TJsValue::to_js(parent), index)
}

///|
/// Create a real DOM node from a virtual node
pub fn[Msg] create_dom_node(
  vnode : VNode[Msg],
  dispatch : (Msg) -> Unit,
) -> @webapi.Node {
  match vnode {
    Text(s) => {
      let text_node = @webapi.document.create_text_node(s)
      jsvalue_to_node(@webapi.TJsValue::to_js(text_node))
    }
    Element(tag, attrs, children) => {
      let el = @webapi.document.create_element(tag)
      apply_attrs(el, attrs, dispatch)
      let el_node = jsvalue_to_node(@webapi.TJsValue::to_js(el))
      for child in children {
        let child_node = create_dom_node(child, dispatch)
        el_node.append_child(child_node) |> ignore
      }
      el_node
    }
  }
}

///|
/// Apply attributes, properties, events, and styles to an element
fn[Msg] apply_attrs(
  el : @webapi.Element,
  attrs : Array[Attr[Msg]],
  dispatch : (Msg) -> Unit,
) -> Unit {
  let js_el = @webapi.TJsValue::to_js(el)
  for attr in attrs {
    match attr {
      Attribute(name, value) => el.set_attribute(name, value)
      Property(name, value) => set_property_ffi(js_el, name, value)
      BoolProperty(name, value) => set_bool_property_ffi(js_el, name, value)
      Event(name, handler) =>
        set_event_handler_ffi(js_el, name, fn(e) { dispatch(handler(e)) })
      Style(name, value) => set_style_ffi(js_el, name, value)
    }
  }
}

///|
/// Diff and patch the DOM in a single pass
pub fn[Msg] diff(
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
        let el = jsvalue_to_element(@webapi.TJsValue::to_js(child))
        diff_attrs(el, old_attrs, new_attrs, dispatch)
        diff_children(child, old_children, new_children, dispatch)
      } else {
        let new_node = create_dom_node(
          Element(new_tag, new_attrs, new_children),
          dispatch,
        )
        let old_node = get_child(parent, index)
        parent.replace_child(new_node, old_node) |> ignore
      }
    _ => {
      let new_node = create_dom_node(new_, dispatch)
      let old_node = get_child(parent, index)
      parent.replace_child(new_node, old_node) |> ignore
    }
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
  let old_properties : Map[String, String] = {}
  let old_bool_properties : Map[String, Bool] = {}
  let old_events : Map[String, Bool] = {}
  let old_styles : Map[String, String] = {}
  for attr in old_attrs {
    match attr {
      Attribute(k, v) => old_attributes[k] = v
      Property(k, v) => old_properties[k] = v
      BoolProperty(k, v) => old_bool_properties[k] = v
      Event(name, _) => old_events[name] = true
      Style(k, v) => old_styles[k] = v
    }
  }
  // Track which old attrs are still present
  let new_attribute_keys : Map[String, Bool] = {}
  let new_property_keys : Map[String, Bool] = {}
  let new_bool_property_keys : Map[String, Bool] = {}
  let new_event_keys : Map[String, Bool] = {}
  let new_style_keys : Map[String, Bool] = {}
  // Apply new attributes
  for attr in new_attrs {
    match attr {
      Attribute(name, value) => {
        new_attribute_keys[name] = true
        match old_attributes.get(name) {
          Some(old_val) => if old_val != value { el.set_attribute(name, value) }
          None => el.set_attribute(name, value)
        }
      }
      Property(name, value) => {
        new_property_keys[name] = true
        match old_properties.get(name) {
          Some(old_val) =>
            if old_val != value {
              set_property_ffi(js_el, name, value)
            }
          None => set_property_ffi(js_el, name, value)
        }
      }
      BoolProperty(name, value) => {
        new_bool_property_keys[name] = true
        match old_bool_properties.get(name) {
          Some(old_val) =>
            if old_val != value {
              set_bool_property_ffi(js_el, name, value)
            }
          None => set_bool_property_ffi(js_el, name, value)
        }
      }
      Event(name, handler) => {
        // Always replace event handlers (closures are not comparable)
        new_event_keys[name] = true
        set_event_handler_ffi(js_el, name, fn(e) { dispatch(handler(e)) })
      }
      Style(name, value) => {
        new_style_keys[name] = true
        match old_styles.get(name) {
          Some(old_val) =>
            if old_val != value {
              set_style_ffi(js_el, name, value)
            }
          None => set_style_ffi(js_el, name, value)
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
  old_properties.each(fn(k, _v) {
    if not(new_property_keys.contains(k)) {
      set_property_ffi(js_el, k, "")
    }
  })
  old_bool_properties.each(fn(k, _v) {
    if not(new_bool_property_keys.contains(k)) {
      set_bool_property_ffi(js_el, k, false)
    }
  })
  old_events.each(fn(k, _v) {
    if not(new_event_keys.contains(k)) {
      remove_event_handler_ffi(js_el, k)
    }
  })
  old_styles.each(fn(k, _v) {
    if not(new_style_keys.contains(k)) {
      remove_style_ffi(js_el, k)
    }
  })
}
