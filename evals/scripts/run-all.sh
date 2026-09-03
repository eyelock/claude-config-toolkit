#!/bin/bash
# Runs every evals/scripts/test-*.sh (script unit tests + fixture-based grader tests).
# No LLM calls, no network — safe and free to run anywhere, including every CI run.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOTAL=0
FAILED=0
FAILED_NAMES=()

for test_file in "$SCRIPT_DIR"/test-*.sh; do
  [ -f "$test_file" ] || continue
  TOTAL=$((TOTAL + 1))
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if ! bash "$test_file"; then
    FAILED=$((FAILED + 1))
    FAILED_NAMES+=("$(basename "$test_file")")
  fi
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$((TOTAL - FAILED))/$TOTAL test files passed"

if [ "$FAILED" -gt 0 ]; then
  echo "Failed: ${FAILED_NAMES[*]}"
  exit 1
fi
exit 0
