# Sessions Directory

**Purpose:** Session continuity documents for resuming work across conversations.

## What Goes Here

Session handover documents with the pattern: `YYYY-MM-DD-description.md`

**Example:** `2026-02-01-auth-implementation.md`

## Why This Exists

Claude conversations are stateless - context is lost between sessions. These handover documents bridge that gap by capturing:

- What you were working on
- Current status and blockers
- Next steps to take
- Related files and context

## Git Status

**Content is git-ignored** - these are your personal working notes, not team documentation.

The directory itself exists in the repo (so the structure is clear), but the `.md` files you create are ignored via `.gitignore`.

## Frontmatter Structure

```yaml
---
session_id: "2026-02-01-feature-name"
previous_session: "2026-01-31-feature-name"  # optional
continued_in: ""                             # filled when resuming
context: "One-line summary of what this session is about"
status: "in_progress|paused|completed"
blockers: []
next_steps:
  - "Specific actionable item"
  - "Another task"
related_files:
  - "/absolute/path/to/file.md"
last_updated: "2026-02-01"
---
```

## Creating Handovers

### Manually
Copy `TEMPLATE.md` and rename with current date:
```bash
cp sessions/TEMPLATE.md sessions/2026-02-01-my-feature.md
```

### Using LLMC Command
```
/llmc-new-handover my-feature
```

Creates: `sessions/2026-02-01-my-feature.md`

## Using Handovers

**At session start:**
1. List recent sessions: `ls -lt sessions/*.md | head -5`
2. Read the most recent: open in editor
3. Continue from `next_steps`

**At session end:**
1. Update `status`, `blockers`, `next_steps`
2. Set `last_updated` to today
3. Save and exit

## Cleanup

Old sessions can be archived:

```
/llmc-archive
```

Or manually:
```bash
mkdir -p sessions/archive/2026-01
mv sessions/2026-01-*.md sessions/archive/2026-01/
```

## What This Is NOT

- ❌ Team documentation (use `.claude/sessions/` for that)
- ❌ Formal plans (use `plans/` for exploration, `.claude/plans/` for formal)
- ❌ Production code (use project files)

## Related

- `plans/` - Working plans and exploration
- `.claude/sessions/` - Team-shared session summaries (git-tracked)
- `TEMPLATE.md` - Starting template for new handovers
