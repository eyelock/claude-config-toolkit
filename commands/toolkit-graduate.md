# Graduate Plan

**Command:** `/toolkit-graduate <plan-name>`

**Purpose:** Graduate a working plan from `plans/` to `plans/` (team-shared).

## Usage

```
/toolkit-graduate 2026-02-02-auth-approach
/toolkit-graduate 2026-02-05-api-design
```

## What It Does

1. Copies working plan to `plans/`
2. Updates frontmatter (`related_to` link, status to `archived`)
3. Prompts for cleanup (archive/delete/keep working plan)
4. Guides through polishing process

## Implementation

When user invokes this command:

```bash
#!/bin/bash
PLAN_NAME="$1"
SOURCE="plans/${PLAN_NAME}.md"
DEST="plans/${PLAN_NAME}.md"

# Verify source exists
if [ ! -f "$SOURCE" ]; then
  echo "Error: Working plan not found: $SOURCE"
  exit 1
fi

# Copy to formal location
cp "$SOURCE" "$DEST"
echo "✓ Copied to: $DEST"

# Update frontmatter in working plan
TODAY=$(date +%Y-%m-%d)
sed -i '' "s/^---$/---\nrelated_to: \"plans\/${PLAN_NAME}.md\"/" "$SOURCE"
sed -i '' 's/status: "[^"]*"/status: "archived"/' "$SOURCE"
sed -i '' "s/last_updated: \"[^\"]*\"/last_updated: \"${TODAY}\"/" "$SOURCE"

echo "✓ Updated working plan frontmatter"
echo ""
echo "Graduation checklist:"
echo "  1. Review and polish: $DEST"
echo "  2. Remove rough notes/rejected approaches"
echo "  3. Add implementation steps"
echo "  4. Commit: git add $DEST && git commit"
echo ""
echo "Working plan cleanup:"
read -p "Archive working plan? (a=archive, d=delete, k=keep): " action

case "$action" in
  a|A)
    MONTH=$(date +%Y-%m)
    mkdir -p "plans/archive/$MONTH"
    mv "$SOURCE" "plans/archive/$MONTH/"
    echo "✓ Archived to: plans/archive/$MONTH/"
    ;;
  d|D)
    rm "$SOURCE"
    echo "✓ Deleted working plan"
    ;;
  *)
    echo "✓ Kept working plan (marked as archived)"
    ;;
esac
```

## Graduation Checklist

Before graduating, ensure your plan is ready:

- [ ] Decision made on approach
- [ ] Remove rejected alternatives
- [ ] Remove "dumb questions" and rough notes
- [ ] Add clear implementation steps
- [ ] Polish language for team audience
- [ ] Update frontmatter
- [ ] Ready for team review

## Example

**Before (`plans/2026-02-02-auth.md`):**
```markdown
# Auth Approaches

## Option 1: JWT
Pros: ...
Cons: ...
Questions: Not sure about refresh tokens?

## Option 2: Sessions
Pros: ...
Cons: ...

## Rough notes
- Need to research
- Talk to team
- This might be overkill?
```

**After (`plans/auth-implementation.md`):**
```markdown
# Auth Implementation

Decision: JWT with refresh tokens in httpOnly cookies.

Implementation steps:
1. Add jwt library
2. Create /auth/login endpoint
3. Create /auth/refresh endpoint
4. Add middleware for protected routes
```

## See Also

- `agents/toolkit-planning-guide.md` - Planning workflow guide
- `plans/README-EXAMPLE-GRADUATION.md` - Detailed before/after example
