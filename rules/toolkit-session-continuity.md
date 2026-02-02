# Toolkit Session Continuity

Session handovers bridge the gap between stateless AI conversations. Follow these practices:

## When to Write Handovers

**ALWAYS create a handover when:**
- ✅ Pausing work mid-stream
- ✅ Switching contexts (working on multiple things)
- ✅ Complex multi-session work
- ✅ Need to resume later (possibly different Claude instance)

**DON'T create handovers for:**
- ❌ Completed work (write a summary in `sessions/` and commit it for team)
- ❌ Simple one-off tasks
- ❌ Just reading/learning (no state to preserve)

## Handover Quality

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

## Naming

Use the standard date-first pattern:
```
sessions/YYYY-MM-DD-description.md
```

Make description specific:
```
✅ 2026-02-02-auth-api-implementation.md
✅ 2026-02-05-bug-user-login-timeout.md

❌ 2026-02-02-work.md                    # Too vague
❌ 2026-02-02-stuff.md                   # Too vague
```

## Session Linking

Link related sessions using frontmatter:

```yaml
---
session_id: "2026-02-02-auth-implementation"
previous_session: "2026-02-01-auth-planning"
continued_in: ""  # Fill when you continue
---
```

This creates a chain:
```
2026-02-01-auth-planning.md
    ↓ (previous_session)
2026-02-02-auth-implementation.md
    ↓ (previous_session)
2026-02-03-auth-testing.md
```

## Resuming Work

**To resume:**
1. Read the handover document
2. Give it to Claude: "Read `sessions/2026-02-02-auth.md` and continue"
3. Claude picks up where you left off

**Example:**
```
You: "Claude, read sessions/2026-02-02-auth-api.md and continue"

Claude: "I see we were implementing the JWT authentication API. We completed
         the login endpoint (api/auth.ts:45-89) but the logout endpoint still
         needs implementation. Shall I continue with the logout endpoint?"
```

## Archival

Archive handovers when work is complete:

**Option 1: Archive folder (recommended)**
```bash
mv sessions/2026-02-01-feature.md \
   sessions/archive/2026-02/
```

**Option 2: Suffix**
```bash
mv sessions/2026-02-01-feature.md \
   sessions/2026-02-01-feature-DONE.md
```

**Option 3: Helper command**
```bash
/toolkit-archive  # Uses command to archive automatically
```

## Status Progression

Handover status should progress:

```
draft → in_progress → paused → completed
                           ↓
                       archived
```

**Don't leave completed handovers active.** Archive them to keep workspace clean.

## The Goal

**Session continuity means:**
- ✅ You can pause work anytime without losing context
- ✅ Different Claude instances can resume your work
- ✅ Multi-day projects maintain momentum
- ✅ Context is explicit, not in your head

**If handovers feel like busywork, they're not working.** They should feel like a helpful colleague briefing you.
