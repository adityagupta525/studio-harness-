#!/usr/bin/env bash
# Self-tests for the validators: builds a FICTIONAL channel-launch fixture in a temporary directory
# (never in the repo), mutates copies, and checks that check-channel-plan.sh and check-source-ledger.sh
# accept what they should (including the literal word "viral" in a title, quote, name or URL, and
# properly tagged claims) and reject what they should (untagged or malformed virality and performance
# claims, and every other Channel Launch gate).
# Usage: scripts/test-validators.sh [-v]     -v lists every passing case
# Needs: bash, python3 (standard library only). Exit 0 = all behaved as expected, 1 = a miss.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 not found"; exit 2; }
exec python3 -I scripts/tests/validator_tests.py "$@"
