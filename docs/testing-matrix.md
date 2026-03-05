# Testing Matrix

This project uses layered testing:

- White-box unit tests (`*_wbtest.mbt`) for runtime internals and deterministic logic.
- Playwright specs (`tests/*.spec.ts`) as browser-level smoke/integration coverage.

## Unit Coverage by Module

| Module | Unit Test File(s) | Focus |
| --- | --- | --- |
| `cmd.mbt` | `cmd_wbtest.mbt` | Command composition, mapping, handle send, HTTP error extraction fallback |
| `sub.mbt` | `sub_wbtest.mbt` | Subscription composition, mapping, lifecycle cleanup semantics |
| `attr.mbt` + `vnode.mbt` | `attr_vnode_wbtest.mbt` | Event/value decoding, attr mapping, vnode mapping, keyed wrappers |
| `nav.mbt` | `nav_wbtest.mbt` | Path parsing and SPA click interception rules |
| `diff.mbt` | `diff_wbtest.mbt` | Keyed/non-keyed mode classification and duplicate-key/mode-switch guard logic |
| `component.mbt` | `component_wbtest.mbt` | Slot reuse, handle lifecycle, init command draining |
| `app.mbt` | `app_wbtest.mbt` | Subscription orchestration and cleanup behavior |

Shared JS fixture helpers live in `unit_test_harness_wbtest.mbt`.

## Regression Mapping

| Issue | Coverage |
| --- | --- |
| `chai-2oa` duplicate keyed children corruption | `diff_wbtest.mbt` (`first_duplicate_key detects duplicate keyed children`) + Playwright regression spec |
| `chai-zfb` keyed/non-keyed mode switch stale DOM | `diff_wbtest.mbt` (`should_replace_children_on_mode_switch...`) + Playwright regression spec |
| `chai-3zq` unmounted handle retained dispatch | `component_wbtest.mbt` (`removing unused component slot disconnects handle dispatch`) |
| `chai-ezb` SPA link modified-click behavior | `nav_wbtest.mbt` (`should_intercept_link_click...`, `link emits EventMaybe...`) |
| HTTP nullish rejection reason robustness | `cmd_wbtest.mbt` (`error_message handles nullish reasons`) |

## Local Commands

```bash
moon check --target js
moon test -v
cd tests && npm test
```
