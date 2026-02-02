---
session_id: "YYYY-MM-DD-descriptor"
previous_session: ""     # Optional: YYYY-MM-DD-previous
continued_in: ""         # Optional: YYYY-MM-DD-next (fill when continuing)
context: "One-line summary of what we're working on"
status: "in_progress"
blockers: []
next_steps:
  - "First thing to do when resuming"
  - "Second thing to do"
related_files:
  - "path/to/file.md:123"  # Optional: file:line format
last_updated: "YYYY-MM-DD"  # Optional: track when last updated
---

# Session Handover: [Title]

## What We Accomplished

- Thing 1
- Thing 2
- Thing 3

## Current State

[Describe where we left off - be specific!]

Example:
"We were implementing the authentication feature. We decided on JWT tokens
with refresh tokens stored in httpOnly cookies. The login endpoint is done
(see api/auth.ts:45-89) but logout still needs implementation."

## Open Questions

- Question 1 that we haven't resolved yet?
- Question 2 that might need user input?

## Decisions Made

- **Decision 1:** We chose X over Y because Z
- **Decision 2:** We decided to defer A until after B

## For Next Session

[Clear instructions for resuming]

Example:
"Continue by implementing the logout endpoint in api/auth.ts. Reference
the login endpoint pattern (lines 45-89). Remember to invalidate the
refresh token in the database."

## Context Links

- Related docs: [Link to relevant documentation]
- Previous handover: `sessions/YYYY-MM-DD-previous.md`
- Working plan: `plans/auth-feature.md`
