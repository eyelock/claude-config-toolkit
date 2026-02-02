#!/bin/bash
# ---
# type: cleanup
# safe_to_run: true
# created: "2026-02-01"
# description: "Archive completed handover documents by date"
# requires: []
# ---

# Script: archive-old-handovers.sh
# Purpose: Move completed handovers to date-organized archive
# Usage: ./scripts/archive-old-handovers.sh [--dry-run] [--days N]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HANDOVER_DIR="$PROJECT_ROOT/sessions"
ARCHIVE_DIR="$HANDOVER_DIR/archive"

# Default: archive completed or files older than 7 days
DRY_RUN=false
DAYS_OLD=7

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Archive completed handover documents to date-organized folders.

Archives handovers that are:
  - Marked with status: "completed"
  - OR older than N days (default: 7)

Options:
  --dry-run        Show what would be archived without doing it
  --days N         Archive handovers older than N days (default: 7)
  --all            Archive all completed regardless of age
  -h, --help       Show this help message

Examples:
  $(basename "$0")                    # Archive completed or >7 days old
  $(basename "$0") --dry-run          # Preview what would be archived
  $(basename "$0") --days 14          # Archive >14 days old
  $(basename "$0") --all              # Archive all completed

Archive structure:
  sessions/archive/YYYY-MM/YYYY-MM-DD-name.md
EOF
}

parse_frontmatter_status() {
  local file=$1
  grep "^status:" "$file" 2>/dev/null | head -1 | sed 's/status: *"\([^"]*\)".*/\1/'
}

get_file_age_days() {
  local file=$1
  local file_date
  local today_seconds
  local file_seconds
  local age_days

  if [[ "$OSTYPE" == "darwin"* ]]; then
    file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$file")
    today_seconds=$(date +%s)
    file_seconds=$(date -j -f "%Y-%m-%d" "$file_date" +%s)
  else
    file_date=$(stat -c "%y" "$file" | cut -d' ' -f1)
    today_seconds=$(date +%s)
    file_seconds=$(date -d "$file_date" +%s)
  fi

  age_days=$(( (today_seconds - file_seconds) / 86400 ))
  echo "$age_days"
}

extract_month() {
  local filename=$1
  # Extract YYYY-MM from YYYY-MM-DD-name.md
  echo "$filename" | grep -oE "^[0-9]{4}-[0-9]{2}" || echo ""
}

main() {
  local archive_all=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --days)
        DAYS_OLD="$2"
        shift 2
        ;;
      --all)
        archive_all=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [ "$DRY_RUN" = true ]; then
    echo "🔍 DRY RUN - No files will be moved"
    echo ""
  fi

  echo "📦 Archiving handover documents..."
  echo "   Criteria: completed status OR older than $DAYS_OLD days"
  echo ""

  local count=0
  local skipped=0

  # Find all handover files (not in archive, not template, not instructions)
  while IFS= read -r file; do
    local basename=$(basename "$file")

    # Skip template and instruction files
    if [[ "$basename" == "TEMPLATE.md" ]] || [[ "$basename" == "INSTRUCTIONS"* ]]; then
      continue
    fi

    local should_archive=false
    local reason=""

    # Check status
    local status=$(parse_frontmatter_status "$file")
    if [ "$status" = "completed" ]; then
      should_archive=true
      reason="status: completed"
    fi

    # Check age
    if [ "$archive_all" = false ]; then
      local age=$(get_file_age_days "$file")
      if [ "$age" -ge "$DAYS_OLD" ]; then
        should_archive=true
        reason="${reason:+$reason, }age: ${age} days"
      fi
    fi

    if [ "$should_archive" = true ]; then
      # Extract YYYY-MM from filename
      local month=$(extract_month "$basename")

      if [ -z "$month" ]; then
        echo "⚠️  Skipping (can't parse date): $basename"
        skipped=$((skipped + 1))
        continue
      fi

      local dest_dir="$ARCHIVE_DIR/$month"
      local dest_file="$dest_dir/$basename"

      if [ "$DRY_RUN" = true ]; then
        echo "Would archive: $basename → archive/$month/ ($reason)"
      else
        mkdir -p "$dest_dir"
        mv "$file" "$dest_file"
        echo "✓ Archived: $basename → archive/$month/ ($reason)"
      fi

      count=$((count + 1))
    fi

  done < <(find "$HANDOVER_DIR" -maxdepth 1 -name "*.md" -type f)

  echo ""
  if [ "$DRY_RUN" = true ]; then
    echo "Summary: Would archive $count files, skipped $skipped"
    echo "Run without --dry-run to actually archive"
  else
    echo "Summary: Archived $count files, skipped $skipped"
  fi

  if [ $count -eq 0 ] && [ $skipped -eq 0 ]; then
    echo "No handover files found to archive."
  fi
}

main "$@"
