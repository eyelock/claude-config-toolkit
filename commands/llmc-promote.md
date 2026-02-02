---
name: llmc/promote
description: Promote a local experiment (*.local.*) to team-level configuration. Handles plans only (not sessions).
---

# Promote Local Experiment to Team

Move a tested local experiment from `.local` version to team-shared configuration.

## Purpose

After testing your experiment locally, promote it to share with the team:
- Removes `.local` suffix
- Moves to appropriate artifact directory
- Stages for git commit
- Guides PR workflow

## Usage

```bash
/llmc-promote <file-path>
```

**Examples:**

```bash
# Promote a plan
/llmc-promote plans/my-feature.local.md

# Promote from .claude/plans/
/llmc-promote .claude/plans/auth-helper.local.md
```

## What Gets Promoted

**✓ Accepted:**
- Plans: `*.local.md` → committed plans
- Commands: `my-cmd.local.md` → `.claude/commands/llmc-my-cmd.md`
- Skills: `my-skill.local/` → `.claude/skills/llmc/my-skill/`
- Agents: `my-agent.local.md` → `.claude/agents/llmc-my-agent.md`
- Rules: `my-rule.local.md` → `.claude/rules/llmc-my-rule.md`

**✗ Rejected:**
- Sessions (never promoted)
- Files without `.local` in the name
- Non-markdown files

## Implementation

```bash
#!/bin/bash
set -e

SOURCE="$1"

if [ -z "$SOURCE" ]; then
    echo "❌ Error: No file specified"
    echo ""
    echo "Usage: /llmc-promote <file-path>"
    echo ""
    echo "Examples:"
    echo "  /llmc-promote plans/my-feature.local.md"
    echo "  /llmc-promote .claude/plans/auth.local.md"
    exit 1
fi

# Validate source exists
if [ ! -e "$SOURCE" ]; then
    echo "❌ Error: File not found: $SOURCE"
    exit 1
fi

# Check if it's a session (reject)
if [[ "$SOURCE" == *"/sessions/"* ]] || [[ "$SOURCE" == "sessions/"* ]]; then
    echo "❌ Error: Cannot promote sessions"
    echo ""
    echo "Sessions are short-term handovers (days), not team configs."
    echo "Only plans and artifacts can be promoted."
    exit 1
fi

# Check if it has .local in the name
if [[ "$SOURCE" != *".local."* ]] && [[ "$SOURCE" != *".local/"* ]]; then
    echo "❌ Error: File doesn't appear to be a local experiment"
    echo ""
    echo "Expected *.local.* pattern, got: $SOURCE"
    echo ""
    echo "Tip: Local experiments use:"
    echo "  - my-file.local.md"
    echo "  - my-skill.local/ (directory)"
    exit 1
fi

echo "🚀 Promoting Local Experiment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Source: $SOURCE"
echo ""

# Determine artifact type and target location
FILENAME=$(basename "$SOURCE")
DIRNAME=$(dirname "$SOURCE")

# Remove .local from filename/directory
if [ -d "$SOURCE" ]; then
    # It's a directory (skill)
    TARGET_NAME="${FILENAME/.local/}"
    ARTIFACT_TYPE="skill"

    # Determine target based on current location
    if [[ "$DIRNAME" == *".claude/plans"* ]]; then
        TARGET_DIR=".claude/skills/llmc"
    else
        TARGET_DIR="skills/llmc"
    fi

    TARGET="$TARGET_DIR/$TARGET_NAME"
else
    # It's a file
    TARGET_NAME="${FILENAME/.local/}"

    # Detect artifact type from location or ask
    if [[ "$DIRNAME" == *"plans"* ]]; then
        echo "This is a plan. Where should it go?"
        echo "  1. Command (automation, file ops)"
        echo "  2. Skill (interactive workflow)"
        echo "  3. Agent (expert guidance)"
        echo "  4. Rule (standard/convention)"
        echo "  5. Plan (keep as plan)"
        echo ""
        read -p "Choose (1-5): " choice

        case $choice in
            1) ARTIFACT_TYPE="command" ;;
            2) ARTIFACT_TYPE="skill" ;;
            3) ARTIFACT_TYPE="agent" ;;
            4) ARTIFACT_TYPE="rule" ;;
            5) ARTIFACT_TYPE="plan" ;;
            *)
                echo "❌ Invalid choice"
                exit 1
                ;;
        esac
    else
        echo "❌ Error: Could not determine artifact type"
        exit 1
    fi

    # Determine target directory
    if [[ "$DIRNAME" == *".claude/"* ]]; then
        case $ARTIFACT_TYPE in
            command) TARGET_DIR=".claude/commands/llmc" ;;
            skill) TARGET_DIR=".claude/skills/llmc" ;;
            agent) TARGET_DIR=".claude/agents/llmc" ;;
            rule) TARGET_DIR=".claude/rules/llmc" ;;
            plan) TARGET_DIR=".claude/plans" ;;
        esac
    else
        case $ARTIFACT_TYPE in
            command) TARGET_DIR="commands/llmc" ;;
            skill) TARGET_DIR="skills/llmc" ;;
            agent) TARGET_DIR="agents/llmc" ;;
            rule) TARGET_DIR="rules/llmc" ;;
            plan) TARGET_DIR="plans" ;;
        esac
    fi

    TARGET="$TARGET_DIR/$TARGET_NAME"
fi

echo "Target: $TARGET"
echo "Type: $ARTIFACT_TYPE"
echo ""

# Check if target already exists
if [ -e "$TARGET" ]; then
    echo "⚠️  Warning: Target already exists!"
    read -p "Overwrite? (y/n): " overwrite
    if [ "$overwrite" != "y" ]; then
        echo "Promotion cancelled"
        exit 0
    fi
    echo ""
fi

# Confirm promotion
read -p "Proceed with promotion? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Promotion cancelled"
    exit 0
fi

echo ""
echo "📦 Promoting..."

# Create target directory if needed
mkdir -p "$TARGET_DIR"

# Move/rename
if [ -d "$SOURCE" ]; then
    mv "$SOURCE" "$TARGET"
else
    mv "$SOURCE" "$TARGET"
fi

echo "   ✓ Moved to $TARGET"
echo ""

# Git workflow guidance
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Promotion complete!"
echo ""
echo "📋 Next Steps (Git Workflow):"
echo ""

if [[ "$TARGET" == ".claude/"* ]]; then
    echo "   1. Stage the change in submodule:"
    echo "      cd .claude"
    echo "      git add $ARTIFACT_TYPE"s/llmc/$TARGET_NAME""
    echo ""
    echo "   2. Commit:"
    echo "      git commit -m \"feat: add $TARGET_NAME $ARTIFACT_TYPE\""
    echo ""
    echo "   3. Push to feature branch:"
    echo "      git checkout -b feature/$TARGET_NAME"
    echo "      git push origin feature/$TARGET_NAME"
    echo ""
    echo "   4. Open PR in LLMC repo for team review"
else
    echo "   1. Stage the change:"
    echo "      git add $TARGET"
    echo ""
    echo "   2. Commit:"
    echo "      git commit -m \"feat: add $TARGET_NAME $ARTIFACT_TYPE\""
    echo ""
    echo "   3. Push and open PR for review"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Examples

### Promote a Plan to Command

```bash
$ /llmc-promote .claude/plans/my-helper.local.md

🚀 Promoting Local Experiment
Source: .claude/plans/my-helper.local.md

This is a plan. Where should it go?
  1. Command (automation, file ops)
  2. Skill (interactive workflow)
  3. Agent (expert guidance)
  4. Rule (standard/convention)
  5. Plan (keep as plan)

Choose (1-5): 1

Target: .claude/commands/llmc-my-helper.md
Type: command

Proceed? (y/n): y

✅ Promotion complete!

Next: cd .claude && git add commands/llmc-my-helper.md
```

### Error: Trying to Promote a Session

```bash
$ /llmc-promote sessions/2026-02-01-work.md

❌ Error: Cannot promote sessions

Sessions are short-term handovers (days), not team configs.
Only plans and artifacts can be promoted.
```

## See Also

- `/llmc-choose-artifact` - Create local experiments
- `/llmc-setup` - Initialize workspace
- `rules/llmc-workspace-separation.md` - Local vs team philosophy
