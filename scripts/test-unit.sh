#!/usr/bin/env bash
set -euo pipefail

moon check --target js
moon test -v
