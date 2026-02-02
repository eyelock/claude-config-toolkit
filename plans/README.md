# Plans Directory

**Purpose:** Working plans and exploration documents - your thinking space.

## What Goes Here

Planning documents with the pattern: `YYYY-MM-DD-topic.md`

**Example:** `2026-02-01-auth-approach.md`

## Why This Exists

Before implementing features, you need space to:

- Explore multiple approaches
- Compare tradeoffs
- Draft implementation strategies
- Get feedback on direction

This directory is that space - messy thinking is encouraged.

## Git Status

**Content is git-ignored** - these are your personal working drafts, not team documentation.

The directory itself exists in the repo (so the structure is clear), but the `.md` files you create are ignored via `.gitignore`.

## Frontmatter Structure

```yaml
---
created: "2026-02-01"
status: "exploring|decided|abandoned|graduated"
context: "Brief description of what this plan addresses"
approaches:
  - "Approach 1: Description"
  - "Approach 2: Description"
related_to: []           # Other plans or sessions
last_updated: "2026-02-01"
---
```

## Typical Workflow

### 1. Exploration Phase
Create a plan to explore options:
```bash
cp plans/TEMPLATE.md plans/2026-02-01-auth-strategy.md
```

Document:
- Problem statement
- Multiple approaches (don't commit yet!)
- Pros/cons of each
- Open questions

Status: `exploring`

### 2. Decision Phase
After discussion, pick an approach:
- Update plan with chosen approach
- Document why
- Add implementation steps

Status: `decided`

### 3. Graduation Phase
When ready to share with team:

**Option A - Using Toolkit:**
```
/toolkit-graduate 2026-02-01-auth-strategy
```

**Option B - Manual:**
```bash
# Rename and commit the plan
mv plans/2026-02-01-auth-strategy.md plans/auth-strategy.md
git add plans/auth-strategy.md
git commit -m "docs: add auth strategy plan"
```

This moves it from git-ignored draft → git-tracked team documentation.

Status: `graduated`

### 4. Implementation
Now the plan is in `plans/` (git-tracked), the team can:
- Review it in PRs
- Reference it in commits
- Update it as implementation evolves

**Note:** In projects using Toolkit as a submodule, committed plans appear as `.claude/plans/` (since the entire repo becomes `.claude/`).

## What This Is NOT

- ❌ Session continuity docs (use `sessions/` for that)
- ❌ Uncommitted drafts forever (commit when ready for team)
- ❌ Code or implementation (plans document approach, not code)

## Cleanup

Plans that didn't pan out:
```bash
# Mark as abandoned in frontmatter, or delete
rm plans/2026-01-*-abandoned-*.md
```

Plans that graduated:
```bash
# Leave them or archive
mkdir -p plans/archive/2026-01
mv plans/2026-01-*.md plans/archive/2026-01/
```

## Related

- `sessions/` - Session continuity handovers
- `TEMPLATE.md` - Starting template for new plans
- Git commit - How plans "graduate" (from ignored draft → tracked team doc)
