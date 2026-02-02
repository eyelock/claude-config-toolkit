#!/bin/bash
set -e

echo "🏗️  Toolkit Frictionless Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect context
# Check for Toolkit repo by looking for flat toolkit-* structure
if [ -d "commands" ] && [ -d "skills" ] && \
   compgen -G "commands/toolkit-*" > /dev/null && \
   compgen -G "skills/toolkit-*" > /dev/null; then
    CONTEXT="toolkit-repo"
    echo "📍 Detected: Toolkit repository (you're developing Toolkit configs)"
# Check for project with Toolkit submodule
elif [ -d ".claude/commands" ] && [ -d ".claude/skills" ] && \
     (compgen -G ".claude/commands/toolkit-*" > /dev/null || \
      compgen -G ".claude/skills/toolkit-*" > /dev/null); then
    CONTEXT="project-with-toolkit"
    echo "📍 Detected: Project with Toolkit submodule"
else
    CONTEXT="new-project"
    echo "📍 Detected: New project (no Toolkit yet)"
fi

echo ""

# Branch based on context
case $CONTEXT in
    "toolkit-repo")
        SESSIONS_DIR="sessions"
        PLANS_DIR="plans"

        # Check if already set up
        if [ -d "$SESSIONS_DIR" ] && [ -f "$SESSIONS_DIR/README.md" ] && \
           [ -d "$PLANS_DIR" ] && [ -f "$PLANS_DIR/README.md" ]; then
            echo "✅ Workspace already configured!"
            echo "   - $SESSIONS_DIR/ ✓"
            echo "   - $PLANS_DIR/ ✓"
            ALREADY_SETUP=true
        else
            echo "Will create:"
            echo "  - sessions/ (for your handovers)"
            echo "  - plans/ (for your experiments)"
            echo ""

            # Check if running interactively
            if [ -t 0 ]; then
                read -p "Proceed? (y/n): " confirm
                if [ "$confirm" != "y" ]; then
                    echo "Setup cancelled"
                    exit 0
                fi
            else
                echo "   (Non-interactive mode - proceeding automatically)"
            fi
            ALREADY_SETUP=false
        fi
        ;;

    "project-with-toolkit")
        SESSIONS_DIR=".claude/sessions"
        PLANS_DIR=".claude/plans"

        # Check if already set up
        if [ -d "$SESSIONS_DIR" ] && [ -f "$SESSIONS_DIR/README.md" ] && \
           [ -d "$PLANS_DIR" ] && [ -f "$PLANS_DIR/README.md" ]; then
            echo "✅ Workspace already configured!"
            echo "   - $SESSIONS_DIR/ ✓"
            echo "   - $PLANS_DIR/ ✓"
            echo ""
            echo "Note: Use *.local.* pattern for git-ignored experiments"
            ALREADY_SETUP=true
        else
            echo "Will create:"
            echo "  - .claude/sessions/ (for handovers)"
            echo "  - .claude/plans/ (for local experiments)"
            echo ""
            echo "Note: Use *.local.* pattern for git-ignored experiments"
            echo ""

            # Check if running interactively
            if [ -t 0 ]; then
                read -p "Proceed? (y/n): " confirm
                if [ "$confirm" != "y" ]; then
                    echo "Setup cancelled"
                    exit 0
                fi
            else
                echo "   (Non-interactive mode - proceeding automatically)"
            fi
            ALREADY_SETUP=false
        fi
        ;;

    "new-project")
        SESSIONS_DIR=".claude/sessions"
        PLANS_DIR=".claude/plans"

        echo "No Toolkit found. You can:"
        echo "  1. Add Toolkit as git submodule (recommended)"
        echo "  2. Just create workspace structure"
        echo ""

        # Check if running interactively
        if [ -t 0 ]; then
            read -p "Add Toolkit submodule? (y/n): " add_submodule

            if [ "$add_submodule" = "y" ]; then
                read -p "Enter Toolkit repo URL (e.g., git@github.com:your-org/toolkit-config.git): " repo_url
                if [ -n "$repo_url" ]; then
                    echo ""
                    echo "Adding submodule..."
                    git submodule add "$repo_url" .claude
                    git submodule update --init
                    echo "✓ Toolkit added as submodule"
                    echo ""
                fi
            fi

            echo "Will create:"
            echo "  - $SESSIONS_DIR (for handovers)"
            echo "  - $PLANS_DIR (for experiments)"
            echo ""
            read -p "Proceed? (y/n): " confirm
            if [ "$confirm" != "y" ]; then
                echo "Setup cancelled"
                exit 0
            fi
        else
            echo "   (Non-interactive mode - skipping submodule setup)"
            echo "   Will create workspace structure only"
            echo ""
        fi
        ALREADY_SETUP=false
        ;;
esac

echo ""

# Only create directories if not already set up
if [ "$ALREADY_SETUP" = "false" ]; then
    echo "📁 Creating directory structure..."
    mkdir -p "$SESSIONS_DIR"
    mkdir -p "$PLANS_DIR"
    echo "   ✓ Created $SESSIONS_DIR"
    echo "   ✓ Created $PLANS_DIR"
    echo ""
fi

# Create sessions README
if [ ! -f "$SESSIONS_DIR/README.md" ]; then
    cat > "$SESSIONS_DIR/README.md" << 'EOF'
# Session Handover Documents

Bridge the gap between stateless AI conversations with structured handovers.

## Purpose

Handovers preserve context when:
- Pausing work mid-stream
- Switching between tasks
- Resuming in a new session (possibly different Claude instance)
- Working on complex multi-session projects

## What Goes Here

- ✅ Session handovers for resuming work
- ✅ Session notes and context
- ✅ Temporary scripts or artifacts
- ✅ Anything related to a specific development session

## Naming Convention

Use date-first pattern for chronological sorting:

```
YYYY-MM-DD-description.md
```

Examples:
- `2026-02-02-auth-api-implementation.md`
- `2026-02-05-bug-user-login-timeout.md`

## Quick Start

Create new handover:
```
/toolkit-new-handover <description>
```

Archive completed handovers:
```
/toolkit-archive
```

## See Also

- `TEMPLATE.md` - Handover template with frontmatter
- `rules/toolkit-session-continuity.md` - Best practices
- `commands/toolkit-new-handover.md` - Create handover command
- `commands/toolkit-archive.md` - Archive completed work
EOF
    echo "   ✓ Created $SESSIONS_DIR/README.md"
fi

# Create sessions TEMPLATE
if [ ! -f "$SESSIONS_DIR/TEMPLATE.md" ]; then
    cat > "$SESSIONS_DIR/TEMPLATE.md" << 'EOF'
---
session_id: "YYYY-MM-DD-descriptor"
previous_session: ""
continued_in: ""
context: "One-line summary of what we're working on"
status: "draft"
blockers: []
next_steps:
  - "First thing to do when resuming"
  - "Second thing to do"
related_files: []
last_updated: "YYYY-MM-DD"
---

# Session: [Descriptive Title]

## Context

[What are we working on? Why? What's the goal?]

## Current State

[Where did we leave off? What's been completed?]

## Next Steps

1. [First action when resuming]
2. [Second action]
3. [Third action]

## Blockers

[What's preventing progress? What decisions need to be made?]

## Notes

[Any relevant observations, gotchas, or context that will help resume]
EOF
    echo "   ✓ Created $SESSIONS_DIR/TEMPLATE.md"
fi

# Create sessions .gitignore
if [ ! -f "$SESSIONS_DIR/.gitignore" ]; then
    cat > "$SESSIONS_DIR/.gitignore" << 'EOF'
# Track structure, ignore content
*
!.gitignore
!README.md
!TEMPLATE.md
EOF
    echo "   ✓ Created $SESSIONS_DIR/.gitignore"
fi

# Create plans README
if [ ! -f "$PLANS_DIR/README.md" ]; then
    cat > "$PLANS_DIR/README.md" << 'EOF'
# Working Plans

This directory holds **rough exploration** while you're figuring things out.

## Purpose

Plans start as git-ignored content where messy exploration is welcome:
- ✅ Comparing multiple approaches
- ✅ Open questions and uncertainties
- ✅ "I don't know..." is perfectly fine
- ✅ Rough notes and rejected alternatives

## Local vs Promoted

**Local experiments** (git-ignored):
- Use `*.local.*` pattern
- Example: `my-feature.local.md`
- Test freely without git worries

**Promoted to team** (git-tracked):
- Remove `.local` from name
- Example: `my-feature.md`
- Use `/toolkit-promote` to help with this

## Naming Convention

Working plans (git-ignored):
```
YYYY-MM-DD-description.md
my-feature.local.md
```

Formal plans (committed):
```
descriptive-name.md
```

Examples:
- `2026-02-02-auth-approach-exploration.md` (working)
- `auth-api.local.md` (local test)
- `auth-implementation.md` (promoted, committed)

## See Also

- `TEMPLATE.md` - Plan template
- `commands/toolkit-promote.md` - Promotion helper
- `rules/toolkit-workspace-separation.md` - Philosophy
EOF
    echo "   ✓ Created $PLANS_DIR/README.md"
fi

# Create plans TEMPLATE
if [ ! -f "$PLANS_DIR/TEMPLATE.md" ]; then
    cat > "$PLANS_DIR/TEMPLATE.md" << 'EOF'
---
plan_id: "YYYY-MM-DD-descriptor"
related_to: ""
status: "draft"
decision: ""
last_updated: "YYYY-MM-DD"
---

# [Plan Title]

## Problem

[What problem are we trying to solve?]

## Approaches Considered

### Approach 1: [Name]

**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

**Open Questions:**
- Question 1?
- Question 2?

### Approach 2: [Name]

[Same structure]

## Rough Notes

[Unstructured thinking, links to research, uncertainties]

## Decision

[To be filled when ready to promote]
EOF
    echo "   ✓ Created $PLANS_DIR/TEMPLATE.md"
fi

# Create plans .gitignore
if [ ! -f "$PLANS_DIR/.gitignore" ]; then
    cat > "$PLANS_DIR/.gitignore" << 'EOF'
# Track structure, ignore content
*
!.gitignore
!README.md
!TEMPLATE.md
EOF
    echo "   ✓ Created $PLANS_DIR/.gitignore"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$ALREADY_SETUP" = "true" ]; then
    echo "✅ Workspace verified - everything is in place!"
else
    echo "✅ Setup complete!"
fi
echo ""

# Context-specific next steps
case $CONTEXT in
    "toolkit-repo")
        echo "📋 Next Steps:"
        echo ""
        echo "   1. (Optional) Install to user-level ~/.claude/?"
        echo "      This makes /toolkit-* commands available everywhere."
        echo ""

        # Check if running interactively
        if [ -t 0 ]; then
            read -p "   Install to user level? (y/n): " install_user
        else
            echo "   (Non-interactive mode - skipping user-level install)"
            install_user="n"
        fi

        if [ "$install_user" = "y" ]; then
            REPO_DIR=$(pwd)
            USER_CLAUDE="$HOME/.claude"

            echo ""
            echo "   Installing to ~/.claude/..."
            mkdir -p "$USER_CLAUDE/skills" "$USER_CLAUDE/commands" "$USER_CLAUDE/agents" "$USER_CLAUDE/rules"

            # Remove existing toolkit-* symlinks if present
            find "$USER_CLAUDE/skills" -type l -name "toolkit-*" -delete 2>/dev/null || true
            find "$USER_CLAUDE/commands" -type l -name "toolkit-*" -delete 2>/dev/null || true
            find "$USER_CLAUDE/agents" -type l -name "toolkit-*" -delete 2>/dev/null || true
            find "$USER_CLAUDE/rules" -type l -name "toolkit-*" -delete 2>/dev/null || true

            # Create individual symlinks for each artifact
            for skill in "$REPO_DIR"/skills/toolkit-*/; do
                [ -d "$skill" ] && ln -s "$skill" "$USER_CLAUDE/skills/$(basename "$skill")"
            done
            for cmd in "$REPO_DIR"/commands/toolkit-*; do
                [ -f "$cmd" ] && ln -s "$cmd" "$USER_CLAUDE/commands/$(basename "$cmd")"
            done
            for agent in "$REPO_DIR"/agents/toolkit-*; do
                [ -f "$agent" ] && ln -s "$agent" "$USER_CLAUDE/agents/$(basename "$agent")"
            done
            for rule in "$REPO_DIR"/rules/toolkit-*; do
                [ -f "$rule" ] && ln -s "$rule" "$USER_CLAUDE/rules/$(basename "$rule")"
            done

            echo "   ✓ Installed to ~/.claude/"
            echo ""
            echo "   Restart Claude Code to see /toolkit-* commands everywhere"
        fi

        echo ""
        echo "   2. Start developing:"
        echo "      Edit commands/, skills/, agents/, rules/"
        echo ""
        echo "   3. Use sessions/ for handovers:"
        echo "      /toolkit-new-handover <description>"
        ;;

    "project-with-toolkit")
        echo "📋 Next Steps:"
        echo ""
        echo "   1. Start experimenting:"
        echo "      /toolkit-choose-artifact"
        echo "         ↓"
        echo "      Creates *.local.* files (git-ignored)"
        echo ""
        echo "   2. Test your experiments locally"
        echo ""
        echo "   3. When ready to share with team:"
        echo "      /toolkit-promote plans/my-feature.local.md"
        echo "         ↓"
        echo "      Opens PR to Toolkit repo"
        ;;

    "new-project")
        if [ "$add_submodule" = "y" ]; then
            echo "📋 Next Steps:"
            echo ""
            echo "   1. Commit the submodule:"
            echo "      git add .claude .gitmodules"
            echo "      git commit -m 'Add Toolkit configuration submodule'"
            echo ""
            echo "   2. Start using Toolkit:"
            echo "      /toolkit-choose-artifact"
        else
            echo "📋 Next Steps:"
            echo ""
            echo "   1. To add Toolkit later:"
            echo "      git submodule add <url> .claude"
            echo ""
            echo "   2. Or continue without Toolkit:"
            echo "      Use .claude/sessions/ and .claude/plans/ manually"
        fi
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
