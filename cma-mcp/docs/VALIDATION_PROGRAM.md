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

- pytest cases (currently 36) across protocol conformance,
  three-section payload determinism, JSONL parsing tolerance,
  subprocess-wrapper isolation, and install-fingerprint
  git_sha fallback. Wire-protocol subprocess roundtrip tests
  arrive in v0.2 (see `docs/ANTICIPATED_CRITIQUES.md` C-8).
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

This claim is core to the project's evidence base, instantiated for
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

## Interim evidence (single-operator pilot, 2025-12-10 → 2026-05-07)

The Layer 3 cohort study is the formal validation. It requires
N≥20 operators per arm and 90 days of activity, conditions that
cannot be met before PyPI publication. The evidence below is the
single-operator pilot the project author has run on themselves
during cma's pre-1.0 development. It is published here because
not publishing it would underclaim, and overclaiming it would
substitute lived experience for a cohort study. Both are wrong.

**Conditions.**

- N = 1 operator (the project author).
- Window: 2025-12-10 (earliest dated capture in the active corpus)
  through 2026-05-07. ~150 days continuous, with daily activity in
  most weeks. Earlier captures exist in archived files; the active
  set was preserved through one distillation cycle.
- Daily-driver binary: a working variant of cma that predates the
  canonical 1.0 reference implementation. The methodology is
  identical; minor schema-shape differences mean the operator's
  evidence carries a cma-binary-fidelity caveat that the cohort
  study is designed to remove.
- AI client: Claude Code with bash cma's PreToolUse and
  SessionStart hooks throughout the window. Context-window upgrade
  to ~1M tokens (Claude Sonnet 4.5+) landed mid-window.

**What the corpus shows.**

| Capture type | Active count | Window |
|---|---:|---|
| Misses | 208 | 2025-12-10 → 2026-05-07 |
| Decisions | 47 | 2025-12-05 → 2026-04-17 |
| Rejections | 15 | 2026-01-27 → 2026-03-14 |
| Core distillations | 6 | 2026-02-26 → 2026-04-24 |
| Lessons | 63 | 2025-12-09 → 2026-01-15 |

Failure-mode distribution: FM-3 (Happy Path Only) 109; FM-1
(Speed Over Understanding) 26; FM-6 (Assumption Over
Verification) 25; FM-8 (Scope Abandonment) 11. Surface
distribution: general 99, ui 48, docs 38, infra 9, git 7, db 5,
api 2.

**What appears to compound.**

The corpus itself. 339 active records survived ~5 months of
continuous use, ~30 context compactions, and at least one model
generation upgrade without manual reset. Decisions and rejections
captured early in the window remain queryable late in the window.
The artifact persists where session state does not. This is the
strongest replicated observation.

Distillation to core. 6 core promotions across ~3 months,
hand-curated by the operator from the recurrence patterns.
Cadence is slow and deliberate by design — the gate to core is
"does this restructure how thinking works", not "did this happen
twice".

Decision tracking. 47 decisions captured. The operator's
qualitative observation: silently-rebuilt rejected branches —
the failure mode that motivates `cma reject` — happens
materially less often when prior rejections are surfaced at
session start. Not measured against a counterfactual; reported as
operator-experience.

**What did not compound the way the design predicted.**

Per-turn surface injection. With a 1M-token context window, the
marginal value of surfacing prior captures into each turn is
smaller than it was at 200K. The model already carries enough
state in-context that the surfaced 5–15 captures contribute less
to that turn's reasoning than the equivalent surface did at
narrower windows. The CAPTURE side of the loop continued to
compound through the upgrade; the SURFACE side has variable
marginal value depending on context size.

Implication: the load-bearing function of cma is shifting from
session-state augmentation toward durable-corpus retention. The
artifact survives across context windows; the per-session
injection's contribution is window-size-dependent. cma-mcp's MCP
distribution path inherits this — the value of `cma_surface` will
also be context-window-dependent in the receiving client.

**What is missing from the data.**

`cma prevented` captures: zero in the active corpus. The operator
does not formally record when a surfaced warning catches a repeat.
This is an operator-recording habit gap, not necessarily a
loop-function gap — the operator's qualitative experience is that
warnings do catch repeats — but without the prevention record the
loop's prevention/miss ratio cannot be computed. Layer 3's
falsification criterion depends on this metric. Closing the
recording gap is a methodology discipline (`cma prevented` becomes
part of the post-correction reflex) rather than a code change.

The cohort study (Layer 3) is the test that turns "appears to
compound" into "compounds at rate X relative to control." Single-
operator evidence is necessary for the project to ship at all but
is not sufficient to validate the cross-operator claim that the
loop closes for adopters generally.

**Honest summary.**

cma's CAPTURE + DISTILL + RETAIN cycle compounds on single-operator
evidence: the corpus persists, distillation produces durable
learnings, decision tracking visibly reduces silent rebuilds.
cma's SURFACE → CATCH → PREVENT cycle is operator-experienced as
working but is not formally measured (zero prevention captures);
its claim is interim. cma-mcp's distribution path adds reach
without changing this evidence — the MCP layer is thin, and the
loop closes (or doesn't) in cma's substrate, not in the wrapper.

What the project ships at 0.1 is a publication of the
infrastructure, the methodology, and the single-operator pilot
evidence in honest shape. The cohort comparison is what comes
next.

---

## Reporting cadence

- **Layer 1**: every release. CI green required to publish.
- **Layer 2**: once, pre-PyPI-publish. Re-run if bash cma's record
  schema or cma-mcp's wrapper changes shape.
- **Layer 3**: 90-day post-launch first report; quarterly after.
  Reports land in `docs/receipts/` and on `blog.clarethium.com`.
- **Interim evidence**: refreshed at major project milestones
  (post-publish, post-cohort-study). The section above gets dated
  updates rather than rewrites; previous snapshots are preserved
  in git history so the trajectory is visible.

---

*Pre-registration is what makes empirical claims about compound
learning worth taking: the plan above is fixed before data arrives.
Revisions are tracked in `DECISIONS.md` and named publicly when
they occur.*
