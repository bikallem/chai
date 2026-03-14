#!/usr/bin/env bash
set -euo pipefail

packages=(
  examples/canvas
  examples/clock
  examples/counters
  examples/fetch
  examples/regressions
  examples/router
  examples/todo
)

for pkg in "${packages[@]}"; do
  moon build "$pkg" --target js --release --target-dir examples/_build
  moon build "$pkg" --target wasm-gc --release --target-dir examples/_build
done

# Copy webapi.mjs runtime next to each wasm binary
webapi_mjs=".mooncakes/bikallem/webapi/webapi.mjs"
for pkg in "${packages[@]}"; do
  wasm_dir="examples/_build/wasm-gc/release/build/${pkg}"
  cp "$webapi_mjs" "$wasm_dir/webapi.mjs"
done
