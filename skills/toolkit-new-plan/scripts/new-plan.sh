#!/bin/bash
set -e

echo "📋 Create New Working Plan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get today's date
TODAY=$(date +%Y-%m-%d)

# Prompt for description
if [ -t 0 ]; then
    read -p "Plan description (e.g., auth-approaches): " DESCRIPTION
else
    echo "  (Non-interactive mode - requires description as argument)"
    DESCRIPTION="$1"
fi

if [ -z "$DESCRIPTION" ]; then
    echo "❌ Description required"
    exit 1
fi

# Sanitize description (lowercase, hyphens)
DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr '_' '-')

# Determine plans directory
if [ -d "plans" ]; then
    PLANS_DIR="plans"
elif [ -d ".claude/plans" ]; then
    PLANS_DIR=".claude/plans"
else
    echo "❌ No plans/ or .claude/plans/ directory found"
    echo "   Run /toolkit-setup first"
    exit 1
fi

# Generate filename
FILENAME="$PLANS_DIR/$TODAY-$DESCRIPTION.md"

# Check if file exists
if [ -f "$FILENAME" ]; then
    echo "⚠️  File already exists: $FILENAME"
    if [ -t 0 ]; then
        read -p "Overwrite? (y/n): " OVERWRITE
        if [ "$OVERWRITE" != "y" ]; then
            echo "Cancelled"
            exit 0
        fi
    else
        echo "   Use different description or delete existing file"
        exit 1
    fi
fi

# Prompt for optional context
if [ -t 0 ]; then
    echo ""
    read -p "Context (what problem are you solving?): " CONTEXT
else
    CONTEXT="${2:-}"
fi

# Create plan from template
cat > "$FILENAME" << EOF
---
plan_id: "$TODAY-$DESCRIPTION"
related_to: ""
status: "draft"
decision: ""
last_updated: "$TODAY"
---

# $(echo "$DESCRIPTION" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

## Problem

${CONTEXT:-[What problem are we trying to solve?]}

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

**Pros:**
- Pro 1
- Pro 2

**Cons:**
- Con 1
- Con 2

**Open Questions:**
- Question 1?
- Question 2?

## Rough Notes

[Unstructured thinking, links to research, uncertainties]

## Decision

[To be filled when ready to graduate this plan]
EOF

echo ""
echo "✅ Created working plan: $FILENAME"
echo ""
echo "📋 Next Steps:"
echo "   1. Fill in approaches and tradeoffs"
echo "   2. Explore options, ask questions"
echo "   3. When decided, run: /toolkit-graduate $TODAY-$DESCRIPTION"
echo ""
echo "💡 This is a working plan (git-ignored) - be messy, explore freely!"
echo ""
