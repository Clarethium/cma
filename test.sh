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
# Operational verb stubs (run without error)
# ---------------------------------------------------------------------------

reset
expect_exit     "surface stub runs"              0 "$CMA" surface
expect_exit     "distill stub runs"              0 "$CMA" distill --review
expect_exit     "stats stub runs"                0 "$CMA" stats

# ---------------------------------------------------------------------------
# Stats stub reports counts correctly
# ---------------------------------------------------------------------------

reset
"$CMA" miss "one" >/dev/null
"$CMA" miss "two" >/dev/null
"$CMA" decision "d1" >/dev/null
expect_contains "stats counts misses"            "misses       2" "$CMA" stats
expect_contains "stats counts decisions"         "decisions    1" "$CMA" stats

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "$pass passed, $fail failed"
[[ "$fail" -eq 0 ]] || exit 1
