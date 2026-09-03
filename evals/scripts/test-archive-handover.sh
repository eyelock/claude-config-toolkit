#!/bin/bash
# Tests skills/toolkit-handover/scripts/archive-handover.sh against real sessions/ (same
# constraint as new-handover.sh: PROJECT_ROOT is resolved from the script's own location).
# Creates a uniquely-named completed handover, archives it, asserts it moved, cleans up.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="skills/toolkit-handover/scripts/archive-handover.sh"
TODAY="$(date +%Y-%m-%d)"
MONTH="$(date +%Y-%m)"
NAME="evaltest-$(date +%s)-$$"
SRC="$REPO_ROOT/sessions/${TODAY}-${NAME}.md"
DEST="$REPO_ROOT/sessions/archive/${MONTH}/${TODAY}-${NAME}.md"

echo "test-archive-handover.sh"

cat > "$SRC" <<EOF
---
session_id: "${TODAY}-${NAME}"
status: "completed"
last_updated: "${TODAY}"
---
Test fixture for evals/scripts/test-archive-handover.sh.
EOF

cd "$REPO_ROOT"

# --dry-run must not move the file
OUT_DRY=$(bash "$TARGET" --dry-run 2>&1)
assert_file_exists "$SRC" "--dry-run leaves the file in place"
assert_contains "$OUT_DRY" "Would archive: ${TODAY}-${NAME}.md" "--dry-run reports the file would be archived"

# Real run should move it
bash "$TARGET" >/dev/null 2>&1
assert_file_exists "$DEST" "moves completed handover to sessions/archive/${MONTH}/"
assert_file_not_exists "$SRC" "original file removed from sessions/"

rm -f "$SRC" "$DEST"
rmdir "$REPO_ROOT/sessions/archive/${MONTH}" 2>/dev/null || true

assert_report
