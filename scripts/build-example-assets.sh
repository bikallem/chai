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
done
