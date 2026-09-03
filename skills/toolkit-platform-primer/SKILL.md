---
name: toolkit-platform-primer
description: Primer on Claude Code platform capabilities this toolkit doesn't otherwise document — auto memory, checkpoints/rewind, sandboxed Bash, fork vs. isolated subagents, background sessions, effort levels, /doctor, and claude import. Use when deciding whether a Toolkit convention overlaps with (or is superseded by) a built-in Claude Code feature.
---

# Claude Code Platform Primer

Claude Code has grown several session-level capabilities that this toolkit's own docs don't mention. Several of them overlap directly with problems Toolkit already solves by hand — know about both so you don't duplicate effort or give contributors stale advice.

## Auto Memory — a second persistence layer

Claude Code maintains its own persistent memory files per project (`user` / `feedback` / `project` / `reference` types), written and loaded automatically across sessions, separate from CLAUDE.md.

**How it relates to Toolkit:** this is distinct from — and complementary to — `sessions/*.md` handover docs. Auto memory is Claude's own notes about *you and the project* (preferences, recurring feedback, project facts); a handover is a human-curated snapshot of *where a specific task left off*, meant to be read by a person or handed to a fresh Claude instance explicitly. Don't ask contributors to duplicate one in the other.

## Checkpoints / `/rewind`

The 100 most recent prompts can be rewound (file state, conversation, or both) without needing a manual git commit first.

**How it relates to Toolkit:** doesn't replace `git commit` for anything you want durable or shared, but it's a real safety net for exploratory work in `plans/` or `sessions/` before you'd normally bother committing.

## Sandboxed Bash

OS-enforced isolation (Seatbelt on macOS, seccomp-style on Linux), configured via `/sandbox`, lets routine commands run without a permission prompt each time.

**How it relates to Toolkit:** complements a project's `.claude/settings.json` allow/ask/deny rules — sandboxing reduces prompt friction for the commands you'd otherwise have to explicitly allow.

## Fork subagents vs. isolated subagents

Default subagents (see `skills/toolkit-agents/SKILL.md`) run in a fresh, isolated context per invocation — no conversation history. **Fork mode** (`/subtask`, `context: fork` in skill/agent frontmatter) instead inherits the parent's full context, history, and tools, and is the default execution mode for background subagents in interactive sessions.

**How it relates to Toolkit:** neither model is "loaded at start, dilutes over hours" — that description doesn't apply to either execution model. If you're documenting agent behavior, be specific about which mode you mean.

## Background sessions (`claude agents`, `--bg`)

Supervised, parallel background sessions with an attach/logs/stop/respawn/rm lifecycle — a different thing from Task-tool subagents.

**How it relates to Toolkit:** don't conflate this with the toolkit's "Agent" artifact type. An artifact-type Agent is a reusable, invocable specialist defined in `agents/*.md`; a background session is a live, running instance of Claude doing a task in parallel.

## Effort levels

`low` / `medium` / `high` / `xhigh` / `max` — a distinct axis from model choice. Settable per-session, and per-subagent via the `effort:` frontmatter field, or per-skill.

**How it relates to Toolkit:** when writing agent/skill-creation guidance, mention `effort` alongside `model` — they're independent knobs.

## `/doctor`

A bundled skill that inspects session health and can propose CLAUDE.md trims.

**How it relates to Toolkit:** directly useful for the context-dilution problem this toolkit's own README already flags for Skills and Agents. Point contributors at `/doctor` as a built-in diagnostic, in addition to the workspace-separation pattern in `skills/toolkit-workspace-separation/SKILL.md`.

## `claude import`

One-time migration of AGENTS.md, and Cursor/Copilot/Windsurf/Devin/Cline configs, into Claude Code equivalents.

**How it relates to Toolkit:** useful for the "Team Member" onboarding scenario in the README when a project already has non-Claude agent config in place — mention it as an option before a contributor hand-migrates anything.

## See Also

- Claude Code docs: https://code.claude.com/docs/en/cli-reference, https://code.claude.com/docs/en/sub-agents, https://code.claude.com/docs/en/settings
- `skills/toolkit-agents/SKILL.md` - Subagent frontmatter and the isolated-context execution model
- `skills/toolkit-workspace-separation/SKILL.md` - Where Toolkit's own workspace pattern does and doesn't overlap with built-ins
