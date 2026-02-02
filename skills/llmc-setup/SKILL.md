---
name: llmc-setup
description: Frictionless setup - detects your context (LLMC repo, project with LLMC, or new project) and sets up the right workspace structure automatically.
---

# LLMC Frictionless Setup

**One command:** "Set me up with Claude in here with LLMC"

Automatically detects your context and does the right thing.

## What This Does

Detects three scenarios and sets up accordingly:

**1. LLMC Maintainer** (you're IN the LLMC repo)
- Creates `sessions/` and `plans/` at root
- Offers user-level install to `~/.claude/` (optional)

**2. Team Member** (project has `.claude/` submodule)
- Creates `.claude/sessions/` and `.claude/plans/`
- Suggests `/llmc-choose-artifact` to start experimenting

**3. New Project** (no LLMC yet)
- Offers to add LLMC as git submodule
- Creates `.claude/sessions/` and `.claude/plans/`

## Usage

```
/llmc-setup
```

The skill will auto-detect and confirm before proceeding.

## Implementation

When invoked, this skill runs the `scripts/setup.sh` script included as an asset in this directory.

The script:
1. Detects your context (LLMC repo, project with LLMC, or new project)
2. Shows what it will create and asks for confirmation
3. Creates appropriate directory structures
4. Generates README, TEMPLATE, and .gitignore files
5. Provides context-specific next steps

## Assets

- `scripts/setup.sh` - Frictionless setup script with context detection

## See Also

- `/llmc-choose-artifact` - Create your first experiment
- `/llmc-promote` - Promote experiments to team level
- `/llmc-new-handover` - Create session handover
- `rules/llmc-workspace-separation.md` - Philosophy
