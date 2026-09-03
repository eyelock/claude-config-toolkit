#!/usr/bin/env bash
# PreToolUse hook (Edit|Write) — blocks edits to a protected-files list.
# Customize PROTECTED_PATTERNS for your project. Exit 2 blocks the tool call
# and returns stderr to Claude as the reason; exit 0 allows it.
set -euo pipefail

PROTECTED_PATTERNS=(
  ".env"
  ".env.*"
  "*.pem"
  "*.key"
  "secrets/*"
)

input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

[ -z "$file_path" ] && exit 0

base="$(basename "$file_path")"
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  # shellcheck disable=SC2254
  case "$file_path" in
    $pattern) echo "Blocked: $file_path matches protected pattern '$pattern'." >&2; exit 2 ;;
  esac
  # shellcheck disable=SC2254
  case "$base" in
    $pattern) echo "Blocked: $file_path matches protected pattern '$pattern'." >&2; exit 2 ;;
  esac
done

exit 0
