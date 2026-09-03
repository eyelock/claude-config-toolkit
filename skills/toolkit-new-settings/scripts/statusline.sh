#!/usr/bin/env bash
# Example statusLine command — Claude Code pipes session JSON on stdin.
# Reads model name and current git branch; extend with cost/context-% fields
# from the input JSON as needed (see the Settings Reference for the schema).
set -euo pipefail

input="$(cat)"
model="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("model",{}).get("display_name","?"))' 2>/dev/null || echo "?")"
branch="$(git branch --show-current 2>/dev/null || echo "no-git")"

printf '%s | %s' "$model" "$branch"
