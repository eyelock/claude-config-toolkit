#!/usr/bin/env bash
# PostToolUse hook (Edit|Write) — best-effort lint of the file Claude just changed.
# Degrades silently when no linter is available or the file type isn't handled;
# this is a starter to extend with your project's real formatter/linter.
set -euo pipefail

input="$(cat)"
file_path="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)"

[ -z "$file_path" ] && exit 0
[ -f "$file_path" ] || exit 0

case "$file_path" in
  *.sh)
    command -v shellcheck >/dev/null 2>&1 && shellcheck "$file_path" || true
    ;;
  *.json)
    python3 -m json.tool "$file_path" >/dev/null || echo "Warning: $file_path is not valid JSON" >&2
    ;;
esac

exit 0
