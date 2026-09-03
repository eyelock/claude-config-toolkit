---
name: toolkit-agents
description: Reference guide for authoring Claude Code subagents in this toolkit — required/optional frontmatter fields, common patterns (read-only advisor, interactive helper, implementation agent), and how the isolated-context execution model actually works. Use when creating or reviewing an agents/toolkit-*.md file.
---

# Toolkit Agent Standards

When working with Toolkit agents, follow these conventions for Claude Code subagent compatibility.

## What Are Agents?

**Agents are invocable AI specialists** that Claude delegates to when it needs expert guidance or focused task execution.

Unlike other artifact types:
- **Commands** execute bash operations (one-shot)
- **Skills** provide interactive workflows *or* passive reference guidance (user-invoked or Claude-invoked, progressive disclosure)
- **Plans** document decisions (reference material)
- **Agents** are delegated to by Claude (isolated-context specialists)

## Required Structure

Agents **MUST** use this format:

```yaml
---
name: agent-name
description: When Claude should delegate to this subagent
tools: Read, Grep, Glob  # Optional - restricts tools
model: sonnet            # Optional - defaults to inherit
---

System prompt content here describing the agent's expertise and behavior.
```

### Required Fields

**`name`** (required)
- Unique identifier using lowercase and hyphens
- Example: `toolkit-architecture`, `toolkit-workflows`

**`description`** (required)
- Clear explanation of when Claude should delegate to this agent
- Claude uses this to decide when to invoke the agent
- Be specific about the agent's domain and use cases
- Can include "Use proactively" to encourage delegation

### Optional Fields

**`tools`** (optional)
- Comma-separated list of allowed tools
- If omitted, inherits all tools from main conversation
- Common patterns:
  - Read-only: `Read, Grep, Glob` (for exploration/guidance)
  - Read-write: `Read, Edit, Write, Bash` (for implementation)
  - Minimal: `Read` (pure consultation)

**`model`** (optional)
- Which AI model to use: `sonnet`, `opus`, `haiku`, `fable`, a full model id, or `inherit`
- Default: `inherit` (uses same model as main conversation)
- Resolution order: invocation param → frontmatter → env var (`CLAUDE_CODE_SUBAGENT_MODEL`) → main model
- Guidelines:
  - `haiku` - Fast, cheap, good for simple guidance
  - `sonnet` - Balanced, good for most agents
  - `opus` - Most capable, use sparingly (expensive)
  - `inherit` - Match main conversation model

**`permissionMode`** (optional)
- One of `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`, `manual`
- Only honored for project/user/managed/`--agents`-defined subagents — a plugin-packaged agent has this stripped for security, so don't rely on it once an agent ships inside a plugin.

## Toolkit Agent Patterns

### Pattern 1: Read-Only Advisor

**Use case:** Expert guidance without code changes

```yaml
---
name: toolkit-architecture
description: Expert guidance on Toolkit architecture and design decisions. Use when users need to understand the system structure.
tools: Read, Grep, Glob
model: inherit
---

You are an expert in Toolkit architecture...
```

**Best for:** Documentation agents, architecture guides, concept explainers

### Pattern 2: Interactive Helper

**Use case:** Multi-step guidance with questioning

```yaml
---
name: toolkit-planning-guide
description: Guide contributors through exploring and comparing approaches before committing to a plan. Use when users want to think through a design decision.
tools: Read, Grep, Glob
model: sonnet
---

You help contributors think through Toolkit design decisions...
```

**Best for:** Workflow guides, decision helpers, onboarding

### Pattern 3: Implementation Agent

**Use case:** Actually modifies code/files

```yaml
---
name: toolkit-generator
description: Generate new Toolkit artifacts from templates. Use when creating commands, skills, or agents.
tools: Read, Write, Edit, Bash
model: sonnet
---

You generate Toolkit artifacts following established patterns...
```

**Best for:** Generators, refactoring tools, code modifiers

## Agents vs Other Artifacts

### When to Use an Agent

✅ **Use agents when:**
- Claude needs expert domain knowledge during a task
- Guidance applies across multiple contexts
- You want to isolate verbose operations (keeps main context clean)
- The expertise should be available proactively
- You need to enforce tool restrictions

❌ **Don't use agents when:**
- User needs to invoke it directly → Use **Skill** instead
- It's a one-shot operation → Use **Command** instead
- It's passive reference material Claude should read on demand → Use a reference **Skill** instead
- It's a decision document → Use **Plan** instead

### Agent vs Skill: The Key Difference

**Agents:**
- Claude invokes them via the Task tool (background delegation)
- Run in a fresh, **isolated context window** per invocation — no conversation history carries over
- Only `name` + `description` are visible at session start, for delegation matching; the full system prompt loads only when actually invoked, and never dilutes the main thread
- Best for: Expert consultation, isolated tasks

**Skills:**
- User invokes them (e.g., `/toolkit-setup`), or Claude invokes them automatically based on `description`
- Progressive disclosure (only full content loads on invocation; once loaded it persists in the *current* session's context, unlike an agent's isolated one)
- Can be interactive Q&A with the user, or pure reference material Claude reads and applies silently
- Best for: Setup wizards, decision trees, multi-step workflows, and standards/conventions documentation

**Example:**
- ❌ Agent: "Interactive setup wizard" → Should be a **Skill**
- ✅ Agent: "Architecture expert Claude consults" → Correct

## Description Best Practices

The `description` field controls when Claude delegates. Make it specific:

**Good descriptions:**
```yaml
description: Expert guidance on Toolkit architecture, design decisions, and component relationships. Use when users need to understand the system structure.
```

**Bad descriptions:**
```yaml
description: Helps with stuff  # Too vague
description: Toolkit expert     # What domain?
```

**Include "Use proactively"** if the agent should act without being asked:
```yaml
description: Validate Toolkit artifact frontmatter. Use proactively after creating or editing artifacts.
```

## Tool Access Guidelines

**Read-only agents** (most Toolkit agents):
```yaml
tools: Read, Grep, Glob
```
Use for: Guidance, documentation, architecture advice

**Read-write agents** (generators, modifiers):
```yaml
tools: Read, Write, Edit, Bash
```
Use for: Creating artifacts, modifying files, running validations

**Minimal agents** (pure consultation):
```yaml
tools: Read
```
Use for: Answering questions from existing content only

## Model Selection Guidelines

**Default: `inherit`**
- Most Toolkit agents should use this
- Matches main conversation quality/cost

**Use `haiku`:**
- Simple lookups or references
- When speed matters more than sophistication
- Cost-sensitive operations

**Use `sonnet`:**
- When you need consistent quality regardless of main conversation model
- Complex reasoning or synthesis
- Standard Toolkit recommendation

**Use `opus`:**
- Rarely needed for Toolkit agents
- Only for exceptionally complex tasks

## Validation Checklist

Before committing an agent, verify:

- [ ] Has YAML frontmatter with `---` delimiters
- [ ] `name` field matches filename (without `.md`)
- [ ] `description` is specific and clear
- [ ] `tools` field only includes necessary tools
- [ ] `model` field uses valid value or omitted
- [ ] System prompt is clear about agent's role
- [ ] Filename follows `toolkit-` namespace convention

## Location and Distribution

**Toolkit maintainers:**
- Agents in: `agents/toolkit-*.md`
- Install with: `make install` (symlinks to `~/.claude/agents/`)
- Restart Claude Code to load changes

**Project developers:**
- Agents in: `.claude/agents/` (via submodule)
- Automatically loaded at session start
- No manual installation needed

## See Also

- Claude Code documentation: https://code.claude.com/docs/en/sub-agents
- `agents/toolkit-architecture.md` - Example agent
- `/toolkit-choose-artifact` - Choosing right artifact type
- `skills/toolkit-frontmatter-standards/SKILL.md` - General frontmatter conventions
