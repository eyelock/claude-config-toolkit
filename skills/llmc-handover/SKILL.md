---
name: llmc-handover
description: Interactive helper for creating, updating, and managing session handover documents. Guides users through proper context capture for session continuity across stateless AI conversations.
---

# LLMC Handover Helper

Interactive guidance for session continuity through structured handovers.

## What This Does

Provides an interactive workflow for:
- Creating new handover documents
- Updating existing handovers
- Archiving completed work
- Linking related sessions
- Ensuring proper context capture

## When to Use

**Create handovers when:**
- ✅ Pausing work mid-stream
- ✅ Switching between tasks
- ✅ Complex multi-session work
- ✅ Need to resume later (possibly different Claude instance)

**Don't create handovers for:**
- ❌ Completed work (write summary in `sessions/` instead)
- ❌ Simple one-off tasks
- ❌ Just reading/learning

## Interactive Workflow

When invoked, this skill guides you through:

### 1. Mode Selection

```
What would you like to do?
1. Create new handover
2. Update existing handover
3. Archive completed handover
4. Link related sessions
```

### 2. Context Capture (for new handovers)

The skill asks targeted questions to ensure quality handovers:

**Essential Context:**
- What are you working on? (One-line summary)
- Why are you doing this? (Goal/motivation)
- Where did you leave off? (Current state)

**Next Steps:**
- What should happen when resuming?
- Are there any blockers?
- Which files are involved?

### 3. Frontmatter Generation

Automatically generates proper frontmatter:

```yaml
---
session_id: "2026-02-02-feature-implementation"
previous_session: ""
continued_in: ""
context: "Implementing JWT authentication for API"
status: "in_progress"
blockers: []
next_steps:
  - "Complete logout endpoint"
  - "Add refresh token handling"
related_files:
  - "api/auth.ts:45-89"
last_updated: "2026-02-02"
---
```

### 4. File Creation

Creates properly named file:
```
sessions/YYYY-MM-DD-description.md
```

### 5. Validation

Optionally runs validation to ensure:
- Required fields present
- Proper naming convention
- Valid status values
- Date formats correct

## Usage

```
# Start interactive handover workflow
/llmc-handover

# Quick create (skip interactive mode)
/llmc-handover create "api-implementation"

# Update existing handover
/llmc-handover update 2026-02-02-api-implementation

# Archive completed work
/llmc-handover archive 2026-02-02-api-implementation
```

## Quality Guidelines

The skill enforces handover quality by prompting for:

**Good handovers include:**
- ✅ Clear context (what you're working on)
- ✅ Current state (where you left off)
- ✅ Next steps (what to do when resuming)
- ✅ Related files (with line numbers if relevant)
- ✅ Blockers (what's preventing progress)

**Bad handovers:**
- ❌ Vague context ("working on stuff")
- ❌ No next steps (what do I do now?)
- ❌ Missing related files (can't find the code)
- ❌ No status (is this done? blocked?)

## Session Linking

Helps create session chains by prompting for:

```
Is this continuing previous work?
→ Links via previous_session field

Are you pausing this to work on something else?
→ Updates continued_in field
```

This creates a navigable chain:
```
2026-02-01-auth-planning.md
    ↓ (previous_session)
2026-02-02-auth-implementation.md
    ↓ (previous_session)
2026-02-03-auth-testing.md
```

## Archival Workflow

When archiving, prompts for:
- Update status to "completed"
- Move to archive/YYYY-MM/ directory
- Update related sessions' continued_in fields
- Create summary in `sessions/` for completed work

## Implementation

This is an interactive skill that:
1. Presents menu options
2. Gathers required information through prompts
3. Generates proper frontmatter and structure
4. Creates/updates files
5. Validates the result
6. Provides next steps

The skill includes helper scripts as assets:
- `scripts/new-handover.sh` - Create new handover
- `scripts/update-handover.sh` - Update existing handover
- `scripts/archive-handover.sh` - Archive completed work

## Example Session

```
User: /llmc-handover

Claude: I'll help you with session handovers.

What would you like to do?
1. Create new handover
2. Update existing handover
3. Archive completed handover

User: 1

Claude: Let's create a new handover.

What are you working on? (One-line summary)

User: Implementing JWT authentication for the API

Claude: Great. What's the goal or motivation for this work?

User: Need secure authentication before public launch

Claude: Where did you leave off?

User: Completed the login endpoint, need to finish logout

Claude: What should happen when you resume?

User: 1. Implement logout endpoint
      2. Add refresh token handling

Claude: Are there any blockers preventing progress?

User: Need to decide on refresh token storage strategy

Claude: Which files are this work in?

User: api/auth.ts lines 45-89

Claude: ✓ Created: sessions/2026-02-02-jwt-auth-implementation.md

Next steps:
1. Edit the file to add any additional notes
2. Update status as you work
3. Archive when complete: /llmc-handover archive jwt-auth-implementation
```

## Assets

- `scripts/new-handover.sh` - Script for creating handovers
- `scripts/update-handover.sh` - Script for updating handovers
- `scripts/archive-handover.sh` - Script for archiving handovers

## See Also

- `rules/llmc-session-continuity.md` - When to create handovers
- `commands/llmc-new-handover.md` - Non-interactive command
- `commands/llmc-archive.md` - Non-interactive archival
- `sessions/TEMPLATE.md` - Handover template
