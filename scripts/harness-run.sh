#!/usr/bin/env bash
# harness-run.sh: kept for old docs; use bin/studio-harness (new | use | show | check | init | doctor).
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/studio-harness" "$@"
