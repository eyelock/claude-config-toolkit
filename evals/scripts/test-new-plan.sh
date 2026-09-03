#!/bin/bash
# Tests skills/toolkit-new-plan/scripts/new-plan.sh. Unlike the handover scripts, this one
# resolves paths relative to cwd, so it's fully sandboxable in a scratch temp dir.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="$REPO_ROOT/skills/toolkit-new-plan/scripts/new-plan.sh"
TODAY="$(date +%Y-%m-%d)"

echo "test-new-plan.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/plans"
cd "$SCRATCH"

OUTPUT=$(bash "$TARGET" "auth-approaches" "Need to decide on an auth strategy" 2>&1)
CODE=$?
EXPECTED="plans/${TODAY}-auth-approaches.md"

assert_exit_code "$CODE" 0 "exits 0 on success"
assert_file_exists "$EXPECTED" "creates plans/${TODAY}-auth-approaches.md"

if [ -f "$EXPECTED" ]; then
  CONTENT=$(cat "$EXPECTED")
  assert_contains "$CONTENT" "plan_id: \"${TODAY}-auth-approaches\"" "plan_id reflects description and today's date"
  assert_contains "$CONTENT" 'status: "draft"' "default status is draft"
  assert_contains "$CONTENT" "Need to decide on an auth strategy" "context is filled into the Problem section"
fi

# No plans/ dir at all -> should fail with a clear error, not crash uncontrolled
SCRATCH2="$(mktemp -d)"
cd "$SCRATCH2"
OUTPUT2=$(bash "$TARGET" "no-plans-dir" "" 2>&1)
CODE2=$?
assert_exit_code "$CODE2" 1 "fails cleanly when no plans/ directory exists"
rm -rf "$SCRATCH2"

assert_report
