# TODO: Keyed List Diffing

## Analysis

### Current Architecture

**VNode enum** (`src/vnode.mbt`): Three variants -- `Text(String)`, `Element(String, Array[Attr[Msg]], Array[VNode[Msg]])`, and `Embed(ComponentNode)`. No notion of keys anywhere.

**diff_children** (`src/diff.mbt`): Pure positional diffing. Iterates by index over the min-length common prefix, removes excess old nodes from the end, and appends new excess nodes. No reordering, no key-matching. Inserting an item at position 0 causes every subsequent child to be diffed against the wrong old child.

**Component system** (`src/component.mbt`): Uses a global `component_counter` that resets to 0 at the start of each render. Components get identity from their call-order position. If a keyed list reorders components, the slot assignment breaks entirely.

### Key Problems to Solve

1. VNode has no place to store a key.
2. `diff_children` has no key-aware logic.
3. The component slot system derives identity from global call order, which is incompatible with reordering.
4. Keys need to flow through `VNode::map` and `bind_events` correctly.

### Design Decisions

**Approach: Add a `Keyed` variant to VNode** rather than putting keys on `Attr`. Reasons:
- Keys are not DOM attributes; they are diffing hints. Mixing them into `Attr` would pollute attribute diffing and require extracting them before attribute processing.
- A dedicated `Keyed(String, VNode[Msg])` wrapper variant is explicit, easy to pattern-match in `diff_children`, and follows the Elm approach (`Html.Keyed`).
- Alternative considered: a `keyed()` wrapper function that returns a special `Element` with a key field. This would require adding an `Option[String]` field to the `Element` variant, changing all match patterns. The wrapper variant approach is less invasive.

**Algorithm: Two-pass keyed reconciliation** in `diff_children`. When the children list contains `Keyed` nodes, switch to key-based matching (build a map of old keys to indices, then iterate new keys to find matches, detect moves, insertions, and removals). When children are all non-keyed, fall back to the existing positional algorithm. Mixing keyed and non-keyed children in the same parent should be disallowed (runtime warning or just documented).

**Component identity: Derive from key instead of call order.** Components inside `Keyed` wrappers should use a composite identity (parent key path + local position) rather than global counter position.

---

## Phase 1: VNode Key Support

### 1.1 Add Keyed variant to VNode enum
- File: src/vnode.mbt
- Add `Keyed(String, VNode[Msg])` variant to the VNode enum
- The String is the user-provided key, the VNode is the actual child node
- Keyed wraps exactly one child; it is only meaningful as a direct child of
  an Element's children array

### 1.2 Update VNode::map for Keyed
- File: src/vnode.mbt
- Add match arm: `Keyed(k, child) => Keyed(k, child.map(f))`

### 1.3 Update bind_events for Keyed
- File: src/vnode.mbt
- Add match arm: `Keyed(k, child) => Keyed(k, bind_events(child, dispatch))`

### 1.4 Add public `keyed` constructor function
- File: src/vnode.mbt
- `pub fn[Msg] keyed(key : String, child : VNode[Msg]) -> VNode[Msg]`
- Returns `Keyed(key, child)`

## Phase 2: Keyed Diff Algorithm

### 2.1 Add helper to unwrap Keyed nodes
- File: src/diff.mbt
- Helper function to extract key and inner vnode from a Keyed variant
- For non-Keyed nodes, return None for key (used in mixed-mode detection)

### 2.2 Add create_dom_node support for Keyed
- File: src/diff.mbt
- Add match arm in create_dom_node: `Keyed(_k, child) => create_dom_node(child, dispatch)`
- The key is only used during diffing, not during DOM creation

### 2.3 Add diff support for Keyed
- File: src/diff.mbt
- In the main `diff` function, add match arm for `(Keyed(_, old_child), Keyed(_, new_child))`
  that delegates to `diff(parent, index, old_child, new_child, dispatch)`
- Also handle transitions between Keyed and non-Keyed (replace node)

### 2.4 Implement diff_children_keyed
- File: src/diff.mbt
- New function: `fn[Msg] diff_children_keyed(parent, old_children, new_children, dispatch)`
- Algorithm outline:
  1. Build `old_key_map : Map[String, Int]` mapping each old child's key to its
     index in old_children
  2. Build `old_nodes : Array[Option[@webapi.Node]]` by collecting child DOM nodes
     from parent (using get_child for each index). These track which old nodes are
     still available for reuse.
  3. For each new child (iterate new_children in order):
     a. Extract the key from the Keyed wrapper
     b. Look up key in old_key_map
     c. If found: the old node exists and can be reused
        - Get the old DOM node from old_nodes, mark it as used (set to None)
        - If it's not already in the correct position, call
          parent.insert_before(old_dom_node, current_reference_node) to move it
        - Call diff() on the old and new inner vnodes to patch in place
     d. If not found: this is a new insertion
        - Call create_dom_node for the new child
        - Insert it at the correct position using insert_before (or append_child
          if at the end)
  4. After processing all new children, remove any old nodes that were not reused
     (still Some in old_nodes) via parent.remove_child()

### 2.5 Modify diff_children to detect and delegate to keyed path
- File: src/diff.mbt
- At the top of diff_children, check if children contain Keyed variants
- If the first child is Keyed, call diff_children_keyed instead
- If no children are Keyed, use existing positional algorithm
- Mixing keyed and non-keyed in the same parent is undefined behavior (document this)

## Phase 3: Component Slot Identity

### 3.1 Change component identity from global counter to path-based
- File: src/component.mbt
- Problem: component_counter resets to 0 each render and increments per
  component() call. Reordering a keyed list changes which slot ID each
  component receives.
- Solution: Replace the global counter with a path-based identity system.
  Maintain a stack/path that tracks the current position in the tree.
  Each component's identity = the full path string (e.g., "0.2.1" or
  "key:item-3.0") rather than a single incrementing integer.
- Change component_slots from Array[ComponentSlot] to Map[String, ComponentSlot]
  keyed by path string.

### 3.2 Push/pop path segments during diffing and rendering
- File: src/diff.mbt, src/app.mbt
- When diff_children iterates children, push the child index (or key for
  Keyed children) onto the path stack before recursing, pop after.
- When diff_children_keyed processes a keyed child, push the key string
  onto the path stack.
- The component() function reads the current path to form its identity.

### 3.3 Update component() to use path-based identity
- File: src/component.mbt
- Instead of `let id = component_counter.val; component_counter.val = id + 1`,
  compute identity from the current path + a local counter (for multiple
  components at the same path level).
- Look up slot in Map by path string instead of Array by index.

### 3.4 Garbage-collect unused component slots
- File: src/component.mbt, src/app.mbt
- With Map-based slots, components that are removed from the tree will leave
  stale entries. After each render, diff the set of active slot keys against
  the previous set, and clean up removed ones.
- Track "seen this render" set; after render, remove slots not seen.

## Phase 4: API Convenience

### 4.1 Add keyed list helper function
- File: src/vnode.mbt
- `pub fn[Msg] keyed_ul(attrs, children : Array[(String, VNode[Msg])]) -> VNode[Msg]`
- Wraps each (key, child) pair in Keyed and passes to ul()
- Similarly: keyed_ol, keyed_div, or a generic keyed_el(tag, attrs, pairs)
- Alternatively, a single `pub fn[Msg] keyed_list(items : Array[(String, VNode[Msg])]) -> Array[VNode[Msg]]`
  that wraps each pair, letting the user pass it to any container:
  `ul([], keyed_list(items))` -- this is more composable

### 4.2 Update exports / imports
- File: src/pkg.generated.mbti (regenerate with `moon info`)
- File: examples/*/imports.mbt - add `keyed` to `pub using @chai { ... }`

## Phase 5: Example / Validation

### 5.1 Update todo example to use keyed lists
- File: examples/todo/main.mbt
- Change `visible_todos.map(fn(t) { view_todo(t) })` to
  `keyed_list(visible_todos.map(fn(t) { (t.id.to_string(), view_todo(t)) }))`
- This ensures deleting/filtering todos reuses DOM nodes correctly

### 5.2 Add keyed-counters example
- New directory: examples/keyed-counters/
- A list of counter components that can be reordered, added, and removed
- Demonstrates that component state follows the key, not the position
- E.g., shuffle the list and verify each counter retains its count

## Implementation Notes

### DOM Operations for Moves
- `parent.insert_before(node, reference)` moves `node` before `reference`
- If `reference` is the node after the correct position, this achieves a move
- Moving a node that is already a child of parent simply relocates it (no clone needed)
- `parent.append_child(node)` moves to end if node is already a child

### Algorithm Choice
- The proposed algorithm is O(n) with a hash map, similar to React's reconciliation.
- It does NOT use longest-increasing-subsequence (LIS) optimization to minimize moves.
  LIS is a potential future optimization but adds complexity. The simple approach
  (move every out-of-place node) is correct and fast enough for typical list sizes.
- Future optimization: track which old indices are in increasing order among reused
  nodes; only move nodes that break the increasing sequence (LIS approach). This
  minimizes DOM mutations from O(n) to O(n - LIS_length).

### Key Type: String
- Keys are String, not Int, for generality. Users convert IDs to strings:
  `todo.id.to_string()`. This matches Elm and React conventions.
- String keys compose well with path-based component identity.

### Mixing Keyed and Non-Keyed
- A given parent's children array should be either all-keyed or all-non-keyed.
- The implementation detects this by checking the first child.
- Mixing is not supported and results in undefined behavior (positional fallback).
- Document this clearly.

### Component Cleanup on Key Change
- When a keyed item is removed, any component slots under that key path must be
  cleaned up (reinit closures discarded, state freed).
- When a keyed item reappears with the same key, the component should resume from
  its existing slot (state preserved across moves but not across removals).

### Critical Files
- `src/vnode.mbt` - Keyed variant, VNode::map, bind_events, keyed constructor
- `src/diff.mbt` - diff_children_keyed, create_dom_node, diff for Keyed, path tracking
- `src/component.mbt` - Path-based identity, Map-based slots, slot GC
- `src/app.mbt` - Path stack management, slot GC integration
- `examples/todo/main.mbt` - Primary test case
