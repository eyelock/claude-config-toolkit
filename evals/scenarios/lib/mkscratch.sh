#!/bin/bash
# Builds a throwaway project directory with this repo's commands/skills/agents/rules
# installed as project-level config (.claude/{commands,skills,agents,rules}), so a headless
# `claude -p` run started inside it sees exactly what a real consuming project would see.
# Usage: mkscratch.sh  ->  prints the scratch directory path on stdout.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCRATCH="$(mktemp -d)"
mkdir -p "$SCRATCH/.claude"

for dir in commands skills agents rules; do
  if [ -d "$REPO_ROOT/$dir" ]; then
    cp -r "$REPO_ROOT/$dir" "$SCRATCH/.claude/$dir"
  fi
done

# Minimal workspace so skills that expect sessions/plans/ to exist can find them.
mkdir -p "$SCRATCH/sessions" "$SCRATCH/plans"
[ -f "$REPO_ROOT/sessions/TEMPLATE.md" ] && cp "$REPO_ROOT/sessions/TEMPLATE.md" "$SCRATCH/sessions/TEMPLATE.md"
[ -f "$REPO_ROOT/plans/TEMPLATE.md" ] && cp "$REPO_ROOT/plans/TEMPLATE.md" "$SCRATCH/plans/TEMPLATE.md"

echo "$SCRATCH"
