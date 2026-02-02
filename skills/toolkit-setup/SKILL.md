---
name: toolkit-setup
description: Frictionless setup - detects your context (Toolkit repo, project with Toolkit, or new project) and sets up the right workspace structure automatically.
---

# Toolkit Frictionless Setup

**One command:** "Set me up with Claude in here with Toolkit"

Automatically detects your context and does the right thing.

## What This Does

Detects three scenarios and sets up accordingly:

**1. Toolkit Maintainer** (you're IN the Toolkit repo)
- Creates `sessions/` and `plans/` at root
- Offers user-level install to `~/.claude/` (optional)

**2. Team Member** (project has `.claude/` submodule)
- Creates `.claude/sessions/` and `.claude/plans/`
- Suggests `/toolkit-choose-artifact` to start experimenting

**3. New Project** (no Toolkit yet)
- Offers to add Toolkit as git submodule
- Creates `.claude/sessions/` and `.claude/plans/`

## Usage

```
/toolkit-setup
```

The skill will auto-detect and confirm before proceeding.

## Implementation

When invoked, this skill runs the `scripts/setup.sh` script included as an asset in this directory.

The script:
1. Detects your context (Toolkit repo, project with Toolkit, or new project)
2. Shows what it will create and asks for confirmation
3. Creates appropriate directory structures
4. Generates README, TEMPLATE, and .gitignore files
5. Provides context-specific next steps

## Assets

- `scripts/setup.sh` - Frictionless setup script with context detection

## See Also

- `/toolkit-choose-artifact` - Create your first experiment
- `/toolkit-promote` - Promote experiments to team level
- `/toolkit-new-handover` - Create session handover
- `rules/toolkit-workspace-separation.md` - Philosophy
