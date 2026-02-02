# Frontmatter Validation Philosophy

## The Question

How strict should frontmatter validation be? Should we fail on missing optional fields?

## The Answer

**HARD STOP on critical issues, gentle suggestions otherwise.**

## Validation Levels

### Critical Errors (Exit 1)

Things that **break core functionality:**

- ❌ Unparseable YAML
- ❌ Missing required fields (`session_id`, `context`, `status`)
- ❌ Wrong filename pattern (breaks chronological sorting)

**Why fail:** These break the system. Files won't sort correctly, can't be parsed, or lack essential context.

### Suggestions (Exit 0)

Things that **improve quality but aren't essential:**

- 💡 Missing optional fields (`next_steps`, `related_files`)
- 💡 Date format recommendations
- 💡 Field naming consistency

**Why suggest:** LLMs get better over time. Today's "missing field" might be auto-filled tomorrow. Don't block on it.

## The Philosophy

**Frictionless development.**

We trust that:
1. LLMs will improve and auto-fill metadata
2. Users will add fields when they see value
3. Friction kills adoption

So we validate the minimum necessary to keep the system working, and suggest the rest.

## Strict Mode

For CI/CD or team standards:

```bash
./validate-frontmatter.sh --strict
```

In strict mode, suggestions become errors. Use this when enforcing team consistency, not during development.

## Implementation

The validation script has two counters:

```bash
CRITICAL_ERRORS=0    # Fail the script
SUGGESTIONS=0        # Just inform the user
```

And different output styles:

```bash
critical() {
  echo -e "${RED}✗ CRITICAL:${NC} $1"
  CRITICAL_ERRORS=$((CRITICAL_ERRORS + 1))
}

suggest() {
  echo -e "${YELLOW}💡 SUGGEST:${NC} $1"
  SUGGESTIONS=$((SUGGESTIONS + 1))
}
```

## Real-World Example

**File:** `sessions/2026-02-01-auth-work.md`

```yaml
---
session_id: "2026-02-01-auth-work"
context: "Implementing JWT authentication"
status: "in_progress"
---
```

**Validation output:**
```
✅ sessions/2026-02-01-auth-work.md: Filename follows YYYY-MM-DD-* pattern
✅ sessions/2026-02-01-auth-work.md: Frontmatter is parseable
✅ sessions/2026-02-01-auth-work.md: Has 'session_id' field
✅ sessions/2026-02-01-auth-work.md: Has 'context' field
✅ sessions/2026-02-01-auth-work.md: Has 'status' field
💡 SUGGEST: sessions/2026-02-01-auth-work.md: Consider adding 'next_steps' for better context
💡 SUGGEST: sessions/2026-02-01-auth-work.md: Consider adding 'related_files' for better context

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary:
  ✅ Good: 6
  💡 Suggestions: 2
  ❌ Critical: 0

💡 Suggestions are optional - LLMs get better over time
   Consider adding suggested fields for even better results
```

**Result:** Exit 0, user can continue working.

## Why This Matters

**Bad validation:** Blocks users on nitpicks, frustrates developers, slows iteration.

**Good validation:** Catches real errors, suggests improvements, stays out of the way.

We chose good validation.
