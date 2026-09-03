#!/bin/bash
# Runs one scenario: builds a scratch project (mkscratch.sh), sends the prompt.md body to a
# headless `claude -p` session in it, saves the stream-json transcript, then grades it
# (grade.sh) against prompt.md's frontmatter. Requires ANTHROPIC_API_KEY — callers (run-all.sh)
# are responsible for checking that and skipping otherwise; this script assumes it's set.
#
# Usage: run-scenario.sh <scenario-dir> [--keep-scratch]
# Exit codes: 0 pass, 1 fail, 2 setup/tooling error (claude CLI missing, etc.)
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/frontmatter.sh"

SCENARIO_DIR="${1:?usage: run-scenario.sh <scenario-dir>}"
KEEP_SCRATCH=false
[ "${2:-}" = "--keep-scratch" ] && KEEP_SCRATCH=true

PROMPT_FILE="$SCENARIO_DIR/prompt.md"
if [ ! -f "$PROMPT_FILE" ]; then
  echo "❌ No prompt.md in $SCENARIO_DIR"
  exit 2
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "❌ 'claude' CLI not found on PATH"
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ 'jq' not found on PATH (required to parse the transcript)"
  exit 2
fi

NAME=$(fm_field "$PROMPT_FILE" "name")
[ -z "$NAME" ] && NAME="$(basename "$SCENARIO_DIR")"
MODEL=$(fm_field "$PROMPT_FILE" "model")
[ -z "$MODEL" ] && MODEL="haiku"
MAX_BUDGET=$(fm_field "$PROMPT_FILE" "max_budget_usd")
[ -z "$MAX_BUDGET" ] && MAX_BUDGET="0.50"
TIMEOUT_SECONDS=$(fm_field "$PROMPT_FILE" "timeout_seconds")
[ -z "$TIMEOUT_SECONDS" ] && TIMEOUT_SECONDS="120"
PROMPT_BODY=$(fm_body "$PROMPT_FILE")

echo "▶ $NAME (model=$MODEL, budget=\$$MAX_BUDGET, timeout=${TIMEOUT_SECONDS}s)"

SCRATCH="$(bash "$SCRIPT_DIR/mkscratch.sh")"
TRANSCRIPT="$SCRATCH/.transcript.jsonl"

TIMEOUT_BIN=""
command -v timeout >/dev/null 2>&1 && TIMEOUT_BIN="timeout"
command -v gtimeout >/dev/null 2>&1 && TIMEOUT_BIN="gtimeout"

CLAUDE_CMD=(claude -p "$PROMPT_BODY" \
  --output-format stream-json --verbose \
  --model "$MODEL" \
  --max-budget-usd "$MAX_BUDGET" \
  --permission-mode bypassPermissions \
  --setting-sources project)

(
  cd "$SCRATCH"
  if [ -n "$TIMEOUT_BIN" ]; then
    "$TIMEOUT_BIN" "${TIMEOUT_SECONDS}s" "${CLAUDE_CMD[@]}"
  else
    "${CLAUDE_CMD[@]}"
  fi
) > "$TRANSCRIPT" 2> "$SCRATCH/.stderr.log"
RUN_EXIT=$?

if [ "$RUN_EXIT" -eq 124 ]; then
  echo "  ⏱️  timed out after ${TIMEOUT_SECONDS}s"
fi

bash "$SCRIPT_DIR/grade.sh" "$PROMPT_FILE" "$TRANSCRIPT" "$SCRATCH"
GRADE_EXIT=$?

if [ "$KEEP_SCRATCH" = true ] || [ "$GRADE_EXIT" -ne 0 ]; then
  echo "  (scratch dir kept for inspection: $SCRATCH)"
else
  rm -rf "$SCRATCH"
fi

exit "$GRADE_EXIT"
