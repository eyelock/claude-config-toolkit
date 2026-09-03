#!/bin/bash
# Grades one scenario transcript against its prompt.md frontmatter.
# Usage: grade.sh <prompt.md> <transcript.jsonl> <scratch-dir>
# Exit codes: 0 pass, 1 fail
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/frontmatter.sh"

PROMPT_FILE="${1:?usage: grade.sh <prompt.md> <transcript.jsonl> <scratch-dir>}"
TRANSCRIPT="${2:?}"
SCRATCH="${3:?}"

# Every Skill tool_use invoked during the run, one skill name per line (deduped).
invoked_skills() {
  [ -f "$TRANSCRIPT" ] || return 0
  jq -r '
    select(.type == "assistant") | .message.content[]?
    | select(.type == "tool_use" and .name == "Skill")
    | (.input.skill // .input.name // empty)
  ' "$TRANSCRIPT" 2>/dev/null | sort -u
}

INVOKED="$(invoked_skills)"
PASS=true
REASONS=()

EXPECT_SKILL=$(fm_field "$PROMPT_FILE" "expect_skill")
if [ -n "$EXPECT_SKILL" ]; then
  if grep -qx "$EXPECT_SKILL" <<< "$INVOKED"; then
    REASONS+=("✅ invoked expected skill: $EXPECT_SKILL")
  else
    PASS=false
    REASONS+=("❌ expected skill '$EXPECT_SKILL' was NOT invoked (invoked: ${INVOKED:-none})")
  fi
fi

FORBID_SKILLS="$(fm_list "$PROMPT_FILE" "forbid_skills")"
if [ -n "$FORBID_SKILLS" ]; then
  BAD=""
  while IFS= read -r skill; do
    [ -z "$skill" ] && continue
    if grep -qx "$skill" <<< "$INVOKED"; then
      BAD="${BAD}${BAD:+, }$skill"
    fi
  done <<< "$FORBID_SKILLS"
  if [ -z "$BAD" ]; then
    REASONS+=("✅ none of the forbidden skills fired")
  else
    PASS=false
    REASONS+=("❌ forbidden skill(s) fired: $BAD")
  fi
fi

EXPECT_FILES="$(fm_list "$PROMPT_FILE" "expect_files")"
if [ -n "$EXPECT_FILES" ]; then
  while IFS= read -r pattern; do
    [ -z "$pattern" ] && continue
    if compgen -G "$SCRATCH/$pattern" > /dev/null 2>&1; then
      REASONS+=("✅ found expected file(s): $pattern")
    else
      PASS=false
      REASONS+=("❌ expected file(s) not found: $pattern")
    fi
  done <<< "$EXPECT_FILES"
fi

if [ -z "$EXPECT_SKILL" ] && [ -z "$FORBID_SKILLS" ] && [ -z "$EXPECT_FILES" ]; then
  PASS=false
  REASONS+=("❌ prompt.md declares no expect_skill/forbid_skills/expect_files — nothing to grade")
fi

for r in "${REASONS[@]}"; do echo "  $r"; done

if [ "$PASS" = true ]; then
  echo "  PASS"
  exit 0
else
  echo "  FAIL"
  exit 1
fi
