#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLES_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$EXAMPLES_DIR/_build/js/release/build/examples"
PUBLIC_EXAMPLES="$SCRIPT_DIR/public/examples"

# Build moonbit examples (JS target)
echo "Building MoonBit examples..."
(cd "$EXAMPLES_DIR" && moon build --target js --release)

# Copy built JS files into public/examples/
examples=(todo counters clock router fetch canvas)
for name in "${examples[@]}"; do
    src="$BUILD_DIR/$name/$name.js"
    if [ -f "$src" ]; then
        cp "$src" "$PUBLIC_EXAMPLES/$name.js"
        echo "  copied $name.js"
    else
        echo "  WARNING: $src not found" >&2
    fi
done

# Install deps and build Vite app
echo "Building showcase..."
(cd "$SCRIPT_DIR" && npm install && npm run build)

echo "Done. Output in $SCRIPT_DIR/dist/"
