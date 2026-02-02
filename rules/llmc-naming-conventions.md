# LLMC Naming Conventions

When working with LLMC session workspace, follow these naming patterns:

## File Naming: Date-First Pattern

**ALWAYS use `YYYY-MM-DD-description.md` for session files.**

This ensures:
- ✅ Chronological sorting (recent files first)
- ✅ Easy to spot old vs new at a glance
- ✅ Consistent across all session directories

### Examples

**Handovers:**
```
✅ sessions/2026-02-02-api-redesign.md
✅ sessions/2026-02-05-bug-investigation.md

❌ sessions/api-redesign.md              # No date
❌ sessions/api-redesign-2026-02-02.md   # Date at end
❌ sessions/02-02-2026-api-redesign.md   # Wrong date order
```

**Working Plans:**
```
✅ plans/2026-02-02-auth-approach.md
✅ plans/2026-02-10-database-schema.md

❌ plans/auth-approach.md                # No date
```

**Scripts:**
```
✅ 2026-02-02-migrate-data.sh
✅ 2026-02-15-test-api.sh

❌ migrate-data.sh               # No date
```

## Directory Naming

Use lowercase with hyphens:

```
✅ skills/llmc-handover/
✅ commands/llmc-new-handover.md

❌ skills/LLMC/Handover/            # Uppercase
❌ skills/llmc_handover/            # Underscores
```

## LLMC Namespace

All LLMC meta-tools use `llmc` prefix or directory:

```
✅ rules/llmc-frontmatter-standards.md
✅ commands/llmc-new-handover.md
✅ skills/llmc-setup/SKILL.md
✅ agents/llmc-architecture.md

❌ rules/frontmatter-standards.md       # No namespace
❌ commands/create-handover.md          # No namespace
```

## Why Date-First?

**Sorting:** `ls` naturally shows recent files first
**Scanning:** Glance at directory, immediately see what's new
**Cleanup:** Easy to identify old files for archival
**Consistency:** Same pattern everywhere reduces cognitive load

## Quick Reference

| Type | Pattern | Example |
|------|---------|---------|
| Handover | `YYYY-MM-DD-description.md` | `2026-02-02-feature-work.md` |
| Plan | `YYYY-MM-DD-description.md` | `2026-02-02-api-design.md` |
| Script | `YYYY-MM-DD-description.sh` | `2026-02-02-migrate.sh` |
| Archive | `archive/YYYY-MM/` | `archive/2026-02/` |
