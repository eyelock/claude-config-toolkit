---
name: toolkit-new-output-style
description: Guide to writing Claude Code output styles — a different layer than a Skill or CLAUDE.md, since it rewrites the system prompt itself (role/tone/format) for every response rather than adding a user-turn message. Use when a team wants to change Claude's overall voice or response format, not just add instructions.
---

# Toolkit Output Style Starter

An output style replaces or extends Claude's system prompt directly, changing tone, role, or response format for every reply — not just this session's task. That's a different layer than everything else in this toolkit:

- **CLAUDE.md / a reference Skill** adds instructions Claude reads and applies with judgment.
- **A hook** deterministically blocks or reacts to specific tool calls.
- **An output style** changes *how Claude talks*, globally, for the duration it's active.

Five built-ins ship with Claude Code: `Default`, `Proactive`, `Concise`, `Explanatory`, `Learning`. Write your own when none of those fit your team's house style.

## Template

`skills/toolkit-new-output-style/templates/terse-reviewer.md` is a worked example — a blunt, findings-only code-review persona:

```yaml
---
name: terse-reviewer
description: Blunt, high-signal code review persona — flags problems only, no praise, no restating the diff.
---

You are reviewing code changes. For every response: ...
```

The frontmatter is `name` + `description`; the body **is** the style's instructions — write it the way you'd write a system prompt, not a skill's how-to guide.

## Where output styles live

- **Personal:** `~/.claude/output-styles/*.md`
- **Project:** `.claude/output-styles/*.md` (or `output-styles/` at this repo's root, once it ships as a plugin)
- **Plugin:** `output-styles/*.md` at the plugin root — a plugin can force one via `force-for-plugin` in its manifest

## Switching styles

Use `/config` (the standalone `/output-style` command was deprecated in v2.1.73 and removed in v2.1.91) or set the `outputStyle` key directly in `.claude/settings.json`.

## See Also

- `skills/toolkit-new-settings/SKILL.md` - `.claude/settings.json` starter, including the `outputStyle` key
