# Why Top-Level Directories (sessions/ and plans/)

## The Design

Two top-level directories for workspace:

```
sessions/              # Session continuity
plans/                 # Working plans
```

## The Rationale

**Simplicity and clarity over abstraction.**

**Benefits:**
- ✅ Clear, descriptive names (no abbreviations, no nesting)
- ✅ Simpler mental model (fewer directories to navigate)
- ✅ Aligned with Claude Code conventions
- ✅ Same pattern works in both config repo and project repo
- ✅ Obvious what goes where

## Key Insight

**The directories serve the same purpose in two contexts:**

1. **Config repo:** Workspace for developing Toolkit configs
2. **Project repo:** Workspace for using Toolkit to build projects

By using top-level directories with clear names, the pattern is obvious in both contexts.

## Git-Ignore Pattern

```gitignore
# Track structure, ignore content
sessions/*.md
!sessions/README.md
!sessions/TEMPLATE.md

plans/*.md
!plans/README.md
!plans/TEMPLATE.md
```

This gives you:
- Physical directories (for structure)
- README files (for documentation)
- Template files (for consistency)
- Git-ignored content (for privacy)

## Why Not Nested Under .claude/?

**Because `.claude/` is for team-shared configs, not personal workspace.**

Putting `sessions/` or `plans/` under `.claude/` would:
- Mix team configs with personal workspace
- Conflict with submodule management (`.claude/` is often a git submodule)
- Create confusion about what's tracked vs ignored

**Better:** Keep workspace separate at top level - unambiguous and clear.

## The Principle

**Flat is better than nested** - when nesting doesn't add value, keep it flat.

The top-level directories clearly signal: "This is workspace, not team artifacts."
