---
name: toolkit-choose-artifact
description: Interactive guide to help you choose the right Claude Code artifact type (command, skill, agent, or plan) based on your needs. Asks targeted questions about purpose, interaction model, tool requirements, and context persistence to recommend the best fit.
---

# Choose the Right Artifact Type

**I'll help you decide whether to create a command, skill, agent, or plan.**

This skill uses an interactive decision tree to understand your needs and recommend the right artifact type.

## Why This Matters

Each artifact type has different characteristics:
- **Context behavior** - How they behave in long conversations
- **Interaction model** - User-interactive vs Claude-direct delegation
- **Tool availability** - What operations they can perform
- **Invocation timing** - On-demand vs delegated vs reference

Choosing the right type ensures your contribution works as intended.

## Quick Decision Matrix

| If you need... | Use this |
|----------------|----------|
| Execute bash operation immediately | **Command** |
| Guide user through a multi-step workflow | **Skill** (interactive) |
| Hold a standard, convention, or quick-reference doc | **Skill** (reference) |
| Provide expert coaching/guidance in an isolated context | **Agent** |
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

**D. Define a standard, convention, or quick-reference doc**
→ Definitely a **Skill** — written as reference content Claude reads on demand rather than an interactive wizard
- Examples: Naming conventions, frontmatter standards, when-to-use patterns
- ✅ Use **Skill (reference)** → See "Reference Skills" in the Skills Deep Dive below

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
- Progressive disclosure keeps the startup footprint small
- Once invoked, its body persists in the session's context — keep it to standing instructions, not narration
- Example: `/toolkit-handover` invoked whenever creating a handover

**B. No - it's reference content Claude should consult, not a wizard**
→ ✅ Still a **Skill**, just written as reference material instead of an interactive flow — see "Reference Skills" below

**Does it need to execute operations or just guide?**

**A. Execute operations (create files, run commands)**
→ ✅ Use **Skill** (can include scripts as assets)
- Skills can bundle executable code
- Examples: `/toolkit-setup` creates directories

**B. Just guide with instructions**
→ ✅ Still use **Skill**, whether that's an interactive Q&A or a reference doc Claude reads silently

---

### Question 4: Agent Confirmation

You said you want to **provide expert knowledge/coaching**.

**Does this need to hold a multi-turn conversation with the user, or is it a task Claude delegates to?**

**A. It's a task Claude delegates to (background specialist)**
→ ✅ Use **Agent**
- Runs in a fresh, **isolated context** per invocation — no conversation history carried in
- Only `name` + `description` are visible at session start for delegation matching; the full system prompt loads only when actually invoked, and the cost never touches the main thread
- Not "always loaded" and doesn't dilute anything — the tradeoff is a fresh isolated call each time, not context pollution

**B. It needs to interact with the user directly, back and forth**
→ ❌ Not a good fit for Agent — a subagent invocation is a one-shot task delegation, it can't hold an interactive loop with the user the way skill content running in the main thread can
→ 🤔 Use **Skill** instead
- Example: This very skill you're using!

**Does it need to execute operations?**

**A. Yes - write code, edit files**
→ ✅ Use **Agent with Skill delegation**
- **Best practice:** Agent is read-only, invokes write-capable Skills
- Follows Principle of Least Privilege
- Example: `toolkit-workflows` agent invokes `/toolkit-new-handover` skill
- Agent coordinates, Skill executes
- See `skills/toolkit-agents/SKILL.md` for details

**B. No - just coaching/guidance**
→ ✅ Use **Agent** when Claude should be able to delegate to it automatically
→ 🤔 Use **Skill** if it's the user who needs to invoke it directly

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
- ❌ Defining a standard → Use a reference Skill

---

### Skills

**What they are:**
- Interactive workflows *or* reference/standards content Claude reads on demand
- Invoked via `/skill-name` (by the user) or automatically by Claude (matching `description`)
- Can guide a user through a multi-step process, or hold quick-reference material with no interaction at all
- Can bundle scripts, templates, assets

**Context behavior:**
- ✅ Progressive disclosure (name+description at startup, full content loaded only on invocation)
- Once loaded, a skill's body **persists in the session's context for the rest of the conversation** — it isn't re-read each turn, so write standing instructions, not narration
- Perfect for long-running conversations precisely because you control when it loads

**Tool availability:**
- Full tool access
- Can read, write, execute
- Can bundle executable assets

**Interaction model:**
- Interactive Q&A and multi-step workflows, **or**
- Pure reference material Claude applies silently, with no back-and-forth

**Best for:**
- ✅ Setup wizards
- ✅ Decision helpers (like this skill!)
- ✅ Multi-step processes
- ✅ Interactive configuration
- ✅ Guided workflows
- ✅ Naming/frontmatter conventions, style guides, standards docs (**reference skills**)

**Reference Skills**

A "reference skill" is just a Skill whose body has no interactive flow — it's a standard, convention, or quick-reference doc that Claude reads and applies when relevant, the same way older "always-loaded rules" tried to work, except Claude Code has no mechanism that auto-loads an arbitrary directory of standards docs. A Skill's `description` is what gets Claude to consult it — write it as specifically as you would for a wizard-style skill.

**Examples:**
- `/toolkit-setup` - Initialize workspace (interactive)
- `/toolkit-handover` - Create handover interactively (interactive)
- `/toolkit-choose-artifact` - This skill! (interactive)
- `skills/toolkit-naming-conventions/SKILL.md` - File naming standards (reference)
- `skills/toolkit-frontmatter-standards/SKILL.md` - Frontmatter conventions (reference)

**When NOT to use:**
- ❌ Simple bash execution → Use Command
- ❌ Ongoing, proactive coaching across a whole session, delegated by Claude rather than invoked → Use Agent

---

### Agents

**What they are:**
- Expert coaching and guidance Claude delegates to via the Task tool
- Invoked based on the agent's `description` matching the current task, or explicitly
- Provide domain expertise in a background, isolated specialist

**Context behavior:**
- Only `name` + `description` are loaded at session start, for delegation matching
- The full system prompt loads fresh, in an **isolated context window**, only when actually invoked — no conversation history carried in, and it never touches or dilutes the main thread
- Each invocation is a clean slate; the "cost" is a fresh call, not accumulated context pollution

**Tool availability:**
- Can specify tool subset for agent
- **Best practice:** Read-only agents + Skill tool for delegation
- Agents invoke Skills when write operations needed
- Skills run with their own permissions (not limited by agent)
- Example: Read-only agent → invokes write-capable skill
- See `skills/toolkit-agents/SKILL.md` for architecture details

**Interaction model:**
- Claude-delegated (not directly user-interactive — can't hold a multi-turn conversation with the user)
- Provides expertise and coaching
- Influences behavior and decisions within the task it was given

**Best for:**
- ✅ Domain expertise (architecture, workflows)
- ✅ Coding standards coaching
- ✅ Best practices guidance
- ✅ Specialized knowledge areas
- ✅ Available for Claude to delegate to automatically
- ✅ Coordinating workflows (read-only agent + Skill delegation)

**Examples:**
- `agents/toolkit-architecture` - System architecture reference (read-only)
- `agents/toolkit-workflows` - Workflow coordinator (invokes skills)

**See also:** `skills/toolkit-agents/SKILL.md` for agent architecture standards

**When NOT to use:**
- ❌ Needs a multi-turn conversation with the user → Use Skill
- ❌ Execute operations → Use Command or Skill
- ❌ Define standards → Use a reference Skill

**If an agent feels like the wrong fit:**
- Make it a **Skill** instead if the user needs to invoke it directly, or if it needs to interact with them
- Agents and Skills solve different problems — pick by *who* invokes it and *whether it talks to the user*, not by worrying about context cost, since neither type dilutes the main thread when used as intended

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
- ❌ Standards → Use a reference Skill
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
1. **Agent** - `agents/toolkit-architecture.md`
   - Available for Claude to delegate to automatically
   - Isolated context, no dilution risk

2. **Skill (reference)** - `skills/toolkit-workspace-separation/SKILL.md`
   - Quick reference, read on demand
   - ✅ Also fresh context each time it's read

**Recommendation:** Agent + reference Skill
- Agent for detailed, Claude-delegated coaching
- Reference Skill for a quick lookup the user (or Claude) can consult directly

---

### "I want to enforce naming conventions"

**Options:**
1. **Skill (reference)** - `skills/toolkit-naming-conventions/SKILL.md`
   - Claude reads it on demand when relevant
   - Passive-feeling, but explicitly invoked/consulted rather than silently "always loaded"

2. **Skill (active)** - `/toolkit-validate`
   - Interactive validation
   - Guided fixes

**Recommendation:** Reference Skill + validation Skill
- Reference skill for the standard itself
- `/toolkit-validate` for actively checking and fixing violations

---

### "I want to guide users through choosing between approaches"

**Options:**
1. **Agent** - Provides coaching
   - Isolated per-invocation, can't hold an interactive back-and-forth with the user

2. **Skill** - Interactive decision tree
   - ✅ User-interactive, multi-turn
   - ✅ Perfect for this use case

**Recommendation:** Skill (like this one!)
- Progressive disclosure
- Interactive Q&A a subagent invocation can't do

---

### "I want to help users write better commit messages"

**Options:**
1. **Skill (reference)** - Standards document
   - Claude reads it when relevant

2. **Agent** - Coaching on commits
   - Claude-delegated, isolated

3. **Skill (interactive)** - `/write-commit`
   - Interactive commit helper
   - Asks questions, generates message

4. **Command** - `/commit`
   - Analyzes changes, creates commit
   - Quick execution

**Recommendation:** Reference Skill + Command
- Reference skill for the standard
- Command for execution
- Or an interactive Skill if you want guided message-writing

---

## Anti-Patterns to Avoid

### ❌ Command that asks user questions

**Problem:** Commands execute immediately, not interactive

**Solution:** Make it a Skill instead
- Skills can ask questions
- Guide through workflow

---

### ❌ Agent expected to hold a conversation with the user

**Problem:** A subagent invocation is an isolated, one-shot task delegation — it can't do a multi-turn Q&A with the user the way skill content running in the main thread can

**Solution:** Make it a Skill
- Runs in the main thread, can ask questions and wait for answers
- Example: This artifact guide is a skill, not an agent!

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

**Sessions never get promoted:**
- Sessions are short-term (days)
- Plans are long-term (weeks of testing)
- Only plans get promoted to team level

---

## The Meta-Example

**Notice what this artifact guide is:**

✅ **A Skill** - Not an agent!

**Why?**
- 📋 Invoked on-demand (`/toolkit-choose-artifact`)
- 🔄 Progressive disclosure (name+description at startup, full content now)
- 🎯 Interactive decision tree
- 💬 Needs a multi-turn conversation with the user

**Why NOT an agent?**
- ❌ Agent invocations are isolated, one-shot delegations — no back-and-forth with the user
- ❌ This needs to ask questions and wait for answers, which only works in the main thread

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
2. Who invokes it — the user directly, or Claude delegating automatically?
3. Does it execute operations or provide guidance?
4. Does it need a multi-turn conversation with the user?

I'll help you choose the right type!
