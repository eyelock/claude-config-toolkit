#!/bin/bash
# Tests skills/toolkit-validate/scripts/validate-frontmatter.sh against good/bad fixtures.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="$REPO_ROOT/skills/toolkit-validate/scripts/validate-frontmatter.sh"

echo "test-validate-frontmatter.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/handover"

GOOD="$SCRATCH/handover/2026-09-03-good.md"
cat > "$GOOD" <<'EOF'
---
session_id: "2026-09-03-good"
context: "Testing the validator"
status: "in_progress"
last_updated: "2026-09-03"
---
Body.
EOF

bash "$TARGET" "$GOOD" >/dev/null 2>&1
assert_exit_code "$?" 0 "good fixture (all required fields present) passes"

BAD="$SCRATCH/handover/2026-09-03-bad.md"
cat > "$BAD" <<'EOF'
---
context: "Missing session_id and status"
---
Body.
EOF

bash "$TARGET" "$BAD" >/dev/null 2>&1
assert_exit_code "$?" 1 "fixture missing required fields fails"

NOFM="$SCRATCH/handover/2026-09-03-no-frontmatter.md"
echo "Just prose, no frontmatter." > "$NOFM"
bash "$TARGET" "$NOFM" >/dev/null 2>&1
assert_exit_code "$?" 1 "fixture with no frontmatter at all fails"

assert_report
