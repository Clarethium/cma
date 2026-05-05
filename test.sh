#!/usr/bin/env bash
# Tests for cma 1.0
# Run from repository root: ./test.sh

set -uo pipefail

CMA="$(cd "$(dirname "$0")" && pwd)/cma"
CMA_DIR=$(mktemp -d)
export CMA_DIR
trap 'rm -rf "$CMA_DIR"' EXIT

pass=0
fail=0

# Run a command, assert exit code matches expected
expect_exit() {
    local name="$1"
    local expected="$2"
    shift 2
    local actual=0
    "$@" >/dev/null 2>&1 || actual=$?
    if [[ "$actual" == "$expected" ]]; then
        printf "PASS  %s\n" "$name"
        pass=$((pass + 1))
    else
        printf "FAIL  %s (expected exit %s, got %s)\n" "$name" "$expected" "$actual"
        fail=$((fail + 1))
    fi
}

# Run a command and assert stdout contains a substring
expect_contains() {
    local name="$1"
    local needle="$2"
    shift 2
    local output
    output=$("$@" 2>&1) || true
    if [[ "$output" == *"$needle"* ]]; then
        printf "PASS  %s\n" "$name"
        pass=$((pass + 1))
    else
        printf "FAIL  %s (output missing %q)\n" "$name" "$needle"
        fail=$((fail + 1))
    fi
}

# Run a command and assert stdout matches a regex (robust to whitespace)
expect_matches() {
    local name="$1"
    local pattern="$2"
    shift 2
    local output
    output=$("$@" 2>&1) || true
    if [[ "$output" =~ $pattern ]]; then
        printf "PASS  %s\n" "$name"
        pass=$((pass + 1))
    else
        printf "FAIL  %s (output didn't match /%s/)\n" "$name" "$pattern"
        fail=$((fail + 1))
    fi
}

# Assert all lines in a file parse as valid JSON
expect_json_valid() {
    local name="$1"
    local file="$2"
    if python3 -c 'import json,sys; [json.loads(l) for l in open(sys.argv[1])]' "$file" 2>/dev/null; then
        printf "PASS  %s\n" "$name"
        pass=$((pass + 1))
    else
        printf "FAIL  %s (file %s is not valid JSONL)\n" "$name" "$file"
        fail=$((fail + 1))
    fi
}

# Reset data between test groups
reset() { rm -rf "$CMA_DIR"/*.jsonl 2>/dev/null || true; }

# ---------------------------------------------------------------------------
# Meta commands
# ---------------------------------------------------------------------------

expect_exit     "version flag exits 0"           0 "$CMA" --version
expect_contains "version flag prints version"    "1.0" "$CMA" --version
expect_exit     "help flag exits 0"              0 "$CMA" --help
expect_exit     "no args exits 0 (shows help)"   0 "$CMA"
expect_contains "help lists all seven primitives" "cma surface" "$CMA" --help
expect_exit     "unknown command exits 1"        1 "$CMA" garbage

# ---------------------------------------------------------------------------
# Capture verbs
# ---------------------------------------------------------------------------

reset
expect_exit "miss with no description exits 1"   1 "$CMA" miss
expect_exit "miss with description succeeds"     0 "$CMA" miss "test miss"
expect_exit "miss with all flags succeeds"       0 "$CMA" miss "t" --surface docs --fm test --files a.md
expect_exit "miss with unknown flag exits 1"     1 "$CMA" miss "t" --bogus value

reset
expect_exit "decision succeeds"                  0 "$CMA" decision "TOPIC: choice (rationale)" --surface infra
expect_exit "decision with applies-when"         0 "$CMA" decision "X" --applies-when "surface=docs"

reset
expect_exit "reject succeeds"                    0 "$CMA" reject "OPTION: reason" --surface ui
expect_exit "reject with revisit-when"           0 "$CMA" reject "X" --revisit-when "if Python 4"

reset
expect_exit "prevented succeeds"                 0 "$CMA" prevented "almost X, did Y instead"
expect_exit "prevented with miss-id"             0 "$CMA" prevented "x" --miss-id abc123

# ---------------------------------------------------------------------------
# JSON validity (each capture writes valid JSONL)
# ---------------------------------------------------------------------------

reset
"$CMA" miss "simple description" >/dev/null
"$CMA" miss 'with "quotes"' >/dev/null
"$CMA" miss 'with \backslashes\' >/dev/null
"$CMA" miss "with
newline" >/dev/null
expect_json_valid "misses.jsonl is valid JSONL after edge inputs" "$CMA_DIR/misses.jsonl"

reset
"$CMA" decision "X" --surface a >/dev/null
"$CMA" reject "Y" --revisit-when 'if "Z"' >/dev/null
"$CMA" prevented "P" --miss-id m1 >/dev/null
expect_json_valid "decisions.jsonl is valid"     "$CMA_DIR/decisions.jsonl"
expect_json_valid "rejections.jsonl is valid"    "$CMA_DIR/rejections.jsonl"
expect_json_valid "preventions.jsonl is valid"   "$CMA_DIR/preventions.jsonl"

# ---------------------------------------------------------------------------
# Surface (operational verb)
# ---------------------------------------------------------------------------

reset
expect_contains "surface with empty data"        "No captures match." "$CMA" surface
"$CMA" miss "first miss" --surface docs >/dev/null
"$CMA" miss "second miss" --surface auth >/dev/null
"$CMA" decision "a decision" --surface infra >/dev/null
expect_contains "surface lists all captures"     "first miss" "$CMA" surface
expect_contains "surface --type miss filters"    "first miss" "$CMA" surface --type miss
expect_exit     "surface --limit 1 succeeds"     0 "$CMA" surface --limit 1
expect_contains "surface --surface docs filters" "first miss" "$CMA" surface --surface docs
expect_exit     "surface --bogus exits 1"        1 "$CMA" surface --bogus

# Surface --type filter excludes other types
output=$("$CMA" surface --type miss 2>&1)
if [[ "$output" != *"a decision"* ]]; then
    printf "PASS  %s\n" "surface --type miss excludes decisions"
    pass=$((pass + 1))
else
    printf "FAIL  %s\n" "surface --type miss leaks decisions"
    fail=$((fail + 1))
fi

# ---------------------------------------------------------------------------
# Distill (default mode + --review/--retire stubs)
# ---------------------------------------------------------------------------

reset
expect_exit     "distill no args exits 1"        1 "$CMA" distill
expect_exit     "distill --review with empty data" 0 "$CMA" distill --review
expect_contains "review reports no misses"       "No misses" "$CMA" distill --review
expect_exit     "distill default mode succeeds"  0 "$CMA" distill "Pattern Study before code" --scope project
expect_json_valid "core.jsonl valid after distill" "$CMA_DIR/core.jsonl"
expect_exit     "distill --bogus exits 1"        1 "$CMA" distill --bogus

# Build a pattern of recurring misses and check --review surfaces it
reset
"$CMA" miss "first" --surface auth --fm assumption-over-verification >/dev/null
"$CMA" miss "second" --surface auth --fm assumption-over-verification >/dev/null
"$CMA" miss "third elsewhere" --surface ui --fm basin-capture >/dev/null
expect_contains "review identifies recurring pattern" "2x" "$CMA" distill --review
expect_contains "review reports surface in pattern"   "auth" "$CMA" distill --review

# distill --retire
reset
"$CMA" distill "rule about auth" --surface auth >/dev/null
"$CMA" distill "rule about ui" --surface ui >/dev/null
expect_contains "retire with no match"           "No active core" "$CMA" distill --retire nonexistent
expect_contains "retire matches by substring"    "Retired 1" "$CMA" distill --retire auth
expect_contains "retire is idempotent"           "No active core" "$CMA" distill --retire auth
expect_json_valid "core.jsonl valid after retire" "$CMA_DIR/core.jsonl"

# ---------------------------------------------------------------------------
# Stats (default summary + --rejections/--preventions views + pending flags)
# ---------------------------------------------------------------------------

reset
expect_exit     "stats default runs"             0 "$CMA" stats
"$CMA" miss "one" >/dev/null
"$CMA" miss "two" >/dev/null
"$CMA" decision "d1" >/dev/null
"$CMA" reject "r1" >/dev/null
expect_matches  "stats counts misses"            'misses[[:space:]]+2' "$CMA" stats
expect_matches  "stats counts decisions"         'decisions[[:space:]]+1' "$CMA" stats
expect_matches  "stats counts rejections"        'rejections[[:space:]]+1' "$CMA" stats
expect_matches  "stats shows total"              'total[[:space:]]+4' "$CMA" stats
expect_contains "stats --rejections shows reject" "r1" "$CMA" stats --rejections
expect_exit     "stats --leaks exits 1 (pending)" 1 "$CMA" stats --leaks
expect_exit     "stats --bogus exits 1"          1 "$CMA" stats --bogus

# stats --recurrence
reset
expect_contains "recurrence empty data"          "No misses" "$CMA" stats --recurrence
"$CMA" miss "x" --surface auth --fm assumption-over-verification >/dev/null
expect_contains "recurrence single miss not recurring" "no patterns are recurring" "$CMA" stats --recurrence
"$CMA" miss "y" --surface auth --fm assumption-over-verification >/dev/null
expect_contains "recurrence detects pattern"     "2x" "$CMA" stats --recurrence
expect_contains "recurrence frames as not working" "not working" "$CMA" stats --recurrence

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "$pass passed, $fail failed"
[[ "$fail" -eq 0 ]] || exit 1
