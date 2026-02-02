# LLM Config

## Dual-Layer Workspace System

This project uses a **workshop vs product** model for LLM configuration development.

### Working Directories - The Workshop Layer (git-ignored)
**Your personal workspace with Claude - messy is OK!**

- **`sessions/`** - Session continuity documents
  - Resume work across conversations
  - Bridge the stateless AI gap
  - Naming: `YYYY-MM-DD-description.md`

- **`plans/`** - Working plans and rough drafts
  - Explore multiple approaches
  - Compare tradeoffs
  - Commit to git when ready (becomes team documentation)

### Root - The Product Layer (git-tracked)
**Team-shared, polished configurations**

- **`commands/`, `skills/`, `agents/`, `rules/`** - Claude Code configurations
- **`plans/`** - Formal plans when committed (git-tracked)

## Quick Start

### Starting a New Session?
1. Check `sessions/` for recent context
2. Read the most recent `YYYY-MM-DD-*.md` file
3. Continue where you left off

### Planning Something?
1. Draft in `plans/YYYY-MM-DD-idea.md`
2. Polish it
3. Rename and commit: `plans/idea.md`
4. Share with team via git

## Graduation Flow

```
plans/2026-02-01-idea.md     (exploring, git-ignored)
    ↓ decision made, rename
plans/idea.md                 (polished, git-tracked)
    ↓ git commit & PR
Merge to main                 (team gets it)
```

## Documentation

**Full details:** Browse with `make serve` or read agents in `agents/llmc-`

**Key agents:**
- `agents/llmc-architecture.md` - System architecture
- `agents/llmc-workflows.md` - Common workflows
- `agents/llmc-organization.md` - File organization

## Helper Commands

```bash
# Create new handover document (auto-dated)
/llmc-new-handover feature-design

# Graduate a plan to .claude/
/llmc-graduate 2026-02-01-auth-approach

# Clean up old handovers
/llmc-archive
```

---

## File Location Reference

**Working Directories (git-ignored content):**
- `sessions/` - Session continuity (YYYY-MM-DD-*.md)
- `plans/` - Working drafts (YYYY-MM-DD-*.md)

**Team Config (git-tracked):**
- `commands/llmc-`, `skills/llmc/`, `agents/llmc-`, `rules/llmc-` - LLMC artifacts
- `plans/` - Formal plans when committed (optional)

**Note:** When this repo is used as `.claude/` submodule in projects, committed plans appear as `.claude/plans/`
