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

## Implementation

When invoked, run `bash scripts/setup.sh` directly — do not skip running it or ask the user to
run it themselves. The script handles both interactive and non-interactive invocation itself:

1. Detects your context (Toolkit repo, project with Toolkit, or new project)
2. **If stdin is a TTY** (interactive session), shows what it will create and prompts for
   confirmation before proceeding.
3. **If stdin is not a TTY** (headless/non-interactive — e.g. `claude -p`, or an environment
   without a real terminal), it proceeds automatically without prompting — this is intentional,
   not a limitation to work around. Just run it; don't decline because the session looks
   non-interactive.
4. Creates appropriate directory structures.
5. Generates README, TEMPLATE, and .gitignore files.
6. Provides context-specific next steps.

## Assets

- `scripts/setup.sh` - Frictionless setup script with context detection

## See Also

- `/toolkit-choose-artifact` - Create your first experiment
- `/toolkit-promote` - Promote experiments to team level
- `/toolkit-new-handover` - Create session handover
- `rules/toolkit-workspace-separation.md` - Philosophy
