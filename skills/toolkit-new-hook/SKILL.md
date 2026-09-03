---
name: toolkit-new-hook
description: Guide to writing Claude Code hooks — deterministic enforcement at lifecycle events (PreToolUse, PostToolUse, SessionStart, and others), as opposed to a Skill or reference doc Claude has to remember to consult. Use when a team wants a rule enforced automatically rather than followed on request.
---

# Toolkit Hooks Starter

Hooks are shell commands Claude Code runs at lifecycle events. Where a Skill says "please do X" and hopes Claude reads it, a hook makes X happen — or blocks the alternative — every time, deterministically.

## When to reach for a hook instead of a Skill

- **Skill**: guidance Claude should apply with judgment ("here's how we name things, here's the tradeoff").
- **Hook**: a rule with no judgment call — always block this, always run this after that. If you find yourself writing "ALWAYS do X" or "NEVER do Y" in a Skill, ask whether a hook would enforce it instead of just asking for it.

## This repo's starter example

`hooks/hooks.json` wires two hooks:

- **`PreToolUse` on `Edit|Write`** → `hooks/scripts/block-protected-files.sh` — blocks edits to a configurable protected-files list (`.env`, `*.pem`, `*.key`, `secrets/*` by default), exiting `2` to block with a stderr reason Claude sees.
- **`PostToolUse` on `Edit|Write`** → `hooks/scripts/lint-changed-file.sh` — best-effort lints the file Claude just touched (shellcheck for `.sh`, JSON validation for `.json`); degrades silently if the file type isn't handled or the tool isn't installed.

Both scripts read the hook's JSON payload from stdin and pull `tool_input.file_path` out of it — that's the shape every `Edit`/`Write` hook payload has.

## Where hooks live

- **Project-level:** a `hooks` key inside `.claude/settings.json` (or `.claude/settings.local.json` for personal-only hooks) — the format is the same nested `{"hooks": {"EventName": [{"matcher": ..., "hooks": [...]}]}}` shape as this repo's `hooks/hooks.json`.
- **Plugin-level:** `hooks/hooks.json` at the plugin root, exactly as this repo has it — once Toolkit ships as a native plugin (see the plugin-manifest work), this file is picked up automatically for anyone who installs it.

## Writing your own

1. Pick the event (`PreToolUse` to gate/block, `PostToolUse` to react after, `SessionStart` to inject context, etc.) — see the Hooks Guide link below for the full event list.
2. Pick a `matcher` — usually a tool name or `|`-separated set (`Edit|Write`, `Bash`, …).
3. Write a `command` hook script: read stdin as JSON, exit `0` to allow/continue or `2` to block (PreToolUse only) with your reason on stderr.
4. Test it directly: `echo '{"tool_input":{"file_path":"test.env"}}' | hooks/scripts/block-protected-files.sh; echo $?`

## See Also

- Claude Code Hooks Guide: https://code.claude.com/docs/en/hooks-guide
- `skills/toolkit-agents/SKILL.md` - Frontmatter can also register hooks scoped to a single agent's invocation
