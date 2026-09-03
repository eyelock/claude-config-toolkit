#!/bin/bash
# ---
# type: validation
# safe_to_run: true
# created: "2026-09-03"
# description: "Validates commands/, skills/, agents/, rules/ themselves (structure + frontmatter), not workspace files"
# requires: []
# ---

# Script: validate-artifacts.sh
# Purpose: Structural/frontmatter validation of Toolkit artifacts (commands, skills, agents, rules).
#          Single source of truth for checks previously duplicated inline in the Makefile.
# Usage: ./scripts/validate-artifacts.sh [--strict]
#
# Exit codes:
#   0 - No errors (warnings don't fail unless --strict)
#   1 - Errors found

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
cd "$PROJECT_ROOT"

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
  RED=$(tput setaf 1); YELLOW=$(tput setaf 3); GREEN=$(tput setaf 2); NC=$(tput sgr0)
else
  RED=''; YELLOW=''; GREEN=''; NC=''
fi

STRICT=false
[ "${1:-}" = "--strict" ] && STRICT=true

ERRORS=0
WARNINGS=0
CHECKED=0

error() { echo "  ${RED}❌${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn()  { echo "  ${YELLOW}⚠️${NC}  $1"; WARNINGS=$((WARNINGS + 1)); }
ok()    { : ; } # quiet on success, summary line covers it

frontmatter_of() {
  # Prints the YAML frontmatter block (between the first two '---' lines), or nothing.
  sed -n '/^---$/,/^---$/p' "$1" | sed '1d;$d'
}

field_of() {
  # field_of <file> <field-name>
  frontmatter_of "$1" | grep "^${2}:" | head -1 | sed "s/^${2}: *//" | sed 's/^"//; s/"$//'
}

echo "🔍 Validating Toolkit artifacts (commands/, skills/, agents/, rules/)..."
echo ""

# --- No empty files anywhere in the four artifact directories ---
echo "1. Checking for empty files..."
EMPTY=$(find commands skills agents rules -name "*.md" -type f -size 0 2>/dev/null || true)
if [ -n "$EMPTY" ]; then
  while IFS= read -r f; do error "$f: empty file"; done <<< "$EMPTY"
else
  echo "  ${GREEN}✅${NC} No empty files"
fi
echo ""

# --- Skills: name field must match parent directory (agentskills.io spec) ---
echo "2. Validating skills..."
if [ -d skills ]; then
  while IFS= read -r skill_file; do
    [ -f "$skill_file" ] || continue
    CHECKED=$((CHECKED + 1))
    skill_dir=$(basename "$(dirname "$skill_file")")
    skill_name=$(field_of "$skill_file" "name")
    skill_desc=$(field_of "$skill_file" "description")
    if [ -z "$skill_name" ]; then
      error "$skill_file: missing 'name' field in frontmatter"
    elif [ "$skill_dir" != "$skill_name" ]; then
      error "$skill_file: name '$skill_name' ≠ directory '$skill_dir' (per agentskills.io spec, these must match)"
    fi
    [ -z "$skill_desc" ] && error "$skill_file: missing 'description' field in frontmatter"
    [ -n "$skill_desc" ] && [ "${#skill_desc}" -lt 20 ] && warn "$skill_file: description is very short (${#skill_desc} chars) — may not trigger reliably"
  done < <(find skills -name "SKILL.md" -type f)
  echo "  ${GREEN}✅${NC} Checked skills"
else
  echo "  ℹ️  No skills directory"
fi
echo ""

# --- Agents: frontmatter present, name matches filename, description present/specific, tools/model valid ---
echo "3. Validating agents..."
VALID_MODELS="sonnet opus haiku fable inherit"
if [ -d agents ]; then
  for agent_file in agents/*.md; do
    [ -f "$agent_file" ] || continue
    CHECKED=$((CHECKED + 1))
    agent_basename=$(basename "$agent_file" .md)
    if ! grep -q "^---" "$agent_file"; then
      error "$agent_file: missing frontmatter"
      continue
    fi
    agent_name=$(field_of "$agent_file" "name")
    agent_desc=$(field_of "$agent_file" "description")
    agent_model=$(field_of "$agent_file" "model")

    if [ -z "$agent_name" ]; then
      error "$agent_file: missing 'name' field in frontmatter"
    elif [ "$agent_name" != "$agent_basename" ]; then
      error "$agent_file: name '$agent_name' ≠ filename '$agent_basename'"
    fi

    if [ -z "$agent_desc" ]; then
      error "$agent_file: missing 'description' field in frontmatter"
    elif [ "${#agent_desc}" -lt 30 ]; then
      warn "$agent_file: description is short (${#agent_desc} chars) — Claude uses this to decide when to delegate; be specific"
    fi

    if [ -n "$agent_model" ] && ! grep -qw "$agent_model" <<< "$VALID_MODELS" && [[ "$agent_model" != *claude* ]]; then
      error "$agent_file: model '$agent_model' is not a recognized alias ($VALID_MODELS) or a full Claude model id"
    fi
  done
  echo "  ${GREEN}✅${NC} Checked agents"
else
  echo "  ℹ️  No agents directory"
fi
echo ""

# --- Commands: frontmatter with a description (best practice for /help discoverability) ---
echo "4. Validating commands..."
if [ -d commands ]; then
  for cmd_file in commands/*.md; do
    [ -f "$cmd_file" ] || continue
    CHECKED=$((CHECKED + 1))
    if ! grep -q "^---" "$cmd_file"; then
      warn "$cmd_file: no frontmatter — add 'description' (and 'argument-hint' if it takes args) so /help shows it properly"
      continue
    fi
    cmd_desc=$(field_of "$cmd_file" "description")
    [ -z "$cmd_desc" ] && warn "$cmd_file: frontmatter present but missing 'description'"
  done
  echo "  ${GREEN}✅${NC} Checked commands"
else
  echo "  ℹ️  No commands directory"
fi
echo ""

# --- Rules: has a top-level heading ---
echo "5. Validating rules..."
if [ -d rules ]; then
  for rule_file in rules/*.md; do
    [ -f "$rule_file" ] || continue
    CHECKED=$((CHECKED + 1))
    if ! grep -q "^# " "$rule_file"; then
      warn "$rule_file: no top-level '# Heading' found"
    fi
  done
  echo "  ${GREEN}✅${NC} Checked rules"
else
  echo "  ℹ️  No rules directory"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: checked $CHECKED artifacts — ${RED}$ERRORS error(s)${NC}, ${YELLOW}$WARNINGS warning(s)${NC}"

if [ "$ERRORS" -gt 0 ]; then
  exit 1
fi
if [ "$STRICT" = true ] && [ "$WARNINGS" -gt 0 ]; then
  echo "⚠️  STRICT MODE: warnings treated as errors"
  exit 1
fi
exit 0
