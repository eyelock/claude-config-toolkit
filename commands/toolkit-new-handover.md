# Create New Handover

**Command:** `/toolkit-new-handover <description>`

**Purpose:** Create a new session handover document with today's date and proper frontmatter.

## Usage

```
/toolkit-new-handover feature-design
/toolkit-new-handover bug-investigation
/toolkit-new-handover api-redesign
```

## What It Does

1. Gets today's date in YYYY-MM-DD format
2. Creates `sessions/YYYY-MM-DD-<description>.md`
3. Copies frontmatter template
4. Fills in today's date
5. Opens file for editing

## Implementation

When user invokes this command:

```bash
#!/bin/bash
TODAY=$(date +%Y-%m-%d)
DESCRIPTION="$1"
FILENAME="sessions/${TODAY}-${DESCRIPTION}.md"

# Check if file already exists
if [ -f "$FILENAME" ]; then
  echo "Error: Handover already exists: $FILENAME"
  exit 1
fi

# Copy template
cp sessions/TEMPLATE.md "$FILENAME"

# Replace placeholders with today's date
sed -i '' "s/YYYY-MM-DD/${TODAY}/g" "$FILENAME"
sed -i '' "s/session_id: \"${TODAY}-descriptor\"/session_id: \"${TODAY}-${DESCRIPTION}\"/" "$FILENAME"

echo "✓ Created handover: $FILENAME"
echo ""
echo "Next steps:"
echo "  1. Edit the file and fill in context"
echo "  2. Update status as you work"
echo "  3. Archive when complete: /toolkit-archive"
```

## Example Output

```bash
$ /toolkit-new-handover api-redesign
✓ Created handover: sessions/2026-02-02-api-redesign.md

Next steps:
  1. Edit the file and fill in context
  2. Update status as you work
  3. Archive when complete: /toolkit-archive
```

## Frontmatter Created

```yaml
---
session_id: "2026-02-02-api-redesign"
previous_session: ""
continued_in: ""
context: "One-line summary of what we're working on"
status: "in_progress"
blockers: []
next_steps:
  - "First thing to do when resuming"
  - "Second thing to do"
related_files: []
last_updated: "2026-02-02"
---
```

## See Also

- `/toolkit-archive` - Archive old session files
- `skills/toolkit-handover/` - Interactive session helper
- `sessions/TEMPLATE.md` - Template used
