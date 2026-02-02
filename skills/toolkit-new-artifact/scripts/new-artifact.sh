#!/bin/bash
set -e

echo "🎨 Create New Toolkit Artifact"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Prompt for artifact type
if [ -t 0 ]; then
    echo "Artifact types:"
    echo "  1) Agent   - Expert coaching/guidance"
    echo "  2) Command - Bash operation executor  "
    echo "  3) Skill   - Interactive workflow"
    echo "  4) Rule    - Standard/convention"
    echo ""
    read -p "Choose type (1-4): " TYPE_CHOICE
else
    TYPE_CHOICE="$1"
fi

case "$TYPE_CHOICE" in
    1|agent|Agent)
        ARTIFACT_TYPE="agent"
        ARTIFACT_DIR="agents"
        ;;
    2|command|Command)
        ARTIFACT_TYPE="command"
        ARTIFACT_DIR="commands"
        ;;
    3|skill|Skill)
        ARTIFACT_TYPE="skill"
        ARTIFACT_DIR="skills"
        ;;
    4|rule|Rule)
        ARTIFACT_TYPE="rule"
        ARTIFACT_DIR="rules"
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

# Prompt for name
if [ -t 0 ]; then
    read -p "Artifact name (without toolkit- prefix): " NAME
else
    NAME="$2"
fi

if [ -z "$NAME" ]; then
    echo "❌ Name required"
    exit 1
fi

# Sanitize name
NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-')
FULL_NAME="toolkit-$NAME"

# Prompt for description
if [ -t 0 ]; then
    read -p "Description: " DESCRIPTION
else
    DESCRIPTION="$3"
fi

if [ -z "$DESCRIPTION" ]; then
    echo "❌ Description required"
    exit 1
fi

# Determine directory
if [ -d "$ARTIFACT_DIR" ]; then
    TARGET_DIR="$ARTIFACT_DIR"
elif [ -d ".claude/$ARTIFACT_DIR" ]; then
    TARGET_DIR=".claude/$ARTIFACT_DIR"
else
    echo "❌ No $ARTIFACT_DIR/ or .claude/$ARTIFACT_DIR/ directory found"
    exit 1
fi

# Create artifact based on type
case "$ARTIFACT_TYPE" in
    agent)
        FILENAME="$TARGET_DIR/$FULL_NAME.md"
        if [ -f "$FILENAME" ]; then
            echo "⚠️  File already exists: $FILENAME"
            exit 1
        fi

        # Prompt for tools
        if [ -t 0 ]; then
            echo ""
            echo "Tool access patterns:"
            echo "  1) Read-only (Read, Grep, Glob, Skill)"
            echo "  2) Coordinator (Read, Grep, Glob, Bash, Skill)"
            echo "  3) Write-capable (Read, Write, Bash, Grep, Glob, Skill)"
            echo ""
            read -p "Choose (1-3): " TOOLS_CHOICE
        else
            TOOLS_CHOICE="1"
        fi

        case "$TOOLS_CHOICE" in
            1) TOOLS="Read, Grep, Glob, Skill" ;;
            2) TOOLS="Read, Grep, Glob, Bash, Skill" ;;
            3) TOOLS="Read, Write, Bash, Grep, Glob, Skill" ;;
            *) TOOLS="Read, Grep, Glob, Skill" ;;
        esac

        cat > "$FILENAME" << EOF
---
name: $FULL_NAME
description: $DESCRIPTION
tools: $TOOLS
model: inherit
---

# $(echo "$NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1') Agent

You are an expert in [domain].

## Your Role

When users need help with [domain], you:
- [Primary responsibility 1]
- [Primary responsibility 2]
- [Primary responsibility 3]

## [Section: Core Knowledge]

[Content describing the domain expertise]

## Your Guidance Approach

When helping users:

1. **[First step]:**
   - [Detail]

2. **[Second step]:**
   - [Detail]

## Related

- [Related rules, skills, commands]
- See \`rules/toolkit-agents.md\` for agent standards
EOF
        ;;

    command)
        echo "⚠️  Command creation not yet implemented"
        echo "   Manually create: $TARGET_DIR/$FULL_NAME.md"
        exit 1
        ;;

    skill)
        echo "⚠️  Skill creation not yet implemented"
        echo "   Skills require directory structure:"
        echo "   $TARGET_DIR/$FULL_NAME/SKILL.md"
        exit 1
        ;;

    rule)
        echo "⚠️  Rule creation not yet implemented"
        echo "   Manually create: $TARGET_DIR/$FULL_NAME.md"
        exit 1
        ;;
esac

echo ""
echo "✅ Created $ARTIFACT_TYPE: $FILENAME"
echo ""
echo "📋 Next Steps:"
echo "   1. Edit the file to add content"
echo "   2. Fill in domain expertise and guidance"
echo "   3. Test with Claude Code"
echo "   4. Run: make validate"
echo ""
