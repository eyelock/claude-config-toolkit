#!/bin/bash
# Tests skills/toolkit-new-artifact/scripts/new-artifact.sh: agent and command creation
# (cwd-relative, sandboxable). Rule/skill paths are intentionally not automated — see the
# SKILL.md — so they aren't tested here beyond confirming they fail cleanly.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/lib/assert.sh"

TARGET="$REPO_ROOT/skills/toolkit-new-artifact/scripts/new-artifact.sh"

echo "test-new-artifact.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
mkdir -p "$SCRATCH/agents" "$SCRATCH/commands" "$SCRATCH/skills" "$SCRATCH/rules"
cd "$SCRATCH"

# Agent creation (non-interactive: type, name, description; tools choice defaults to 1/read-only)
bash "$TARGET" agent my-thing "Expert guidance on my thing" < /dev/null > /dev/null 2>&1
assert_exit_code "$?" 0 "agent creation exits 0"
assert_file_exists "agents/toolkit-my-thing.md" "creates agents/toolkit-my-thing.md"
if [ -f "agents/toolkit-my-thing.md" ]; then
  CONTENT=$(cat "agents/toolkit-my-thing.md")
  assert_contains "$CONTENT" "name: toolkit-my-thing" "agent frontmatter name matches filename"
  assert_contains "$CONTENT" "description: Expert guidance on my thing" "agent frontmatter has the given description"
fi

# Command creation
bash "$TARGET" command my-cmd "Does a thing" < /dev/null > /dev/null 2>&1
assert_exit_code "$?" 0 "command creation exits 0"
assert_file_exists "commands/toolkit-my-cmd.md" "creates commands/toolkit-my-cmd.md"
if [ -f "commands/toolkit-my-cmd.md" ]; then
  CONTENT2=$(cat "commands/toolkit-my-cmd.md")
  assert_contains "$CONTENT2" "name: toolkit-my-cmd" "command frontmatter name matches filename"
  assert_contains "$CONTENT2" "argument-hint:" "command frontmatter has an argument-hint"
fi

# Duplicate name should refuse to overwrite
bash "$TARGET" agent my-thing "Duplicate" < /dev/null > /dev/null 2>&1
assert_exit_code "$?" 1 "refuses to overwrite an existing agent"

# Rule and skill paths should fail cleanly (not automated), not crash
bash "$TARGET" rule my-rule "desc" < /dev/null > /dev/null 2>&1
assert_exit_code "$?" 1 "rule creation fails cleanly (not automated)"
bash "$TARGET" skill my-skill "desc" < /dev/null > /dev/null 2>&1
assert_exit_code "$?" 1 "skill creation fails cleanly (not automated)"

assert_report
