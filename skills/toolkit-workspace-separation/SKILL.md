---
name: toolkit-workspace-separation
description: Explains the workshop-vs-product split between git-ignored sessions/plans/ and git-tracked commands/skills/agents/, and the graduation flow for promoting a draft plan to team-shared. Use when deciding where a new file belongs or whether to commit a plan.
---

# Toolkit Workspace Separation

The Toolkit workspace uses git-ignored working directories for development. Follow these rules:

## The Structure

### Working Directories (git-ignored content)

**`sessions/` - Session Continuity**
- ✅ Handovers for resuming work across conversations
- ✅ Session notes and context
- ✅ Temporary scripts or artifacts
- ❌ NEVER: Team-ready configs, production code

**`plans/` - Planning Documents**
- ✅ Rough working plans (exploring options)
- ✅ Architecture exploration
- ✅ Design drafts
- ❌ NEVER: Final implementations (unless committed)

**Quality bar:** Messy is OK. This is thinking space.

**Git status:** Ignored content (except README.md and TEMPLATE.md)

### Root Level - Team Product (git-tracked)

**What goes here:**
- ✅ Commands for team use (`commands/`)
- ✅ Skills for team use (`skills/`) — both interactive workflows and reference/standards docs
- ✅ Agents for team use (`agents/`)
- ✅ Polished documentation

**What NEVER goes here:**
- ❌ Rough drafts (use plans/)
- ❌ Personal notes (use sessions/)
- ❌ Experimental code (use sessions/)
- ❌ Work-in-progress (use plans/ or sessions/)

**Quality bar:** Polished, team-ready, production-quality.

**Git status:** Tracked and distributed to team via submodule.

## The Graduation Flow

Plans can be committed to git when ready:

```
plans/2026-02-02-rough-idea.md    # Exploring 3 approaches (git-ignored)
    ↓ Decision made
    ↓ Polish & remove rejected options
    ↓ git add & commit
    ↓
plans/final-idea.md is now tracked  # Team gets it via submodule
```

Or use `/toolkit-graduate <plan-name>` to rename and commit in one step.

## When to Commit Plans

**Commit plans to git when:**
- ✅ Decision made (no longer exploring)
- ✅ Content is polished (no rough notes)
- ✅ Ready for team review
- ✅ Actionable (clear next steps)

**DON'T commit if:**
- ❌ Still comparing approaches
- ❌ Has open questions
- ❌ Contains "I don't know..." notes
- ❌ Not ready for team eyes

## The Philosophy

> **Working directories (plans/, sessions/):** Be uncertain. Explore. Iterate. Mess is expected.
>
> **Product (root):** Be clear. Polished. Ready. Team depends on this.

The separation gives you **freedom to be messy** without cluttering team-shared configs.

## Examples

**Working plan (git-ignored):**
```markdown
# plans/2026-02-02-auth.md

## Approach 1: JWT
Pros: ...
Cons: ...
Questions: How do we handle refresh tokens? 🤔

## Approach 2: Sessions
Pros: ...
Cons: ...
Questions: Redis or in-memory? Not sure yet.

## Rough notes
- Need to research OAuth flows
- Talk to security team
- This might be overkill?
```

**Committed plan (git-tracked):**
```markdown
# plans/auth-implementation.md

## Approach: JWT with Refresh Tokens

Decision: JWT for authentication, httpOnly cookies for refresh tokens.

Implementation steps:
1. Add jwt library
2. Create /auth/login endpoint
3. Create /auth/refresh endpoint
4. Add middleware for protected routes
```

Notice the difference: **Messy → Clear. Uncertain → Decided. Rough → Polished.**

## See Also

- `/toolkit-graduate` - Promote a working plan to team-shared
- `skills/toolkit-session-continuity/SKILL.md` - When and how to write handovers
