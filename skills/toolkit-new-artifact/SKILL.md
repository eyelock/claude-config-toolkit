---
name: toolkit-new-artifact
description: Create Toolkit artifacts (agents, commands, skills, rules) with proper structure and frontmatter. Use when users want to contribute a new Toolkit artifact.
---

# Toolkit New Artifact Creator

Create Toolkit artifacts following conventions - proper frontmatter, naming patterns, templates.

## Usage

```
/toolkit-new-artifact
```

The skill will prompt you for:
1. **Artifact type** - Agent, Command, Skill, or Rule
2. **Name** - Without toolkit- prefix
3. **Description** - What it does
4. **Tool access** (agents only) - Read-only, Coordinator, or Write-capable

## Supported Types

**Currently implemented:**
- ✅ **Agents** - Full support with tool selection
- ✅ **Commands** - Bash executors

**Not automated:**
- ❌ **Skills** - Skills need a multi-file directory (`SKILL.md` + `scripts/` + `templates/`), which doesn't fit a single-file scaffold. Copy an existing skill as your starting point instead — `skills/toolkit-new-plan/` for a simple, single-script skill, or `skills/toolkit-handover/` for a skill with multiple bundled scripts.
- ❌ **Rules** - The Rule artifact type has other in-flight work on this repo; check for that before adding new `rules/` content by hand.

## What It Does (Agents)

1. **Prompts for details:**
   - Name (auto-adds toolkit- prefix)
   - Description
   - Tool access pattern

2. **Creates agent file:**
   - Proper frontmatter (name, description, tools, model)
   - Template structure with guidance sections
   - Ready to fill in with domain expertise

3. **Tool patterns:**
   - **Read-only:** `Read, Grep, Glob, Skill` (reference/guidance)
   - **Coordinator:** `Read, Grep, Glob, Bash, Skill` (workflow guide + git ops)
   - **Write-capable:** `Read, Write, Bash, Grep, Glob, Skill` (hands-on helper)

## What It Does (Commands & Rules)

Prompts for **name** and **description**, then creates a stub file with proper frontmatter (commands) or a standard heading structure (rules), ready for you to fill in the implementation/content. See `templates/command-template.md` and `templates/rule-template.md` for the exact shape.

## After Creation

1. **Edit the agent** - Add domain expertise and guidance
2. **Test it** - Restart Claude Code and test invocation
3. **Validate** - Run `make validate`
4. **Submit PR** - Share with team

## Related

- `/toolkit-choose-artifact` - Decide which artifact type to create
- `/toolkit-validate` - Validate frontmatter
- `rules/toolkit-agents.md` - Agent standards and patterns
- `rules/toolkit-frontmatter-standards.md` - Metadata standards
- `agents/toolkit-workflows` - Contribution workflow guidance

## Implementation

This skill runs `scripts/new-artifact.sh` which:
- Prompts for artifact details
- Detects directory location
- Creates file from template
- Validates naming conventions
- Provides next steps

**Status:** Agent and Command creation implemented. Skill and Rule scaffolding are manual (see "Not automated" above).
