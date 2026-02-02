---
name: toolkit-new-plan
description: Create a new working plan from template with proper frontmatter and structure. Use when users want to start exploring a new idea or architectural decision.
---

# Toolkit New Plan Creator

Create working plans following Toolkit conventions - date-first naming, proper frontmatter, template structure for exploring approaches.

## Usage

```
/toolkit-new-plan
```

The skill will prompt you for:
1. **Plan description** - Brief topic (e.g., "auth-approaches")
2. **Context** (optional) - What problem you're solving

It creates: `plans/YYYY-MM-DD-description.md`

## What It Does

1. **Prompts for details:**
   - Description/topic (required)
   - Context (optional)

2. **Generates plan file:**
   - Name: `plans/YYYY-MM-DD-{description}.md`
   - Frontmatter with required fields
   - Template sections ready to fill

3. **Provides next steps:**
   - How to fill in approaches
   - When to graduate the plan
   - Reminder that it's git-ignored (explore freely!)

## What You Get

A working plan with:
- ✅ Date-first filename (`2026-02-02-your-topic.md`)
- ✅ Proper frontmatter (snake_case fields)
- ✅ Template structure (Problem, Approaches, Rough Notes, Decision)
- ✅ Git-ignored by default (safe to be messy)

## After Creation

1. **Explore approaches** - Fill in pros/cons, ask questions
2. **Be messy** - This is thinking space, not presentation
3. **Graduate when ready** - `/toolkit-graduate YYYY-MM-DD-description`

## Related

- `/toolkit-graduate` - Promote plan to formal documentation
- `plans/TEMPLATE.md` - Template structure
- `rules/toolkit-frontmatter-standards.md` - Metadata standards
- `rules/toolkit-naming-conventions.md` - Naming conventions
- `agents/toolkit-planning-guide` - Planning workflow guidance

## Implementation

This skill runs `scripts/new-plan.sh` which handles:
- Date generation
- Filename creation
- Template population
- Directory detection (plans/ or .claude/plans/)
- Validation
