---
name: llmc-validate
description: Validate frontmatter metadata in handovers, plans, and scripts following LLMC standards. Performs frictionless validation with hard stops for critical issues and suggestions for optional improvements.
---

# LLMC Validation

Validate frontmatter metadata across workspace files.

## What This Does

Checks frontmatter in:
- **Handovers** (`sessions/*.md`)
- **Plans** (`plans/*.md`)

Validates:
- Required fields are present
- Field naming follows snake_case convention
- Date formats are YYYY-MM-DD
- Status values are valid
- File naming follows YYYY-MM-DD-* pattern

## Validation Philosophy: Frictionless

**Hard Stop (Exit 1):**
- Missing required fields (session_id, plan_id, etc.)
- Invalid field names (camelCase, PascalCase when snake_case required)
- Malformed frontmatter structure

**Suggestions Only (Exit 0):**
- Missing optional fields
- Recommendations for improvement
- Best practice reminders

**Goal:** Catch critical errors without blocking workflow for stylistic preferences.

## When to Use

- Before archiving handovers
- Before graduating plans
- During code reviews
- As part of CI/CD checks
- When teaching LLMC conventions

## Usage

```bash
# Validate all workspace files
/llmc-validate

# Validate specific file
/llmc-validate sessions/2026-02-01-feature.md

# Dry run (show what would be checked)
/llmc-validate --dry-run
```

## What Gets Checked

### Handover Files (sessions/*.md)

**Required Fields:**
- `session_id` (string, matches filename pattern)
- `context` (string)
- `status` (enum: draft|in_progress|paused|completed)
- `last_updated` (YYYY-MM-DD)

**Optional Fields:**
- `previous_session` (string)
- `continued_in` (string)
- `blockers` (array)
- `next_steps` (array)
- `related_files` (array)

### Plan Files (plans/*.md)

**Required Fields:**
- `plan_id` (string, matches filename pattern)
- `status` (enum: draft|in_progress|decided|archived)
- `last_updated` (YYYY-MM-DD)

**Optional Fields:**
- `related_to` (string)
- `decision` (string)

### Script Files (*.sh)

**Required in Comments:**
- Script name
- Purpose description
- Created date (YYYY-MM-DD)

**Optional:**
- Author
- Status

## Implementation

When invoked, this skill runs the `scripts/validate-frontmatter.sh` script included as an asset in this directory.

The validator:
1. Scans target files
2. Extracts frontmatter
3. Validates required fields
4. Checks field naming conventions
5. Verifies date formats
6. Reports errors and suggestions
7. Exits with appropriate status code

## Example Output

```
🔍 Validating LLMC workspace files...

✓ sessions/2026-02-01-feature.md
  All required fields present

✗ sessions/2026-02-02-bug-fix.md
  ERROR: Missing required field 'session_id'

⚠ plans/2026-02-03-design.md
  SUGGESTION: Consider adding 'decision' field for clarity

Summary: 2 valid, 1 error, 1 suggestion
```

## Assets

- `scripts/validate-frontmatter.sh` - Frontmatter validation script

## See Also

- `rules/llmc-frontmatter-standards.md` - Field naming conventions
- `rules/llmc-naming-conventions.md` - File naming standards
- `commands/llmc-archive.md` - Archive command (validates before archiving)
