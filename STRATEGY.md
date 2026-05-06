# cma Project Strategy

**Scope.** This document covers the cma project as a whole. The
project ships under one repository
([Clarethium/cma](https://github.com/Clarethium/cma)) with two
components:

- **cma** — the canonical bash reference implementation of the
  compound practice loop. Surface, primitives, and architecture
  live in `DESIGN.md`, `ARCHITECTURE.md`, `DATA.md`, and the CLI's
  own README. cma is the project's anchor; design decisions about
  the loop's shape are documented there and in
  [Lodestone](https://github.com/Clarethium/lodestone) (the
  methodology canon).
- **cma-mcp** — the Python MCP distribution wrapper. Lives under
  `cma-mcp/` in this repository. Most durable decisions in §6
  govern this component.

Both components are Apache-2.0, share one governance model
(`GOVERNANCE.md`), one set of cross-cutting docs (`SECURITY.md`,
`CITATION.cff`, `NOTICE`, `CONTRIBUTING.md`), one issue tracker,
and this strategy document. They release independently with
separate version tags and separate CHANGELOG files (`CHANGELOG.md`
for cma; `cma-mcp/CHANGELOG.md` for cma-mcp).

**Status:** v0.1 strategy. Versioned alongside the codebase;
durable decisions in §6 require an explicit overturn proposal to
change.

**Curator:** Lovro Lucic (BDFL, single-curator model for v0.x).

---

## 1. What cma-mcp is, in one sentence

cma-mcp is the Model Context Protocol distribution wrapper that brings
the [cma](https://github.com/Clarethium/cma) compound practice loop
to operator environments outside Claude Code's native hook surface.

## 2. What cma-mcp is not

- Not a reimplementation of cma. cma-mcp invokes the canonical bash
  cma binary as a subprocess. Drift is the enemy.
- Not a replacement for cma. Operators with shell access continue to
  use bash cma directly; cma-mcp is the layer for operators reaching
  the loop through an MCP-compatible client.
- Not a methodology. Failure-mode vocabulary, the practice loop's
  shape, calibration, and altitude all live in Lodestone. cma-mcp is
  methodology-agnostic at the substrate level: `--fm` is an opaque
  string passed through to cma.
- Not an applied vehicle in the [Frame Check](https://github.com/Clarethium/frame-check-mcp)
  sense. Frame Check applies Touchstone substrate to a specific
  context (structural framing analysis). cma-mcp does not apply a
  measurement substrate; it distributes a practice loop.

## 3. Position in the Clarethium body

The [Clarethium](https://github.com/Clarethium) empire publishes four
substantive open reference artifacts:

- **Lodestone** orients the operator's practice (methodology canon).
- **Touchstone** validates work against quality standards (measurement
  substrate).
- **cma** runs the compound practice loop on the operator's machine
  (terminal-side companion to Lodestone).
- **Frame Check** applies Clarethium methodology in a specific
  context (the first applied vehicle, distributed as an MCP).

cma-mcp is **distribution channel for cma**. Same loop, broader reach:

| Operator environment | Integration |
|---|---|
| Bash, zsh, fish | cma CLI directly |
| Claude Code | cma's PreToolUse + SessionStart hooks |
| Claude Desktop, Cursor, Cline, Continue.dev, any MCP client | cma-mcp |

The org profile names cma-mcp under "companion tooling": `cma + cma-mcp`.

## 4. Why a thin distribution layer is the right shape

cma-mcp's contribution is reach, not new capability. Three principles
follow:

- **Drift is the enemy.** Reimplementing cma's seven primitives in
  Python would duplicate a 1.0 surface (98-test suite, texture
  preservation, recurrence detection, leak detection) and lag behind
  canonical cma's evolution. The subprocess wrapper picks up cma's
  evolution automatically.
- **Empire-conformant payload discipline.** Every cma-mcp tool and
  resource response carries three sections (`analysis`,
  `agent_guidance`, `provenance`), matching the construct-honesty
  pattern established by frame-check-mcp. Agents passing cma-mcp
  output to users without attribution would strip the discipline that
  makes the loop's evidence worth citing; the agent_guidance block
  exists to prevent that.
- **Methodology-agnostic substrate.** Lodestone owns the failure-mode
  vocabulary; cma stores `--fm` as an opaque string; cma-mcp passes
  it through unchanged. An MCP server that bundled Lodestone's FM-1..10
  catalog would couple cma-mcp to Lodestone's release cadence and
  invert the canon-vs-companion separation.

## 5. Distribution

PyPI under the package name `cma-mcp`. Entry point installed as
`cma-mcp` (matching frame-check-mcp's convention: `frame-check-mcp =
"mcp_server:cli"`).

Version 0.1.0 is the first release; semver, with PEP 440 pre-release
markers (`.dev0`) during the dev window. CHANGELOG.md tracks the
release history in Keep a Changelog format.

DOI on Zenodo for citable form (allocated at first PyPI release).

## 6. Durable decisions

Decisions in this section are durable: they require an explicit
overturn proposal to change. New durable decisions land here when
their consequences span multiple components or when an early
contributor would otherwise need to rediscover the rationale.

### DD-1: Subprocess wrapper, not reimplementation

**Decision.** cma-mcp invokes the canonical `cma` bash binary as a
subprocess for every captured action. cma-mcp does not reimplement
cma's seven primitives in Python.

**Rationale.** bash cma is the canonical 1.0 reference implementation
with a 98-test suite. Any reimplementation introduces drift; the
empire's compounding logic favors thin wrappers over parallel codebases.
Reimplementation would also duplicate texture preservation, recurrence
detection, and leak-detection logic that bash cma already validates.

**Trade-off accepted.** cma-mcp requires a working `cma` binary on
the operator's `PATH`. See DD-3 for the platform stance.

### DD-2: Manual JSON-RPC, no MCP SDK dependency

**Decision.** cma-mcp implements the Model Context Protocol over
stdio using JSON-RPC 2.0 line-delimited, in-repo. No dependency on a
third-party MCP SDK.

**Rationale.** The MCP protocol surface used here (initialize,
tools/list, tools/call, resources/list, resources/read, ping,
notifications) is small enough that implementing it in-repo keeps
cma-mcp self-contained: no extra install step, no SDK version drift,
no transitive dependency exposure. This matches frame-check-mcp's
convention.

### DD-3: Bash dependency, WSL-universal stance

**Decision.** cma-mcp requires a working bash environment to invoke
the `cma` binary. On Linux and macOS, bash is part of the operating
system. On Windows, cma-mcp requires WSL.

**Rationale.** Every operator running an MCP-compatible AI client on
Windows (Claude Desktop, Cursor, Cline, Continue.dev) is reasonably
expected to have WSL available. Claude operators specifically tend to
use WSL because Claude Code's own integration patterns favor it.
Standalone Python reimplementation would lift this dependency at the
cost of DD-1's drift-vs-canonical concerns; the bash dependency is
the deliberately-paid price of canonical-cma alignment.

**Trade-off accepted.** Operators on a pure Windows host with no WSL
cannot run cma-mcp. This is named clearly in the README so no operator
reaches install-time confusion.

### DD-4: Methodology-agnostic substrate

**Decision.** cma-mcp stores `--fm` (failure-mode tag) as an opaque
string. cma-mcp does not bundle Lodestone's FM-1..10 catalog or any
other methodology's vocabulary.

**Rationale.** Vocabulary is the methodology's responsibility (in
Clarethium's case, Lodestone). Bundling vocabulary into the substrate
inverts the canon-vs-companion separation. Operators who want
methodology-aware classification at capture time use bash cma's
`CMA_FM_CLASSIFIER` plugin hook, which cma-mcp inherits because it
shells out to bash cma.

### DD-5: Three-section payload discipline

**Decision.** Every tool response and every resource read returns a
JSON payload with three top-level sections: `analysis` (the data),
`agent_guidance` (what the tool can and cannot tell the agent, how
to cite faithfully), and `provenance` (versions, license, cost,
citation). Adversarial tests pin the structure (see
`tests/test_payload_determinism.py`).

**Rationale.** Established by frame-check-mcp; preserved here because
agents passing cma-mcp output to users without attribution would
strip the construct-honesty discipline. Surfacing "how to cite
faithfully" inside the payload is the structure that carries the
discipline forward.

### DD-6: Schema parity with bash cma

**Decision.** cma-mcp reads the same JSONL files bash cma writes
(`misses.jsonl`, `decisions.jsonl`, `rejections.jsonl`,
`preventions.jsonl`, `core.jsonl`, `surface_events.jsonl`). cma-mcp
does not write records itself; bash cma does. Any future Python-side
write path must produce records byte-identical in field set to bash
cma's writes.

**Rationale.** Forward and reverse compatibility with bash cma are
required for operators who run both interfaces. cma's DATA.md is the
canonical schema reference.

### DD-7: Apache-2.0 + CC-BY-4.0 licensing aligned with empire

**Decision.** Code under Apache-2.0. Documentation and any reference
data under CC-BY-4.0. Matches the rest of the Clarethium body.

---

## 7. Explicitly deferred

Items deferred until evidence accumulates or an explicit forcing
function arrives:

- **Resource-update notifications** (`notifications/resources/updated`).
  Most MCP clients re-fetch resources per read; the notification
  channel adds complexity without clear demand. Defer until a client
  asks.
- **Session-priming resource analogous to bash cma's SessionStart
  hook.** MCP has no native session-start hook; closest equivalent
  is the `instructions` field on the `initialize` handshake. v0.1
  ships a minimal `instructions` field. Richer session-priming
  awaits operator feedback on whether `instructions` is enough.
- **Validation program for the loop closing through cma-mcp.**
  Designing the empirical claim ("with cma-mcp installed,
  prevention/miss ratio measured on a longitudinal corpus") and the
  protocol to test it is post-launch work. Tracked in
  `cma-mcp/docs/VALIDATION_PROGRAM.md`.

## 8. Where decisions live

A decision is not a decision until it lands in an authoritative
source.

| Decision type | Authoritative source |
|---|---|
| Strategy and durable decisions | `STRATEGY.md` (this file) |
| Architectural decisions | `DECISIONS.md` |
| Governance mechanics (who decides, by what process) | `GOVERNANCE.md` |
| Contribution mechanics | `CONTRIBUTING.md` |
| Release history | `CHANGELOG.md` |
| MCP protocol surface | `cma-mcp/docs/MCP_SERVER.md` |
| Anticipated critiques (construct-honesty discipline) | `cma-mcp/docs/ANTICIPATED_CRITIQUES.md` |
| Validation program | `cma-mcp/docs/VALIDATION_PROGRAM.md` |
| cma's CLI surface, primitives, schema | `DESIGN.md`, `ARCHITECTURE.md`, `DATA.md` |
| cma's release history | `CHANGELOG.md` |
| cma-mcp's release history | `cma-mcp/CHANGELOG.md` |
