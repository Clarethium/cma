# Validation Program

This document specifies the empirical validation plan for cma-mcp:
the claims the project makes, the data needed to test them, and the
post-launch protocol for accumulating evidence. The program is
pre-registered so the test design is fixed before the data arrives.

The structure follows frame-check-mcp's
[VALIDATION_PROGRAM.md](https://github.com/Clarethium/frame-check-mcp/blob/master/docs/VALIDATION_PROGRAM.md)
pattern: separate the protocol-conformance layer (does cma-mcp
faithfully expose cma's loop) from the loop-closing layer (does the
loop actually close when distributed via MCP).

---

## Layer 1: Protocol conformance (validated at every release)

**Claim.** Every cma-mcp release faithfully exposes bash cma's seven
primitives and four resource surfaces with the three-section payload
discipline intact.

**Evidence.** The pytest suite at `tests/`. Every release passes:

- 34 tests across protocol conformance, three-section payload
  determinism, JSONL parsing tolerance, and subprocess-wrapper
  isolation.
- The `--version` install fingerprint matches the published wheel's
  metadata.
- The `--test` offline sanity check produces a valid three-section
  payload against the operator's `~/.cma/` data.

**Status.** Validated continuously via CI on every PR (pytest runs
on Python 3.10, 3.11, 3.12). Coverage extension toward
adversarial-stdio roundtrips planned for v0.2 (see `docs/ANTICIPATED_CRITIQUES.md` C-8).

---

## Layer 2: Distribution faithfulness (one-shot validation)

**Claim.** Records captured through cma-mcp are byte-equivalent to
records captured through bash cma directly. An operator can switch
between cma CLI and cma-mcp without producing a heterogeneous
corpus.

**Test design.**

1. Empty `~/.cma/` directory.
2. Capture a fixed sequence of 20 records via bash cma directly:
   5 misses (mix of texture-preserved and bare), 5 decisions (with
   `applies_when`), 5 rejections (with `revisit_when`), 5
   preventions (with `miss_id` linkages).
3. Read all `*.jsonl` files; record byte-content as snapshot A.
4. Empty `~/.cma/` again.
5. Capture the same 20 records via cma-mcp tool calls (identical
   field values).
6. Read all `*.jsonl` files; record byte-content as snapshot B.
7. Compare: A and B must differ only in `id` (random suffix) and
   `timestamp` (UTC clock). Every other field byte-identical.

**Status.** Designed; one-shot pre-PyPI-publish. Result publishes to
`docs/internal/DISTRIBUTION_FAITHFULNESS_<date>.md` with the
captured snapshots.

---

## Layer 3: Loop closure through MCP exposure (longitudinal)

**Claim (load-bearing for the whole project).** Operators who run
the cma compound practice loop through an MCP client (Claude
Desktop, Cursor, etc.) experience the loop closing — surfaced
warnings actually catching repeats — at a rate not statistically
distinguishable from operators running the same loop through cma's
shell hooks or CLI directly.

This is the empire's core compounding claim, instantiated for
cma-mcp's distribution layer specifically. cma's loop is supposed
to close. cma-mcp's value depends on the loop closing through MCP
exposure too.

**Test design.**

1. **Cohort.** Operators who install cma-mcp from PyPI and opt in
   to the validation program by setting `CMA_MCP_VALIDATION=1` (the
   variable is read once at server start; opt-in only).
2. **Measurement window.** Rolling 90-day window per operator, with
   minimum 30 days of activity to qualify.
3. **Metrics.** Per operator, computed monthly:
   - **prevention/miss ratio**: count(preventions) /
     count(misses) over the window.
   - **leak rate**: count(leaks from `cma stats --leaks`) /
     count(misses).
   - **recurrence rate**: count(misses where prior similar miss
     existed at capture time) / count(misses).
4. **Comparison.** Two cohorts:
   - **Cohort A (cma-mcp)**: operators capturing primarily through
     cma-mcp tool calls.
   - **Cohort B (cma direct)**: operators capturing primarily
     through cma CLI / Claude Code hooks.
5. **Test.** Two-sample t-test on prevention/miss ratio with α=0.05
   (pre-registered; no peeking).
6. **Falsification criterion.** If Cohort A's mean prevention/miss
   ratio is statistically significantly lower than Cohort B's
   (p < 0.05) at the 90-day mark with N ≥ 20 per cohort, cma-mcp's
   distribution claim is falsified. Public report. Strategy
   document update.

**Cohort assignment.** Operator self-classifies primary capture
channel via `CMA_MCP_VALIDATION_COHORT` env var (values: `mcp`,
`direct`, `mixed`). Operators with `mixed` are excluded from the
two-cohort comparison. Cohort assignment is recorded once per
operator per measurement window; cross-window switching is
disallowed (the operator stays in their first declared cohort
through the window's end to prevent post-hoc cohort selection).

**Data shipping.** Operators export their `~/.cma/` corpus as a
zip and submit through a separate intake (not part of cma-mcp's
runtime; cma-mcp ships zero telemetry). Submission is opt-in,
explicit, and named. Anonymization happens at the operator's choice
before export.

**Status.** Designed; awaits release of cma-mcp on PyPI plus
sufficient cohort N (≥20 per arm). First report at 90 days
post-launch or N=20 per arm, whichever comes later.

---

## Layer 4: Anti-claim (what we are NOT testing)

cma-mcp's validation program does NOT claim:

- That the cma loop is more effective than no loop at all (that is
  cma's claim, not cma-mcp's).
- That cma-mcp produces "better" captures than the CLI (the
  capture quality is a function of operator discipline, not of the
  distribution channel).
- That MCP exposure improves loop adoption (a separate empirical
  question; would require comparing operator counts pre and post
  MCP availability).

The narrow claim cma-mcp owns is **distribution faithfulness**
(Layer 2) plus **loop-closing parity through MCP exposure** (Layer
3). Anything broader belongs to cma's or Lodestone's validation.

---

## Reporting cadence

- **Layer 1**: every release. CI green required to publish.
- **Layer 2**: once, pre-PyPI-publish. Re-run if bash cma's record
  schema or cma-mcp's wrapper changes shape.
- **Layer 3**: 90-day post-launch first report; quarterly after.
  Reports land in `docs/receipts/` and on `blog.clarethium.com`.

---

*Pre-registration is the construct-honesty discipline that makes
empirical claims about compound learning worth taking. The plan
above is fixed before data arrives; revisions to the plan happen
only via explicit `STRATEGY.md` durable-decision overturns and are
named publicly.*
