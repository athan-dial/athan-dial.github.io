#!/usr/bin/env bash
# Runs the validator on the real set (must pass) and on deliberately bad inputs (must fail with a reason).
cd "$(dirname "$0")/.." || exit 2
fail=0
python3 validate.py records || { echo "UNEXPECTED: real set failed"; fail=1; }
expect_fail() { # label, pattern, paths...
  label=$1; pat=$2; shift 2
  out=$(python3 validate.py "$@" 2>&1); rc=$?
  if [ $rc -ne 0 ] && echo "$out" | grep -q "$pat"; then echo "PASS (failed as expected: $label)"; echo "$out" | grep FAIL | head -3
  else echo "UNEXPECTED ($label): rc=$rc"; echo "$out"; fail=1; fi
}
expect_fail "bad topic enum" "not in allowed list" tests/invalid
expect_fail "tested without evidence_note" "requires evidence_note" tests/invalid2
expect_fail "missing required field" "missing required field 'mechanism'" tests/invalid3
expect_fail "canonical_url/id mismatch" "does not resolve to id owner/repo" tests/invalid4
expect_fail "email in text (safety scan)" "safety deny-list hit" tests/invalid5
expect_fail "image file missing" "image.file" tests/invalid6
expect_fail "duplicate canonical identity" "duplicate canonical identity" tests/duplicate/a tests/duplicate/b
exit $fail
