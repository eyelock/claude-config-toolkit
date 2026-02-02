---
name: toolkit-choose-artifact
description: Interactive guide to help you choose the right Claude Code artifact type (command, skill, agent, rule, or plan) based on your needs. Asks targeted questions about purpose, interaction model, tool requirements, and context persistence to recommend the best fit.
---

# Choose the Right Artifact Type

**I'll help you decide whether to create a command, skill, agent, rule, or plan.**

This skill uses an interactive decision tree to understand your needs and recommend the right artifact type.

## Why This Matters

Each artifact type has different characteristics:
- **Context persistence** - How they behave in long conversations
- **Interaction model** - User-interactive vs LLM-direct
- **Tool availability** - What operations they can perform
- **Invocation timing** - Always loaded vs on-demand

Choosing the right type ensures your contribution works as intended.

## Quick Decision Matrix

| If you need... | Use this |
|----------------|----------|
| Execute bash operation immediately | **Command** |
| Guide user through multi-step workflow | **Skill** |
| Provide expert coaching/guidance | **Agent** |
| Define standard/convention | **Rule** |
| Document implementation approach | **Plan** |

## Interactive Decision Process

Let me ask you some questions to find the best fit:

### Question 1: What's the primary purpose?

**A. Execute an operation (bash script, automate task)**
→ Likely a **Command**
- Examples: Create files, run git operations, process data
- Go to Question 2 to confirm

**B. Guide user through interactive workflow**
→ Likely a **Skill**
- Examples: Setup wizard, decision helper, step-by-step process
- Go to Question 3 to confirm

**C. Provide expert knowledge/coaching**
→ Likely an **Agent**
- Examples: Architecture guidance, best practices, domain expertise
- Go to Question 4 to confirm

**D. Define standard, convention, or rule**
→ Definitely a **Rule**
- Examples: Naming conventions, frontmatter standards, when to use patterns
- ✅ Use **Rule** → See "Rules Deep Dive" below

**E. Document implementation plan**
→ Definitely a **Plan**
- Examples: Feature design, architecture decisions, implementation steps
- ✅ Use **Plan** → See "Plans Deep Dive" below

---

### Question 2: Command Confirmation

You said you want to **execute an operation**.

**Does it need user interaction during execution?**

**A. No - just run and show output**
→ ✅ Use **Command**
- Bash script executes, user sees results
- Examples: `/toolkit-new-handover`, `/toolkit-archive`, `/release`

**B. Yes - ask questions, get input, guide through steps**
→ ❌ Not a command → Use **Skill** instead
- Commands execute directly, skills guide interactively
- Example: Instead of command that asks questions, make skill that walks through workflow

**C. It needs to make complex decisions based on codebase state**
→ 🤔 Consider **Skill with agent** or **Agent**
- If mostly automation → Skill (can invoke agents)
- If mostly guidance → Agent

---

### Question 3: Skill Confirmation

You said you want to **guide user through interactive workflow**.

**Will this be invoked frequently in long-running conversations?**

**A. Yes - user might invoke multiple times in one session**
→ ✅ Definitely use **Skill**
- Progressive disclosure keeps context fresh
- Not subject to dilution
- Example: `/toolkit-handover` invoked whenever creating handover

**B. No - more of ongoing coaching throughout conversation**
→ 🤔 Consider **Agent** instead
- Agents provide continuous guidance
- Better for "always available" expertise
- But note: Subject to context dilution over time

**Does it need to execute operations or just guide?**

**A. Execute operations (create files, run commands)**
→ ✅ Use **Skill** (can include scripts as assets)
- Skills can bundle executable code
- Examples: `/toolkit-setup` creates directories

**B. Just guide with instructions**
→ ✅ Still use **Skill** if invoked on-demand
→ 🤔 Consider **Agent** if ongoing coaching

---

### Question 4: Agent Confirmation

You said you want to **provide expert knowledge/coaching**.

**When should this guidance be available?**

**A. Always throughout the conversation**
→ ✅ Use **Agent**
- Loaded at session start
- Provides ongoing expertise
- ⚠️ Warning: Context dilution - impact fades after hours of conversation

**B. Only when user explicitly asks for help**
→ 🤔 Consider **Skill** instead
- Invoked on-demand
- Fresh context each time
- No dilution problem
- Example: This very skill you're using!

**Does it need to execute operations?**

**A. Yes - write code, edit files**
→ ✅ Use **Agent with Skill delegation**
- **Best practice:** Agent is read-only, invokes write-capable Skills
- Follows Principle of Least Privilege
- Example: `toolkit-workflows` agent invokes `/toolkit-new-handover` skill
- Agent coordinates, Skill executes
- See `rules/toolkit-agents.md` for details

**B. No - just coaching/guidance**
→ ✅ Use **Agent** for ongoing coaching
→ 🤔 Use **Skill** for on-demand coaching (avoids dilution)

---

## Deep Dive: Each Artifact Type

### Commands

**What they are:**
- Bash scripts that execute operations
- Invoked via `/command-name`
- Execute immediately, show output

**Context behavior:**
- Not loaded at startup
- Invoked on-demand
- Fresh execution each time
- ✅ Not affected by context dilution

**Tool availability:**
- Bash execution
- Can run any shell command
- Full system access

**Interaction model:**
- Execute → Show output
- Not interactive (can't ask questions mid-execution)
- User sees results

**Best for:**
- ✅ Automation tasks
- ✅ File operations (create, move, archive)
- ✅ Git operations
- ✅ Quick utilities
- ✅ Data processing

**Examples:**
- `/toolkit-new-handover` - Create handover file
- `/toolkit-archive` - Archive old handovers
- `/release` - Create release

**When NOT to use:**
- ❌ Need user interaction during execution → Use Skill
- ❌ Need ongoing guidance → Use Agent
- ❌ Defining a standard → Use Rule

---

### Skills

**What they are:**
- Interactive workflows with progressive disclosure
- Invoked via `/skill-name`
- Guide user through multi-step processes
- Can bundle scripts, templates, assets

**Context behavior:**
- ✅ Progressive disclosure (name+description at startup, full content on invocation)
- ✅ Fresh context each invocation
- ✅ Not affected by dilution
- Perfect for long-running conversations

**Tool availability:**
- Full tool access
- Can read, write, execute
- Can bundle executable assets

**Interaction model:**
- Interactive Q&A
- Multi-step workflows
- Can execute bundled scripts
- User is actively engaged

**Best for:**
- ✅ Setup wizards
- ✅ Decision helpers (like this skill!)
- ✅ Multi-step processes
- ✅ Interactive configuration
- ✅ Guided workflows

**Examples:**
- `/toolkit-setup` - Initialize workspace
- `/toolkit-handover` - Create handover interactively
- `/toolkit-choose-artifact` - This skill!

**When NOT to use:**
- ❌ Simple bash execution → Use Command
- ❌ Ongoing passive guidance → Use Agent or Rule
- ❌ Just defining a standard → Use Rule

---

### Agents

**What they are:**
- Expert coaching and guidance
- Loaded based on agent description matching task
- Provide domain expertise
- LLM talks directly to them (not user-interactive)

**Context behavior:**
- ⚠️ Loaded at session start (or when task matches)
- ⚠️ Subject to context dilution over hours
- Impact fades in long conversations
- Better at session start than hours later

**Tool availability:**
- Can specify tool subset for agent
- **Best practice:** Read-only agents + Skill tool for delegation
- Agents invoke Skills when write operations needed
- Skills run with their own permissions (not limited by agent)
- Example: Read-only agent → invokes write-capable skill
- See `rules/toolkit-agents.md` for architecture details

**Interaction model:**
- LLM-direct (not user-interactive)
- Provides expertise and coaching
- Influences behavior and decisions
- Background guidance

**Best for:**
- ✅ Domain expertise (architecture, workflows)
- ✅ Coding standards coaching
- ✅ Best practices guidance
- ✅ Specialized knowledge areas
- ✅ Session-start guidance
- ✅ Coordinating workflows (read-only agent + Skill delegation)

**Examples:**
- `agents/toolkit-architecture` - System architecture reference (read-only)
- `agents/toolkit-workflows` - Workflow coordinator (invokes skills)
- `agents/toolkit-organization` - Validator/fixer (can move files + invoke skills)
- `agents/toolkit-scripts-guide` - Script helper (write-capable)

**See also:** `rules/toolkit-agents.md` for agent architecture standards

**When NOT to use:**
- ❌ Long-running conversations → Use Skill (no dilution)
- ❌ Need frequent re-invocation → Use Skill
- ❌ Execute operations → Use Command or Skill
- ❌ Define standards → Use Rule

**Context dilution workaround:**
- Make it a **Skill** instead if used frequently
- User can re-invoke to get fresh context
- Example: This artifact guide is a skill, not an agent!

---

### Rules

**What they are:**
- Standards, conventions, patterns
- **Modular alternative to monolithic CLAUDE.md files**
- Always loaded at session start
- Passive influence on behavior
- Quick reference guides

**Context behavior:**
- ⚠️ Loaded at startup
- ⚠️ Subject to context dilution
- Passive influence (not invoked)
- Better for quick reference than complex decisions

**Tool availability:**
- None - just guidance text
- No execution capability

**Interaction model:**
- Always present
- Passive influence
- No invocation needed
- LLM refers to them as needed

**Best for:**
- ✅ Naming conventions
- ✅ Frontmatter standards
- ✅ Code style guidelines
- ✅ When to use patterns
- ✅ Quick reference material
- ✅ Breaking up large CLAUDE.md files into focused, modular pieces

**Examples:**
- `rules/toolkit-naming-conventions.md`
- `rules/toolkit-frontmatter-standards.md`
- `rules/toolkit-session-continuity.md`

**When NOT to use:**
- ❌ Complex decision trees → Use Skill
- ❌ Execute operations → Use Command
- ❌ Deep coaching → Use Agent
- ❌ Implementation details → Use Plan

---

### Plans

**What they are:**
- Implementation plans and architecture decisions
- Documentation of approach
- Not executable - informational

**Context behavior:**
- Read when needed
- Not loaded automatically
- User or LLM references them

**Tool availability:**
- None - just documentation

**Interaction model:**
- Reference material
- Not invoked
- Describes what to build, not how to build it

**Best for:**
- ✅ Architecture decisions
- ✅ Feature implementation plans
- ✅ Technical design documents
- ✅ Approach documentation

**Examples:**
- `plans/auth-implementation.md`
- `plans/api-redesign.md`
- `plans/2026-02-02-exploring-options.md` (working plan)

**When NOT to use:**
- ❌ Executable operations → Use Command or Skill
- ❌ Standards → Use Rule
- ❌ Ongoing guidance → Use Agent

---

## Common Scenarios

### "I want to automate creating handover documents"

**Options:**
1. **Command** - `/toolkit-new-handover <description>`
   - ✅ Quick, non-interactive
   - Creates file, fills template

2. **Skill** - `/toolkit-handover create <description>`
   - ✅ Interactive, asks questions
   - Guides user through capturing context

**Recommendation:** Both!
- Command for quick creation
- Skill for guided, quality handovers

---

### "I want to help users understand workspace structure"

**Options:**
1. **Agent** - `agents/toolkit-workspace-setup.md`
   - Provides ongoing coaching
   - ⚠️ Dilutes over time

2. **Skill** - `/toolkit-workspace-help`
   - On-demand guidance
   - ✅ Fresh context each time

3. **Rule** - `rules/toolkit-workspace-separation.md`
   - Quick reference
   - ⚠️ Passive, dilutes over time

**Recommendation:** Agent + Rule
- Agent for detailed coaching
- Rule for quick reference
- Consider Skill if invoked frequently

---

### "I want to enforce naming conventions"

**Options:**
1. **Rule** - `rules/toolkit-naming-conventions.md`
   - ✅ Always loaded
   - Passive influence

2. **Command** - `/toolkit/validate-names`
   - Active checking
   - Explicit execution

3. **Skill** - `/toolkit-validate`
   - Interactive validation
   - Guided fixes

**Recommendation:** Rule + Skill
- Rule for passive guidance
- Skill for active validation and help

---

### "I want to guide users through choosing between approaches"

**Options:**
1. **Agent** - Provides coaching
   - ⚠️ Context dilution problem

2. **Skill** - Interactive decision tree
   - ✅ Fresh context on invocation
   - ✅ Perfect for this use case

**Recommendation:** Skill (like this one!)
- Progressive disclosure
- No context dilution
- Interactive Q&A

---

### "I want to help users write better commit messages"

**Options:**
1. **Rule** - Standards document
   - Passive guidance

2. **Agent** - Coaching on commits
   - ⚠️ Dilutes over time

3. **Skill** - `/write-commit`
   - Interactive commit helper
   - Asks questions, generates message

4. **Command** - `/commit`
   - Analyzes changes, creates commit
   - Quick execution

**Recommendation:** Rule + Command
- Rule for standards
- Command for execution
- Or Skill for interactive guidance

---

## Anti-Patterns to Avoid

### ❌ Command that asks user questions

**Problem:** Commands execute immediately, not interactive

**Solution:** Make it a Skill instead
- Skills can ask questions
- Guide through workflow

---

### ❌ Agent for frequently-invoked guidance

**Problem:** Context dilution in long conversations

**Solution:** Make it a Skill
- Progressive disclosure
- Fresh context each invocation
- Example: This artifact guide is a skill!

---

### ❌ Skill for passive reference material

**Problem:** Skills are for active invocation

**Solution:** Make it a Rule instead
- Always loaded
- Quick reference
- No invocation needed

---

### ❌ Rule with complex decision trees

**Problem:** Rules are passive, dilute over time

**Solution:** Make it a Skill
- Interactive decision making
- Fresh context when needed
- Active guidance

---

### ❌ Plan with executable code

**Problem:** Plans are documentation, not execution

**Solution:**
- Plan describes the approach
- Command/Skill implements it

---

## Experimenting Safely: The *.local.* Pattern

**When creating new artifacts, start with local experiments:**

### The Pattern

**Local experiments (git-ignored):**
- Commands: `my-command.local.md`
- Skills: `my-skill.local/SKILL.md`
- Agents: `my-agent.local.md`
- Rules: `my-rule.local.md`
- Plans: `my-plan.local.md`

**Git pattern:** `*.local.*` matches all of these

### The Workflow

1. **Create local:**
   ```
   .claude/plans/auth-helper.local.md
   ```

2. **Test thoroughly** without worrying about git

3. **Promote when ready:**
   ```
   /toolkit-promote plans/auth-helper.local.md
   ```

4. **Result:**
   ```
   .claude/commands/toolkit-auth-helper.md
   ```

5. **Open PR** to share with team

### Why This Works

- ✅ **Safe** - *.local.* files are git-ignored
- ✅ **Frictionless** - No git worries during experimentation
- ✅ **Clear path** - Experiment → Test → Promote → Team
- ✅ **Reversible** - Easy to delete failed experiments

### Location Matters

**In .claude/plans/:**
- Start experiments here
- Test locally
- Promote to appropriate artifact directory

**After promotion:**
- Moves to `.claude/commands/toolkit-<name>.md` (for commands)
- Or `.claude/skills/toolkit-<name>/` (for skills - directory)
- Or `.claude/agents/toolkit-<name>.md` (for agents)
- Or `.claude/rules/toolkit-<name>.md` (for rules)

**Sessions never get promoted:**
- Sessions are short-term (days)
- Plans are long-term (weeks of testing)
- Only plans get promoted to team level

---

## The Meta-Example

**Notice what this artifact guide is:**

✅ **A Skill** - Not an agent, not a rule!

**Why?**
- 📋 Invoked on-demand (`/toolkit-choose-artifact`)
- 🔄 Progressive disclosure (name+description at startup, full content now)
- 🎯 Interactive decision tree
- ✨ Fresh context each invocation
- ⏱️ Not subject to dilution (you can invoke multiple times)

**Why NOT an agent?**
- ❌ Would dilute over long conversations
- ❌ Not needed as ongoing background guidance
- ❌ Better invoked when actually needed

**Why NOT a rule?**
- ❌ Too complex for passive reference
- ❌ Interactive Q&A doesn't fit rule model
- ❌ Decision tree needs active guidance

**Why NOT a command?**
- ❌ Not executing an operation
- ❌ Needs interaction, not just output
- ❌ Guiding decisions, not automating tasks

**This skill demonstrates the very pattern it teaches!**

---

## Your Turn

Based on our conversation, what artifact type do you think fits your needs?

If you're still unsure, tell me:
1. What you're trying to accomplish
2. When it should be available (always vs on-demand)
3. Does it execute operations or provide guidance?
4. Does it need user interaction?

I'll help you choose the right type!
