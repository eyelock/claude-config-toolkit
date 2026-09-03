#!/bin/bash
# Tests skills/toolkit-validate/scripts/validate-artifacts.sh. The script resolves its own
# repo root from its own file location (so it always validates the tree it's shipped in),
# so a fixture test needs a full copy of commands/skills/agents/rules + the script itself at
# the matching relative path inside a scratch dir.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

echo "test-validate-artifacts.sh"

mkscratch() {
  local scratch
  scratch="$(mktemp -d)"
  cp -r "$REPO_ROOT/commands" "$REPO_ROOT/skills" "$REPO_ROOT/agents" "$REPO_ROOT/rules" "$scratch/"
  echo "$scratch"
}

# Clean tree (this repo, as shipped) should pass with 0 errors.
CLEAN="$(mkscratch)"
bash "$CLEAN/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 0 "clean tree passes with 0 errors"
rm -rf "$CLEAN"

# Agent name mismatch -> error, exit 1.
BROKEN1="$(mkscratch)"
sed -i '' 's/^name: toolkit-architecture$/name: toolkit-bogus-name/' "$BROKEN1/agents/toolkit-architecture.md"
OUT1=$(bash "$BROKEN1/skills/toolkit-validate/scripts/validate-artifacts.sh" 2>&1)
assert_exit_code "$?" 1 "agent name != filename is caught"
assert_contains "$OUT1" "toolkit-bogus-name" "reports the offending name in the error"
rm -rf "$BROKEN1"

# Skill directory/name mismatch -> error, exit 1.
BROKEN2="$(mkscratch)"
sed -i '' 's/^name: toolkit-setup$/name: toolkit-wrong-name/' "$BROKEN2/skills/toolkit-setup/SKILL.md"
bash "$BROKEN2/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 1 "skill name != directory is caught"
rm -rf "$BROKEN2"

# Missing agent description -> error, exit 1.
BROKEN3="$(mkscratch)"
sed -i '' '/^description:/d' "$BROKEN3/agents/toolkit-workflows.md"
bash "$BROKEN3/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 1 "agent missing description is caught"
rm -rf "$BROKEN3"

# model: accepts an alias (including fable) or any full Claude model id, not just the 4 aliases.
GOODMODEL="$(mkscratch)"
sed -i '' 's/^model: inherit$/model: fable/' "$GOODMODEL/agents/toolkit-workflows.md"
bash "$GOODMODEL/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 0 "model: fable is accepted"
rm -rf "$GOODMODEL"

GOODMODEL2="$(mkscratch)"
sed -i '' 's/^model: inherit$/model: claude-sonnet-5/' "$GOODMODEL2/agents/toolkit-workflows.md"
bash "$GOODMODEL2/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 0 "model: a full claude-* model id is accepted, not just the 4 aliases"
rm -rf "$GOODMODEL2"

# A genuinely bogus model value should still be caught.
BADMODEL="$(mkscratch)"
sed -i '' 's/^model: inherit$/model: gpt-4/' "$BADMODEL/agents/toolkit-workflows.md"
bash "$BADMODEL/skills/toolkit-validate/scripts/validate-artifacts.sh" >/dev/null 2>&1
assert_exit_code "$?" 1 "an unrecognized model value is still caught"
rm -rf "$BADMODEL"

assert_report
