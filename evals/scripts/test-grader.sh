#!/bin/bash
# Tests evals/scenarios/lib/grade.sh's grading logic against canned fixture transcripts.
# No LLM calls, no network, no cost — this is what makes the tier-3 grading logic itself
# testable in every CI run, even when ANTHROPIC_API_KEY isn't set to actually run scenarios.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GRADE="$REPO_ROOT/evals/scenarios/lib/grade.sh"
source "$SCRIPT_DIR/lib/assert.sh"

echo "test-grader.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

# A transcript where the "Skill" tool was invoked once, with input.skill = toolkit-setup.
TRANSCRIPT_SETUP="$SCRATCH/transcript-setup.jsonl"
cat > "$TRANSCRIPT_SETUP" <<'EOF'
{"type":"system","subtype":"init"}
{"type":"assistant","message":{"content":[{"type":"text","text":"I'll set that up."}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t1","name":"Skill","input":{"skill":"toolkit-setup"}}]}}
{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"done"}]}}
{"type":"result","subtype":"success"}
EOF

# A transcript with no tool use at all (e.g. Claude just answered in text).
TRANSCRIPT_EMPTY="$SCRATCH/transcript-empty.jsonl"
cat > "$TRANSCRIPT_EMPTY" <<'EOF'
{"type":"system","subtype":"init"}
{"type":"assistant","message":{"content":[{"type":"text","text":"The capital of France is Paris."}]}}
{"type":"result","subtype":"success"}
EOF

# --- expect_skill: match ---
P1="$SCRATCH/p1.md"
cat > "$P1" <<'EOF'
---
name: p1
expect_skill: toolkit-setup
---
prompt body
EOF
bash "$GRADE" "$P1" "$TRANSCRIPT_SETUP" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 0 "expect_skill matches invoked skill -> PASS"

# --- expect_skill: mismatch ---
P2="$SCRATCH/p2.md"
cat > "$P2" <<'EOF'
---
name: p2
expect_skill: toolkit-handover
---
prompt body
EOF
bash "$GRADE" "$P2" "$TRANSCRIPT_SETUP" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 1 "expect_skill not invoked -> FAIL"

# --- expect_skill but nothing fired ---
bash "$GRADE" "$P1" "$TRANSCRIPT_EMPTY" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 1 "expect_skill declared but transcript has no tool use -> FAIL"

# --- forbid_skills: none fired -> PASS ---
P3="$SCRATCH/p3.md"
cat > "$P3" <<'EOF'
---
name: p3
forbid_skills: [toolkit-setup, toolkit-handover]
---
prompt body
EOF
bash "$GRADE" "$P3" "$TRANSCRIPT_EMPTY" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 0 "forbid_skills, none invoked -> PASS"

# --- forbid_skills: forbidden one fired -> FAIL ---
bash "$GRADE" "$P3" "$TRANSCRIPT_SETUP" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 1 "forbid_skills, a forbidden one fired -> FAIL"

# --- expect_files ---
mkdir -p "$SCRATCH/sessions"
touch "$SCRATCH/sessions/2026-09-03-fixture.md"
P4="$SCRATCH/p4.md"
cat > "$P4" <<'EOF'
---
name: p4
expect_files: [sessions/*.md]
---
prompt body
EOF
bash "$GRADE" "$P4" "$TRANSCRIPT_EMPTY" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 0 "expect_files glob matches an existing file -> PASS"

rm -f "$SCRATCH/sessions"/*.md
bash "$GRADE" "$P4" "$TRANSCRIPT_EMPTY" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 1 "expect_files glob matches nothing -> FAIL"

# --- prompt.md with no grading directives at all -> FAIL loudly rather than false-passing ---
P5="$SCRATCH/p5.md"
cat > "$P5" <<'EOF'
---
name: p5
---
prompt body
EOF
bash "$GRADE" "$P5" "$TRANSCRIPT_EMPTY" "$SCRATCH" >/dev/null 2>&1
assert_exit_code "$?" 1 "no grading directives declared -> FAIL (not a silent pass)"

assert_report
