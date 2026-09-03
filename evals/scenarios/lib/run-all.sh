#!/bin/bash
# Runs every LLM-in-the-loop scenario under evals/scenarios/.
#
# Auth: this script does NOT gate on ANTHROPIC_API_KEY — locally, `claude -p` authenticates
# however you normally use Claude Code (OAuth/keychain login or an API key), and this just
# tries to run. The API-key-presence skip/gate lives only in .github/workflows/ci.yml, because
# CI has no OAuth session and needs an explicit secret; that's a CI concern, not this script's.
# If `claude` can't run at all here (not installed, not logged in), run-scenario.sh's per-run
# tool check reports that clearly and the run fails loudly rather than silently skipping.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIOS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TOTAL=0
FAILED=0
FAILED_NAMES=()

for scenario in "$SCENARIOS_DIR"/*/; do
  [ -f "$scenario/prompt.md" ] || continue
  TOTAL=$((TOTAL + 1))
  if ! bash "$SCRIPT_DIR/run-scenario.sh" "${scenario%/}"; then
    FAILED=$((FAILED + 1))
    FAILED_NAMES+=("$(basename "${scenario%/}")")
  fi
  echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$((TOTAL - FAILED))/$TOTAL scenarios passed"

if [ "$FAILED" -gt 0 ]; then
  echo "Failed: ${FAILED_NAMES[*]}"
  exit 1
fi
exit 0
