#!/usr/bin/env bash
set -euo pipefail

./scripts/test-unit.sh
(cd tests && npm test)
