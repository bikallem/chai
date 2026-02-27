///|
fn get_child(parent : @webapi.Node, index : Int) -> @webapi.Node {
  parent.child_nodes().item(index.reinterpret_as_uint()).unwrap()
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
    Embed(comp) => (comp.mount)()
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
      Style(name, val) => {
        let html_el : @webapi.HTMLElement = js_el.into()
        html_el.style().set_property(name, val)
      }
    }
  }
}

///|
/// Apply an attribute, using typed webapi setters for DOM properties
fn apply_attribute(el : @webapi.Element, name : String, val : String) -> Unit {
  if name == "value" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_value(val)
  } else if name == "checked" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_checked(val == "true")
  } else if name == "disabled" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_disabled(val == "true")
  } else {
    el.set_attribute(name, val)
  }
}

///|
/// Remove an attribute, using typed webapi setters to clear DOM properties
fn remove_attribute_value(el : @webapi.Element, name : String) -> Unit {
  if name == "value" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_value("")
  } else if name == "checked" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_checked(false)
  } else if name == "disabled" {
    let input : @webapi.HTMLInputElement = @webapi.TJsValue::to_js(el).into()
    input.set_disabled(false)
  } else {
    el.remove_attribute(name)
  }
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
        let new_node = create_dom_node(
          Element(new_tag, new_attrs, new_children),
          dispatch,
        )
        let old_node = get_child(parent, index)
        parent.replace_child(new_node, old_node) |> ignore
      }
    (Embed(old_comp), Embed(new_comp)) =>
      if old_comp.props_fingerprint == new_comp.props_fingerprint {
        // Same component, same props — keep existing instance
        ()
      } else {
        let new_node = (new_comp.mount)()
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
  let old_events : Map[String, Bool] = {}
  let old_styles : Map[String, String] = {}
  for attr in old_attrs {
    match attr {
      Attribute(k, v) => old_attributes[k] = v
      Event(name, _) => old_events[name] = true
      Style(k, v) => old_styles[k] = v
    }
  }
  // Track which old attrs are still present
  let new_attribute_keys : Map[String, Bool] = {}
  let new_event_keys : Map[String, Bool] = {}
  let new_style_keys : Map[String, Bool] = {}
  // Apply new attributes
  for attr in new_attrs {
    match attr {
      Attribute(name, value) => {
        new_attribute_keys[name] = true
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
        new_event_keys[name] = true
        set_event_handler_ffi(js_el, name, fn(e) { dispatch(handler(e)) })
      }
      Style(name, value) => {
        new_style_keys[name] = true
        match old_styles.get(name) {
          Some(old_val) =>
            if old_val != value {
              let html_el : @webapi.HTMLElement = js_el.into()
              html_el.style().set_property(name, value)
            }
          None => {
            let html_el : @webapi.HTMLElement = js_el.into()
            html_el.style().set_property(name, value)
          }
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
  old_events.each(fn(k, _v) {
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
