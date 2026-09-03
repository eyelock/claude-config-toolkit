#!/bin/bash
# Tests skills/toolkit-handover/scripts/new-handover.sh.
# The script resolves its own PROJECT_ROOT from its file location (not cwd), so it always
# operates on this repo's real sessions/ dir. sessions/*.md is git-ignored working content —
# we create a uniquely-named file and delete it afterward, leaving no trace.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="skills/toolkit-handover/scripts/new-handover.sh"
DESC="evaltest-$(date +%s)-$$"
TODAY="$(date +%Y-%m-%d)"
EXPECTED_FILE="$REPO_ROOT/sessions/${TODAY}-${DESC}.md"

echo "test-new-handover.sh"

cd "$REPO_ROOT"
OUTPUT=$(bash "$TARGET" "$DESC" 2>&1)
CODE=$?

assert_exit_code "$CODE" 0 "exits 0 on success"
assert_file_exists "$EXPECTED_FILE" "creates sessions/${TODAY}-${DESC}.md"

if [ -f "$EXPECTED_FILE" ]; then
  CONTENT=$(cat "$EXPECTED_FILE")
  assert_contains "$CONTENT" "session_id: \"${TODAY}-${DESC}\"" "session_id reflects description and today's date"
  assert_contains "$CONTENT" 'status: "in_progress"' "default status is in_progress"
fi

# Re-running with the same description should fail (file already exists), not overwrite silently.
OUTPUT2=$(bash "$TARGET" "$DESC" 2>&1)
CODE2=$?
assert_exit_code "$CODE2" 1 "refuses to overwrite an existing handover"

rm -f "$EXPECTED_FILE"

assert_report
