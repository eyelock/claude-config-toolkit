# Claude Config Toolkit

> Note: This is a personal project developed in my spare time. It works well for my workflow but may have rough edges. Contributions and feedback welcome!  See the [Issues](https://github.com/eyelock/claude-config-toolkit/issues) for outstanding work in this early access release.

**Git-Based AI Development Configuration**

A proven approach to writing, sharing, and measuring the impact of AI development configurations (prompts, skills, agents, commands) using Claude Code.

## Quick Start

**One command:** `/toolkit-setup` - It detects your context and does the right thing.

### Scenario 1: Team Member (Project with the Toolkit)

**Your project already has `.claude/` folder:**

1. **Open Claude Code** in your project
2. **Run setup:**
   ```
   /toolkit-setup    # Auto-detects project, creates .claude/sessions/ and .claude/plans/
   ```
3. **Start experimenting:**
   ```
   /toolkit-choose-artifact    # Creates *.local.* files (git-ignored)
   ```
4. **Test locally, then promote:**
   ```
   /toolkit-promote plans/my-feature.local.md    # Shares with team
   ```

**No `.claude/` folder yet?** Run `/toolkit-setup` - it will offer to add the Toolkit as submodule.

### Scenario 2: Claude Config Maintainer (Developing Configs)

**Want to create or improve team configs?**

1. **Clone this repo:**
   ```bash
   git clone git@github.com:your-org/toolkit-config.git ~/repos/myteam-claude-config
   cd ~/repos/myteam-claude-config
   ```

2. **Bootstrap install** (first time only):
   ```bash
   make install
   ```
   This symlinks Toolkit to `~/.claude/` so `/toolkit-*` commands work.

3. **Restart Claude Code** (or reload window)

4. **Open Claude Code** and run setup:
   ```
   /toolkit-setup    # Creates sessions/plans/ workspace
   ```

5. **Start creating:**
   ```
   /toolkit-choose-artifact    # Guides you through artifact types
   ```

6. **Test it, then submit a PR**

**That's the whole flow!** The system guides you from there.

### The *.local.* Pattern

**Experiment safely:**
- Create: `my-command.local.md` (git-ignored)
- Test thoroughly
- Promote: `/toolkit-promote plans/my-command.local.md`
- Result: `.claude/commands/toolkit-my-command.md` (git-tracked)

**Path: Experiment → Test → Promote → Team**

## What This System Provides

### 🧩 Artifact Types at a Glance

Claude Code supports five artifact types. Each has different characteristics for context, interaction, and execution:

| Type | Purpose | Interaction | Context Behavior | Best For |
|------|---------|-------------|------------------|----------|
| **Command** | Execute bash operations | User invokes → Sees output | Fresh each time, no dilution | Automation, file ops, git tasks |
| **Skill** | Guide interactive workflows | User invokes → Interactive Q&A | Progressive disclosure, fresh on invoke | Setup wizards, decision helpers, multi-step processes |
| **Agent** | Provide expert coaching | LLM-direct (background) | Loaded at start, ⚠️ dilutes over hours | Domain expertise, best practices, architecture guidance |
| **Rule** | Define standards/conventions | Always loaded (passive) | Loaded at start, ⚠️ dilutes over time | Naming conventions, quick reference, style guides |
| **Plan** | Document implementation | Reference material | Read when needed | Architecture decisions, feature designs, approach docs |

**Key Insights:**
- 🔄 **Context dilution**: Agents and Rules fade in long conversations → Use Skills for frequently-invoked guidance
- ⚡ **Progressive disclosure**: Skills load name+description at startup, full content on invocation → Keeps context efficient
- 🎯 **Tool availability**: Agents can be read-only (exploration) or read-write (task completion) → Tools shape behavior
- 💬 **Interaction model**: Commands execute, Skills interact, Agents coach, Rules guide passively

**Not sure which to use?** Invoke `/toolkit-choose-artifact` for an interactive decision helper.

### 🎯 Three-Tier Development Model

```
┌─────────────────────────────────────────────────────────────┐
│ Tier 1: Local Experimentation                               │
│ Location: Your laptop                                       │
│ Visibility: Only you                                        │
│ Tools: ~/.claude/ (user space)                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Tier 2: Team Testing                                        │
│ Location: Feature branch in this repo                       │
│ Visibility: Team members who opt-in to test                 │
│ Tools: PRs, code review, git branches                       │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Tier 3: Official Release                                    │
│ Location: Tagged release (v1.0.0, v1.1.0, etc.)             │
│ Visibility: All team projects (via submodule)               │
│ Tools: Semantic versioning, release notes                   │
└─────────────────────────────────────────────────────────────┘
```

### 🔐 Safety First

- ✅ Never overwrites your personal configs
- ✅ Git-tracked changes in `~/.claude/`
- ✅ Automatic backups before linking
- ✅ Explicit user control at every step

### 📊 Measurable Impact

- Track which configs are most used
- Measure team productivity improvements
- Gather feedback through PRs
- Iterate based on real usage

## Project vs User Scopes

**PROJECT-scoped configs** (in this repo):
- Project-specific commands (e.g., `/release`, `/deploy`)
- Team conventions (e.g., "always ask before git push")
- Shared workflows (e.g., debugging patterns)

**USER-scoped configs** (in your `~/.claude/`):
- Personal preferences (e.g., verbose vs terse)
- Cross-project utilities (e.g., `/explain-thoroughly`)
- Individual productivity tools

## Toolkit Meta-Tools

The **toolkit** namespace provides tools for managing Claude Code configurations:

**Interactive Skills:**
- `/toolkit-choose-artifact` - Help choosing the right artifact type (command/skill/agent/rule/plan)
- `/toolkit-setup` - Initialize workspace structure
- `/toolkit-validate` - Validate frontmatter metadata
- `/toolkit-handover` - Create and manage session handovers

**Quick Commands:**
- `/toolkit-new-handover` - Create session handover document
- `/toolkit-graduate` - Graduate working plan to formal plan
- `/toolkit-archive` - Archive completed handovers

**Standards & Guides:**
- `rules/toolkit-` - Naming conventions, frontmatter standards, workspace separation
- `agents/toolkit-` - Expert guidance on workflows, planning, architecture, contributing

## Browsing Documentation

**Web interface (recommended):**
```bash
make serve
# Open http://localhost:3000
```

This starts docsify, which renders all markdown files in a searchable web interface with navigation sidebar.

**Makefile commands:**
```bash
make help      # Show all available commands
make test      # Run validation checks
make validate  # Check frontmatter
```

## Directory Structure

### This Config Repo (toolkit-config/)

```
toolkit-config/           # The config repository
├── README.md                   # This file
├── Makefile                    # Development tasks
├── index.html                  # Docsify documentation browser
│
├── commands/toolkit-              # Toolkit commands (git-tracked)
├── skills/toolkit/                # Toolkit skills (git-tracked)
├── agents/toolkit-                # Toolkit agents (git-tracked)
├── rules/toolkit-                 # Toolkit rules (git-tracked)
│
├── plans/                      # Working plans (git-ignored content)
│   ├── README.md               # How to use plans/
│   ├── TEMPLATE.md             # Plan template
│   └── *.md                    # Your draft plans (git-ignored)
│
└── sessions/                   # Session continuity (git-ignored content)
    ├── README.md               # How to use sessions/
    ├── TEMPLATE.md             # Session template
    └── *.md                    # Your handovers (git-ignored)
```

### Project Using This Config (your-project/)

When this config is linked to a project via git submodule:

```
your-project/                      # Your actual project
├── .claude/                    # Git submodule → myteam-claude-config
│   ├── commands/toolkit-          # Team commands (from submodule)
│   ├── skills/toolkit/            # Team skills (from submodule)
│   ├── agents/toolkit-            # Team agents (from submodule)
│   └── rules/toolkit-             # Team rules (from submodule)
│
├── plans/                      # Working plans (git-ignored)
│   └── *.md                    # Your project planning docs
│
└── sessions/                   # Session continuity (git-ignored)
    └── *.md                    # Your session handovers
```

**Key insight:** `sessions/` and `plans/` exist in BOTH repos, but serve different purposes:
- **In config repo:** Workspace for developing Toolkit configs
- **In project repo:** Workspace for using Toolkit configs to build your project

## Git-Ignore Philosophy

**Q: Why do git-ignored directories exist in a git repo?**

**A: Physical structure vs tracked content**

The directories `sessions/` and `plans/` are tracked in git (so everyone gets the structure and README files), but the `.md` files you create in them are git-ignored (personal workspace).

**In `.gitignore`:**
```gitignore
# Track structure, ignore content
plans/*.md
!plans/README.md
!plans/TEMPLATE.md

sessions/*.md
!sessions/README.md
!sessions/TEMPLATE.md
```

**Why this matters:**
1. **Config repo:** When developing Toolkit, you need workspace for drafts and session continuity
2. **Project repo:** When using Toolkit, you need workspace for planning features and resuming work
3. **Both cases:** The directories must exist, but your personal content stays private

## Using Without Toolkit

**Can you use this workspace pattern without the Toolkit starter configs?**

**Yes!** The core concept is separating workspace (sessions/plans) from configs (commands/skills/agents/rules).

### Two Patterns Without Toolkit

**Pattern 1: Root-level workspace** (mimics Toolkit maintainer structure)
```bash
your-project/
├── sessions/          # Session handovers
├── plans/             # Working plans
└── .claude/           # Your custom configs (not a submodule)
    ├── commands/
    ├── skills/
    └── agents/
```

Setup:
```bash
mkdir -p sessions plans .claude
echo "sessions/*.md" >> .gitignore
echo "plans/*.md" >> .gitignore
```

**Pattern 2: Everything in .claude/** (mimics submodule structure)
```bash
your-project/
└── .claude/           # Your custom configs
    ├── sessions/      # Session handovers
    ├── plans/         # Working plans
    ├── commands/
    ├── skills/
    └── agents/
```

Setup:
```bash
mkdir -p .claude/sessions .claude/plans
echo ".claude/sessions/*.md" >> .gitignore
echo ".claude/plans/*.md" >> .gitignore
```

**Which pattern to use?**
- Pattern 1 if you're developing configs themselves (like Toolkit maintainers)
- Pattern 2 if you're using configs in a project (like Toolkit submodule users)

**What you lose without Toolkit:**
- `/toolkit-setup` - manual directory creation instead
- `/toolkit-new-handover` - manual file creation instead
- `/toolkit-graduate` - manual rename and git commit instead
- `/toolkit-validate` - no frontmatter validation
- No starter agents/skills/rules/commands

**What you keep:**
- The workspace pattern (sessions/plans/)
- Your own commands/skills/agents/rules
- The three-tier development model
- Git-based distribution

Toolkit provides automation and starters, but the core pattern is just directories and git.

## Getting Started

### Path 1: Just Exploring

**Want to understand the system?**
1. Run `make serve` to browse documentation
2. Read `agents/toolkit-architecture.md` - System overview
3. Try `/toolkit-choose-artifact` - Interactive guide
4. Explore the artifact types in `commands/`, `skills/`, `agents/`, `rules/`

### Path 2: Setting Up a Project

**Want to add Toolkit to a project? (Tech leads / project maintainers)**

**Option A - With Toolkit automation:**

1. **Add Toolkit as a submodule:**
   ```bash
   cd /path/to/your/project
   git submodule add git@github.com:your-org/toolkit-config.git .claude
   git commit -m "Add Toolkit configuration submodule"
   ```

2. **Open Claude Code in your project:**
   ```bash
   code .  # or your editor of choice
   ```

3. **In Claude, run setup:**
   ```
   /toolkit-setup    # Creates sessions/ and plans/ directories
   ```

4. **Done! Now you and your team can use:**
   ```
   /toolkit-new-handover my-feature
   /toolkit-choose-artifact
   /toolkit-validate
   ```

**Option B - Manual (no Toolkit starters):**

1. **Create workspace manually:**
   ```bash
   mkdir -p sessions plans .claude
   echo -e "sessions/*.md\nplans/*.md" >> .gitignore
   ```

2. **Create your own configs in `.claude/`** (no Toolkit commands/skills/agents)

### Path 3: Contributing to Toolkit

**Want to develop configs for the team?**

1. **Clone the Toolkit repo:**
   ```bash
   git clone git@github.com:your-org/claude-config-toolkit.git ~/repos/toolkit
   cd ~/repos/toolkit
   ```

2. **Open in Claude Code:**
   ```bash
   code .
   ```

3. **In Claude, initialize workspace:**
   ```
   /toolkit-setup    # Creates sessions/ and plans/ directories
   ```

4. **Create your first config:**
   ```
   /toolkit-choose-artifact    # Interactive guide walks you through it
   ```
   This will help you choose: Command, Skill, Agent, or Rule

5. **Test it, then submit a PR**

**More details:** Run `make serve` to browse full documentation at http://localhost:3000

## Quick Reference

## Contributing

**Quick start:**
1. Run `/toolkit-setup` to initialize your workspace
2. Run `/toolkit-choose-artifact` to choose the right artifact type
3. Create your artifact in the appropriate directory
4. Test it, then submit a PR

**Detailed guides:**
- `agents/toolkit-contributing.md` - **Comprehensive contribution guide** (workflow, quality standards, examples)
- `agents/toolkit-workflows.md` - Development workflows (session, planning)
- `agents/toolkit-organization.md` - File organization patterns
- `agents/toolkit-team-workflows.md` - Team workflows (PR testing, releases, upgrades)

**Standards:**
- `rules/toolkit-naming-conventions.md` - File naming standards
- `rules/toolkit-frontmatter-standards.md` - Metadata conventions
- `rules/toolkit-workspace-separation.md` - Workshop vs product philosophy

## Support

- **Questions?** Run `make serve` to browse all documentation
- **Issues?** Open a GitHub issue
- **Stuck?** Use the Toolkit skills and agents - they're designed to help!
