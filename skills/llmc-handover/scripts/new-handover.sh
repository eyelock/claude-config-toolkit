#!/bin/bash
# ---
# type: setup
# safe_to_run: true
# created: "2026-02-01"
# description: "Create new handover document from template with auto-dating"
# requires: []
# ---

# Script: new-handover.sh
# Purpose: Create a new session handover document from template
# Usage: ./scripts/new-handover.sh <description>
# Example: ./scripts/new-handover.sh feature-design

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HANDOVER_DIR="$PROJECT_ROOT/sessions"
TEMPLATE="$HANDOVER_DIR/TEMPLATE.md"

usage() {
  cat <<EOF
Usage: $(basename "$0") <description>

Create a new session handover document from template.

Arguments:
  description    Brief description for filename (use-dashes-not-spaces)

Examples:
  $(basename "$0") feature-design
  $(basename "$0") bug-investigation
  $(basename "$0") api-refactor

Creates:
  sessions/YYYY-MM-DD-<description>.md
EOF
}

main() {
  # Check for description argument
  if [ $# -eq 0 ]; then
    echo "Error: Description required"
    echo ""
    usage
    exit 1
  fi

  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
  fi

  local description="$1"
  local today=$(date +%Y-%m-%d)
  local filename="${today}-${description}.md"
  local filepath="$HANDOVER_DIR/$filename"

  # Check if file already exists
  if [ -f "$filepath" ]; then
    echo "Error: File already exists: $filepath"
    echo "Choose a different description or edit the existing file."
    exit 1
  fi

  # Check if template exists
  if [ ! -f "$TEMPLATE" ]; then
    echo "Error: Template not found: $TEMPLATE"
    exit 1
  fi

  # Copy template
  cp "$TEMPLATE" "$filepath"

  # Replace YYYY-MM-DD placeholders with actual date
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed
    sed -i '' "s/YYYY-MM-DD/${today}/g" "$filepath"
  else
    # Linux sed
    sed -i "s/YYYY-MM-DD/${today}/g" "$filepath"
  fi

  # Update session_id with description
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/session_id: \"${today}-descriptor\"/session_id: \"${today}-${description}\"/" "$filepath"
  else
    sed -i "s/session_id: \"${today}-descriptor\"/session_id: \"${today}-${description}\"/" "$filepath"
  fi

  echo "✓ Created handover document: $filepath"
  echo ""
  echo "Next steps:"
  echo "  1. Edit the file and fill in context"
  echo "  2. Update as you work"
  echo "  3. Archive when complete: ./scripts/archive-old-handovers.sh"
  echo ""
  echo "Open with: \$EDITOR $filepath"
}

main "$@"
