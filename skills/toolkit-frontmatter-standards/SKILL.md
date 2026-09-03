---
name: toolkit-frontmatter-standards
description: Frontmatter conventions for Toolkit workspace files (sessions, plans, scripts) and for SKILL.md itself — including which SKILL.md fields are portable across Agent Skill vendors (the agentskills.io spec) versus Claude Code-only extensions. Use when writing or reviewing frontmatter for any Toolkit artifact or workspace file.
---

# Toolkit Frontmatter Standards

Frontmatter conventions split into two groups: workspace files (sessions/plans/scripts, Toolkit-specific) and SKILL.md (spec-governed, cross-vendor).

## SKILL.md Frontmatter: Portable vs. Claude Code-Only

Agent Skills follow an open, cross-vendor standard ([agentskills.io](https://agentskills.io)). Claude Code implements that standard and adds its own extensions on top. **Other vendors that load Agent Skills (or claude.ai's own Skill upload, or the Skills API) may ignore or reject any field outside the portable subset** — an unrecognized field doesn't necessarily break loading everywhere, but you can't rely on it doing anything outside Claude Code, and some loaders may be stricter than others.

**Portable — part of the agentskills.io spec, safe on any vendor:**

| Field | Purpose |
|-------|---------|
| `name` | Skill identifier |
| `description` | When/why to use this skill — the only field most vendors require |
| `license` | SPDX license identifier |
| `compatibility` | Declared compatibility constraints |
| `metadata` | Free-form key/value map |
| `allowed-tools` | Tool grants scoped to this skill |

**Claude Code-only extensions — will be ignored or rejected by other vendors' loaders:**

| Field | Purpose |
|-------|---------|
| `argument-hint` | Shown in `/help` for invocation hints |
| `arguments` | Named positional args with `$name` substitution |
| `disable-model-invocation` | Manual-only — Claude won't auto-invoke |
| `user-invocable` | When `false`, only Claude can invoke (not the user) |
| `disallowed-tools` | Tool removal scoped to this skill |
| `model` | Pin a specific model for this skill's invocations |
| `effort` | Pin an effort level (`low`/`medium`/`high`/`xhigh`/`max`) |
| `context: fork` (+ `agent`, `background`) | Run this skill as a forked subagent |
| `hooks` | Session-scoped hooks registered on invoke |
| `paths` | Glob-gated auto-activation for nested skills |
| `shell` | `bash` or `powershell` for inline `` !`cmd` `` execution |

**Rule of thumb:** if a skill is meant to work identically wherever Agent Skills are supported (shared publicly, uploaded to claude.ai, used across tools), stick to the portable subset. If a skill is Claude Code-specific by design (uses `context: fork`, pins a `model`, registers `hooks`), that's fine — just don't expect it to behave the same, or load at all in a strict vendor, elsewhere.

Toolkit's own `skills/toolkit-*` skills currently use only `name` + `description` — fully portable by default.

## Workspace File Frontmatter (sessions, plans, scripts)

**Always use `snake_case` for all frontmatter fields.**

```yaml
✅ session_id: "2026-02-02-feature"
✅ previous_session: "2026-02-01-setup"
✅ last_updated: "2026-02-02"
✅ safe_to_run: true

❌ sessionId: "..."      # camelCase - wrong
❌ SessionID: "..."      # PascalCase - wrong
❌ session-id: "..."     # kebab-case - wrong
```

### Required Fields by Type

**Handover Files (`sessions/*.md`)**

Required:
- `session_id` - Unique identifier (YYYY-MM-DD-description)
- `context` - One-line summary
- `status` - Current state (in_progress | paused | blocked | completed)

Optional but recommended:
- `previous_session` - Chain backwards
- `continued_in` - Chain forwards
- `next_steps` - Actionable items for resume
- `related_files` - Files touched this session
- `blockers` - What's blocking progress
- `last_updated` - Track when updated

**Working Plans (`plans/*.md`)**

Required:
- `created` - Creation date (YYYY-MM-DD)
- `status` - Current state (draft | in_progress | ready | archived)
- `context` - Why exploring this

Optional but recommended:
- `last_updated` - Track updates
- `related_to` - Link to formal plan if graduated
- `approaches` - List approaches being considered

**Scripts (`*.sh`)**

Required (in comments):
- `type` - Script category
- `safe_to_run` - Safety indicator (true | false)
- `description` - What it does

Optional:
- `created` - Creation date
- `last_run` - Last execution date
- `requires` - Dependencies
- `created_during_session` - Link to handover

### Date Format

All date fields use `YYYY-MM-DD` format:

```yaml
✅ created: "2026-02-02"
✅ last_updated: "2026-02-02"

❌ created: "02-02-2026"     # Wrong order
❌ created: "2/2/2026"       # Wrong format
❌ created: "Feb 2, 2026"    # Wrong format
```

### Why These Standards?

**Consistency:** Same patterns across all file types
**Tooling:** Enables automated validation and processing
**Readability:** Clear, predictable structure
**LLM-friendly:** Models understand structured metadata better

## See Also

- [agentskills.io](https://agentskills.io) - The cross-vendor Agent Skills spec
- Claude Code Skills docs: https://code.claude.com/docs/en/skills
- `skills/toolkit-naming-conventions/SKILL.md` - File naming conventions
