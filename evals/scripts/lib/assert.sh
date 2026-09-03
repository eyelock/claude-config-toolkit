#!/bin/bash
# Tiny bash assertion helpers for evals/scripts/test-*.sh. Source, don't execute.
# Tracks pass/fail counts in $ASSERT_PASS / $ASSERT_FAIL for the sourcing script to report.

ASSERT_PASS=0
ASSERT_FAIL=0

_assert_ok()   { ASSERT_PASS=$((ASSERT_PASS + 1)); echo "  ✅ $1"; }
_assert_bad()  { ASSERT_FAIL=$((ASSERT_FAIL + 1)); echo "  ❌ $1"; }

assert_eq() {
  # assert_eq <actual> <expected> <label>
  if [ "$1" = "$2" ]; then _assert_ok "$3"; else _assert_bad "$3 (expected '$2', got '$1')"; fi
}

assert_contains() {
  # assert_contains <haystack> <needle> <label>
  if [[ "$1" == *"$2"* ]]; then _assert_ok "$3"; else _assert_bad "$3 (expected to contain '$2')"; fi
}

assert_file_exists() {
  # assert_file_exists <path> <label>
  if [ -f "$1" ]; then _assert_ok "$2"; else _assert_bad "$2 (file not found: $1)"; fi
}

assert_file_not_exists() {
  # assert_file_not_exists <path> <label>
  if [ ! -f "$1" ]; then _assert_ok "$2"; else _assert_bad "$2 (file still present: $1)"; fi
}

assert_exit_code() {
  # assert_exit_code <actual> <expected> <label>
  if [ "$1" -eq "$2" ]; then _assert_ok "$3"; else _assert_bad "$3 (expected exit $2, got $1)"; fi
}

assert_report() {
  # Call at the end of a test-*.sh file. Exits non-zero if any assertion failed.
  echo ""
  echo "  $ASSERT_PASS passed, $ASSERT_FAIL failed"
  [ "$ASSERT_FAIL" -eq 0 ]
}
