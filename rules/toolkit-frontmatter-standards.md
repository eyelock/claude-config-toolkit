# Toolkit Frontmatter Standards

When working with Toolkit session workspace files, follow these frontmatter conventions:

## Naming Convention

**Always use `snake_case` for all frontmatter fields.**

```yaml
✅ session_id: "2026-02-02-feature"
✅ previous_session: "2026-02-01-setup"
✅ last_updated: "2026-02-02"
✅ safe_to_run: true

❌ sessionId: "..."      # camelCase - wrong
❌ SessionID: "..."      # PascalCase - wrong
❌ session-id: "..."     # kebab-case - wrong
```

## Required Fields by Type

### Handover Files (`sessions/*.md`)

**Required:**
- `session_id` - Unique identifier (YYYY-MM-DD-description)
- `context` - One-line summary
- `status` - Current state (in_progress | paused | blocked | completed)

**Optional but recommended:**
- `previous_session` - Chain backwards
- `continued_in` - Chain forwards
- `next_steps` - Actionable items for resume
- `related_files` - Files touched this session
- `blockers` - What's blocking progress
- `last_updated` - Track when updated

### Working Plans (`plans/*.md`)

**Required:**
- `created` - Creation date (YYYY-MM-DD)
- `status` - Current state (draft | in_progress | ready | archived)
- `context` - Why exploring this

**Optional but recommended:**
- `last_updated` - Track updates
- `related_to` - Link to formal plan if graduated
- `approaches` - List approaches being considered

### Scripts (`*.sh`)

**Required (in comments):**
- `type` - Script category
- `safe_to_run` - Safety indicator (true | false)
- `description` - What it does

**Optional:**
- `created` - Creation date
- `last_run` - Last execution date
- `requires` - Dependencies
- `created_during_session` - Link to handover

## Date Format

All date fields use `YYYY-MM-DD` format:

```yaml
✅ created: "2026-02-02"
✅ last_updated: "2026-02-02"

❌ created: "02-02-2026"     # Wrong order
❌ created: "2/2/2026"       # Wrong format
❌ created: "Feb 2, 2026"    # Wrong format
```

## Why These Standards?

**Consistency:** Same patterns across all file types
**Tooling:** Enables automated validation and processing
**Readability:** Clear, predictable structure
**LLM-friendly:** Models understand structured metadata better
