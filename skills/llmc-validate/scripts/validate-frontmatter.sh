#!/bin/bash
# ---
# type: validation
# safe_to_run: true
# created: "2026-02-01"
# description: "Helpful frontmatter linter - suggests improvements, only fails on critical issues"
# requires: []
# ---

# Script: validate-frontmatter.sh
# Purpose: Validate frontmatter in session workspace files
# Philosophy: HARD STOP on critical, gentle suggestions otherwise
# Usage: ./scripts/validate-frontmatter.sh [--strict] [path]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors using tput (more portable)
if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
  RED=$(tput setaf 1)
  YELLOW=$(tput setaf 3)
  GREEN=$(tput setaf 2)
  BLUE=$(tput setaf 4)
  NC=$(tput sgr0)
else
  RED=''
  YELLOW=''
  GREEN=''
  BLUE=''
  NC=''
fi

# Counters
CRITICAL_ERRORS=0
SUGGESTIONS=0
GOOD=0

# Mode
STRICT=false

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [PATH]

Helpful frontmatter linter for session workspace files.

Philosophy:
  - HARD STOP: Unparseable YAML, wrong file naming (breaks sorting)
  - SUGGESTIONS: "Consider adding X for better results"
  - Frictionless: LLMs only get better, don't second-guess them

Options:
  --strict       Treat suggestions as errors (for CI)
  -h, --help     Show this help

Arguments:
  PATH           File or directory to validate (default: sessions/ and plans/)

Examples:
  $(basename "$0")                                    # Check all workspace files
  $(basename "$0") sessions/                 # Check handovers
  $(basename "$0") sessions/2026-02-01-*.md  # Check specific file

Exit codes:
  0 - All good (suggestions don't fail)
  1 - Critical errors found
EOF
}

critical() {
  echo -e "${RED}✗ CRITICAL:${NC} $1"
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
}

suggest() {
  echo -e "${YELLOW}💡 SUGGEST:${NC} $1"
  SUGGESTIONS=$((SUGGESTIONS + 1))
}

good() {
  echo -e "${GREEN}✓${NC} $1"
  GOOD=$((GOOD + 1))
}

info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

check_file_naming() {
  local file=$1
  local basename=$(basename "$file")
  local dirname=$(basename "$(dirname "$file")")

  # Skip special files
  if [[ "$basename" == "TEMPLATE."* ]] || \
     [[ "$basename" == "README"* ]] || \
     [[ "$basename" == "INSTRUCTIONS"* ]] || \
     [[ "$basename" == ".gitignore" ]]; then
    return 0
  fi

  # Check YYYY-MM-DD pattern
  if [[ ! "$basename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}- ]]; then
    critical "$file: Filename must start with YYYY-MM-DD- (breaks chronological sorting)"
    return 1
  fi

  good "$file: Filename follows YYYY-MM-DD-* pattern"
  return 0
}

extract_frontmatter() {
  local file=$1
  local in_frontmatter=false
  local frontmatter=""
  local line_num=0

  while IFS= read -r line; do
    line_num=$((line_num + 1))

    if [ $line_num -eq 1 ] && [ "$line" = "---" ]; then
      in_frontmatter=true
      continue
    fi

    if [ "$in_frontmatter" = true ]; then
      if [ "$line" = "---" ]; then
        echo "$frontmatter"
        return 0
      fi
      frontmatter="${frontmatter}${line}"$'\n'
    fi
  done < "$file"

  # No frontmatter found
  return 1
}

check_yaml_parseable() {
  local file=$1
  local frontmatter

  if ! frontmatter=$(extract_frontmatter "$file"); then
    critical "$file: No frontmatter found (must start with --- on line 1)"
    return 1
  fi

  # Basic YAML syntax check (just look for key: value pattern)
  if ! echo "$frontmatter" | grep -q '^[a-z_]*:'; then
    critical "$file: Frontmatter doesn't look like valid YAML"
    return 1
  fi

  good "$file: Frontmatter is parseable"
  return 0
}

check_field() {
  local file=$1
  local field=$2
  local required=$3  # "required" or "optional"
  local frontmatter

  frontmatter=$(extract_frontmatter "$file") || return 1

  if echo "$frontmatter" | grep -q "^${field}:"; then
    good "$file: Has '$field' field"
    return 0
  else
    if [ "$required" = "required" ]; then
      critical "$file: Missing required field '$field'"
      return 1
    else
      suggest "$file: Consider adding '$field' for better context"
      return 0
    fi
  fi
}

check_date_format() {
  local file=$1
  local field=$2
  local frontmatter

  frontmatter=$(extract_frontmatter "$file") || return 1

  local value=$(echo "$frontmatter" | grep "^${field}:" | sed "s/^${field}: *\"\?\([^\"]*\)\"\?/\1/" | tr -d ' ')

  if [ -z "$value" ]; then
    return 0  # Field not present, that's okay
  fi

  if [[ ! "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    suggest "$file: Field '$field' should be YYYY-MM-DD format (found: $value)"
    return 0
  fi

  good "$file: Field '$field' has correct date format"
  return 0
}

validate_handover() {
  local file=$1

  info "Validating handover: $file"

  check_file_naming "$file" || true
  check_yaml_parseable "$file" || return 1

  # Required fields (HARD STOP)
  check_field "$file" "session_id" "required"
  check_field "$file" "context" "required"
  check_field "$file" "status" "required"

  # Optional but recommended
  check_field "$file" "next_steps" "optional"
  check_field "$file" "related_files" "optional"
  check_field "$file" "previous_session" "optional"

  # Date format checks
  check_date_format "$file" "session_id"
  check_date_format "$file" "previous_session"
  check_date_format "$file" "continued_in"
  check_date_format "$file" "last_updated"

  echo ""
}

validate_plan() {
  local file=$1

  info "Validating plan: $file"

  check_file_naming "$file" || true
  check_yaml_parseable "$file" || return 1

  # Required fields
  check_field "$file" "created" "required"
  check_field "$file" "status" "required"
  check_field "$file" "context" "required"

  # Optional but recommended
  check_field "$file" "approaches" "optional"
  check_field "$file" "related_to" "optional"
  check_field "$file" "last_updated" "optional"

  # Date format checks
  check_date_format "$file" "created"
  check_date_format "$file" "last_updated"

  echo ""
}

validate_script() {
  local file=$1

  info "Validating script: $file"

  # Scripts in comments, not frontmatter
  if ! head -20 "$file" | grep -q "^# ---"; then
    suggest "$file: Consider adding frontmatter in comments (see TEMPLATE.sh)"
    return 0
  fi

  # Check for basic fields in comments
  if head -20 "$file" | grep -q "# type:"; then
    good "$file: Has type field"
  else
    suggest "$file: Consider adding '# type:' field"
  fi

  if head -20 "$file" | grep -q "# safe_to_run:"; then
    good "$file: Has safe_to_run field"
  else
    suggest "$file: Consider adding '# safe_to_run:' field"
  fi

  echo ""
}

main() {
  local target_path="sessions/ plans/"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --strict)
        STRICT=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        target_path="$1"
        shift
        ;;
    esac
  done

  echo "🔍 Validating frontmatter..."
  echo "   Path: $target_path"
  echo "   Mode: $([ "$STRICT" = true ] && echo "STRICT" || echo "HELPFUL")"
  echo ""

  # Find and validate files
  if [ -f "$target_path" ]; then
    # Single file
    case "$target_path" in
      *handover*.md)
        validate_handover "$target_path"
        ;;
      *plans*.md)
        validate_plan "$target_path"
        ;;
      *.sh)
        validate_script "$target_path"
        ;;
      *)
        info "Skipping: $target_path (unknown type)"
        ;;
    esac
  else
    # Directory
    # Handovers
    while IFS= read -r file; do
      validate_handover "$file"
    done < <(find "$target_path" -path "*/handover/*.md" -type f ! -name "TEMPLATE.md" ! -name "README*.md" ! -name "INSTRUCTIONS*.md" 2>/dev/null || true)

    # Plans
    while IFS= read -r file; do
      validate_plan "$file"
    done < <(find "$target_path" -path "*/plans/*.md" -type f ! -name "TEMPLATE.md" ! -name "README*.md" 2>/dev/null || true)

    # Scripts
    while IFS= read -r file; do
      validate_script "$file"
    done < <(find "$target_path" -path "*/scripts/*.sh" -type f ! -name "TEMPLATE.sh" 2>/dev/null || true)
  fi

  # Summary
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Summary:"
  echo "  ${GREEN}✅ Good:${NC} $GOOD"
  echo "  ${YELLOW}💡 Suggestions:${NC} $SUGGESTIONS"
  echo "  ${RED}❌ Critical:${NC} $CRITICAL_ERRORS"
  echo ""

  if [ $CRITICAL_ERRORS -gt 0 ]; then
    echo "❌ CRITICAL ERRORS FOUND"
    echo "   Fix these before continuing (they break core functionality)"
    exit 1
  fi

  if [ "$STRICT" = true ] && [ $SUGGESTIONS -gt 0 ]; then
    echo "⚠️  STRICT MODE: Suggestions treated as errors"
    exit 1
  fi

  if [ $SUGGESTIONS -gt 0 ]; then
    echo "💡 Suggestions are optional - LLMs get better over time"
    echo "   Consider adding suggested fields for even better results"
  fi

  if [ $CRITICAL_ERRORS -eq 0 ] && [ $SUGGESTIONS -eq 0 ]; then
    echo "🎉 Everything looks great!"
  fi

  echo ""
  echo "Philosophy: Frictionless development."
  echo "  HARD STOP: Only on critical issues (unparseable, breaks sorting)"
  echo "  SUGGESTIONS: Optional improvements (LLMs will understand anyway)"

  exit 0
}

main "$@"
