---
name: toolkit-new-settings
description: Guide to a team's .claude/settings.json — permission allow/ask/deny rules, statusLine, model/outputStyle pinning, and the split between committed settings.json and gitignored settings.local.json. Use when a team wants to share runtime config, not just docs.
---

# Toolkit Settings Starter

`.claude/settings.json` is runtime config, not documentation — the fifth shareable category alongside commands/skills/agents/plans. It's a direct parallel to this toolkit's existing workshop-vs-product split, just applied to Claude Code's own behavior instead of your files:

- **`.claude/settings.json`** (committed): team-shared config everyone gets automatically.
- **`.claude/settings.local.json`** (gitignored): personal overrides — your own permission grants, your own statusline tweaks.

## Template

`skills/toolkit-new-settings/templates/settings.json.example`:

```json
{
  "model": "sonnet",
  "outputStyle": "Default",
  "statusLine": {
    "type": "command",
    "command": "$CLAUDE_PROJECT_DIR/skills/toolkit-new-settings/scripts/statusline.sh"
  },
  "permissions": {
    "allow": ["Bash(git status)", "Bash(git diff *)", "Bash(git log *)", "Bash(make test)", "Bash(make validate)"],
    "ask": ["Bash(git push *)"],
    "deny": ["Bash(git push --force *)", "Read(./.env)", "Read(./.env.*)"]
  }
}
```

`skills/toolkit-new-settings/scripts/statusline.sh` is a working example `statusLine` command — reads the piped session JSON, prints the model name and current git branch.

## What goes in each key

- **`permissions.allow` / `.ask` / `.deny`** — always-allow commands the team already trusts (read-only git, your test/validate targets), commands that should always prompt (force-push), and commands/paths that should always be blocked (secrets).
- **`statusLine`** — a `command`-type entry pointing at a script that reads session JSON from stdin and prints a status line.
- **`model` / `outputStyle`** — pin a team default; individual contributors can still override in their own `settings.local.json`.

## Copying this in

1. Copy the template to `.claude/settings.json` in your project.
2. Trim the example `permissions` rules down to your team's actual trusted commands — don't ship someone else's allowlist unreviewed.
3. Commit it. Anything personal goes in `.claude/settings.local.json` instead (already gitignored by Claude Code's defaults).

## See Also

- Claude Code Settings Reference: https://code.claude.com/docs/en/settings
- `skills/toolkit-new-output-style/SKILL.md` - Writing a custom `outputStyle`
