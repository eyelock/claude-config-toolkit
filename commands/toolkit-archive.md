# Archive Handovers

**Command:** `/toolkit-archive [--dry-run] [--days N]`

**Purpose:** Archive completed handover documents to date-organized folders.

## Usage

```
/toolkit-archive                  # Archive completed or >7 days old
/toolkit-archive --dry-run        # Preview what would be archived
/toolkit-archive --days 14        # Archive >14 days old
```

## What It Does

Archives handovers that are:
- Marked with `status: "completed"`
- OR older than N days (default: 7)

Moves them to: `sessions/archive/YYYY-MM/`

## Implementation

When user invokes this command:

```bash
#!/bin/bash
DRY_RUN=false
DAYS_OLD=7

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --days) DAYS_OLD="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo "📦 Archiving handover documents..."
echo "   Criteria: completed status OR older than $DAYS_OLD days"
echo ""

COUNT=0

# Find handover files
for file in sessions/2026-*.md; do
  [ ! -f "$file" ] && continue

  # Skip template and instructions
  [[ "$file" =~ TEMPLATE ]] && continue
  [[ "$file" =~ INSTRUCTIONS ]] && continue

  SHOULD_ARCHIVE=false
  REASON=""

  # Check status
  if grep -q 'status: "completed"' "$file"; then
    SHOULD_ARCHIVE=true
    REASON="status: completed"
  fi

  # Check age
  FILE_AGE=$(( ( $(date +%s) - $(stat -f %m "$file") ) / 86400 ))
  if [ "$FILE_AGE" -ge "$DAYS_OLD" ]; then
    SHOULD_ARCHIVE=true
    REASON="${REASON:+$REASON, }age: ${FILE_AGE} days"
  fi

  if [ "$SHOULD_ARCHIVE" = true ]; then
    BASENAME=$(basename "$file")
    MONTH=$(echo "$BASENAME" | grep -oE "^[0-9]{4}-[0-9]{2}")
    DEST_DIR="sessions/archive/$MONTH"

    if [ "$DRY_RUN" = true ]; then
      echo "Would archive: $BASENAME → archive/$MONTH/ ($REASON)"
    else
      mkdir -p "$DEST_DIR"
      mv "$file" "$DEST_DIR/"
      echo "✓ Archived: $BASENAME → archive/$MONTH/ ($REASON)"
    fi

    COUNT=$((COUNT + 1))
  fi
done

echo ""
if [ "$DRY_RUN" = true ]; then
  echo "Summary: Would archive $COUNT files"
  echo "Run without --dry-run to actually archive"
else
  echo "Summary: Archived $COUNT files"
fi
```

## Archive Structure

```
sessions/
├── 2026-02-05-current-work.md        # Active
├── 2026-02-04-another-task.md        # Active
└── archive/
    ├── 2026-01/                      # January archives
    │   ├── 2026-01-15-old-work.md
    │   └── 2026-01-20-another.md
    └── 2026-02/                      # February archives
        └── 2026-02-01-completed.md
```

## Cleanup Cadence

**Weekly:** Review active handovers, archive completed ones

**Monthly:** Clean up old archives (delete or compress)

## See Also

- `/toolkit-new-handover` - Create new handover
- `rules/toolkit-session-continuity.md` - When to archive handovers
