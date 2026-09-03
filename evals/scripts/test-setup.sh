#!/bin/bash
# Tests skills/toolkit-setup/scripts/setup.sh (cwd-relative, sandboxable). Covers the
# "new-project" detection path in non-interactive mode (no tty stdin, matches how the eval
# harness and CI invoke it).
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="$REPO_ROOT/skills/toolkit-setup/scripts/setup.sh"

echo "test-setup.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

OUTPUT=$(bash "$TARGET" < /dev/null 2>&1)
CODE=$?

assert_exit_code "$CODE" 0 "exits 0 on success (new-project, non-interactive)"
assert_contains "$OUTPUT" "New project" "detects new-project context"
assert_file_exists ".claude/sessions/README.md" "creates .claude/sessions/README.md"
assert_file_exists ".claude/sessions/TEMPLATE.md" "creates .claude/sessions/TEMPLATE.md"
assert_file_exists ".claude/plans/README.md" "creates .claude/plans/README.md"
assert_file_exists ".claude/plans/TEMPLATE.md" "creates .claude/plans/TEMPLATE.md"

# Re-running should detect already-configured and not error
OUTPUT2=$(bash "$TARGET" < /dev/null 2>&1)
CODE2=$?
assert_exit_code "$CODE2" 0 "re-running on an already-set-up workspace still exits 0"
assert_contains "$OUTPUT2" "already configured" "detects already-configured workspace on re-run"

assert_report
