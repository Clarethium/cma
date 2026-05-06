# Architectural Decisions

This file records architectural decisions for the cma project at
finer grain than `STRATEGY.md` durable decisions. Entries are dated
and named. Decisions here can be revised through normal pull
request review; durable decisions in `STRATEGY.md §6` require an
explicit overturn proposal.

Entries to date are scoped to the **cma-mcp** component (the
Python MCP wrapper under `cma-mcp/`). Architectural decisions
governing the bash cma reference implementation are documented in
`DESIGN.md`, `ARCHITECTURE.md`, and `DATA.md` at the repository
root.

Newest first.

---

## AD-007: Tool surface is seven verbs, resource surface is four URIs

**Date:** 2026-05-06

**Decision.** Tool surface mirrors bash cma's seven primitives:
`cma_miss`, `cma_decision`, `cma_reject`, `cma_prevented`,
`cma_distill`, `cma_surface`, `cma_stats`. Resource surface is four
URIs for read-only context: `cma://decisions`, `cma://rejections`,
`cma://core`, `cma://stats`.

**Rationale.** A model that knows bash cma's CLI knows cma-mcp's
tools without retraining. `cma_distill` and `cma_stats` carry
`mode`/`view` arguments rather than splitting into multiple tools to
keep the tool count at the bash cma 1.0 surface (seven). `cma_surface`
remains a tool, not a resource, because it logs `surface_events.jsonl`
as a side effect (load-bearing for `cma stats --leaks`).

Resources are reserved for context the agent reads to orient itself
(decisions, rejections, core learnings, stats summary). Calling
`cma stats` for non-default views (`--leaks`, `--recurrence`,
`--behavior`, `--preventions`, `--rejections`) goes through the
`cma_stats` tool with a `view` arg.

---

## AD-006: cma-mcp does not bundle Lodestone's failure-shape catalog

**Date:** 2026-05-06

**Decision.** No `cma://failure-shapes` resource. Tool descriptions
for `cma_miss` and `cma_prevented` reference Lodestone's FM-1..10 as
an example methodology but do not enumerate it.

**Rationale.** STRATEGY DD-4. Methodology vocabulary lives in
Lodestone; bundling a frozen copy in cma-mcp couples release cadence
and inverts canon-vs-companion separation. Operators who want the FM
catalog read Lodestone directly; operators who want autoclassification
wire `CMA_FM_CLASSIFIER` per cma's plugin convention.

---

## AD-005: Stdio transport only

**Date:** 2026-05-06

**Decision.** cma-mcp ships stdio transport. SSE, WebSocket, and HTTP
transports are explicitly out of scope for v0.1.

**Rationale.** Stdio is the universally supported transport across MCP
clients (Claude Desktop, Cursor, Cline, Continue.dev). Operators who
need multi-client server-side deployment can use one of the
forthcoming MCP gateway projects. Adding transports inside cma-mcp
would expand the surface beyond its distribution-wrapper role.

---

## AD-004: subprocess.run with argv-array, never shell=True

**Date:** 2026-05-06

**Decision.** Every bash cma invocation goes through
`subprocess.run([...], shell=False)` with an argv array. Operator
input never gets concatenated into a shell-interpreted string.

**Rationale.** Argument injection is the most likely abuse path for a
local MCP server. The argv-array discipline makes injection
structurally impossible: any operator-supplied string lands in a
single `argv[i]` slot and bash cma's argument parser treats it as
data, not as code.

---

## AD-003: 5-second timeout on every subprocess call

**Date:** 2026-05-06

**Decision.** `subprocess.run` calls all carry `timeout=5`. On
timeout, cma-mcp returns an `isError: true` response naming the
timeout and the partial command. The MCP server stays responsive; the
caller decides whether to retry.

**Rationale.** Matches bash cma's own failure-isolated discipline
(`hooks/cma-pre` 5-second timeout on `cma surface`). A hung cma
process must not hang the MCP server.

---

## AD-002: schema_version pinned to "1.0", any new schema_version
emitted by bash cma surfaces as a parse warning

**Date:** 2026-05-06

**Decision.** cma-mcp's JSONL parser treats records with
`schema_version: "1.0"` as native, records without that field as
legacy (parses leniently), and records with any other
`schema_version` value as a parse warning surfaced in `provenance`.

**Rationale.** Per cma's DATA.md, schema_version is the migration
gate. cma-mcp's wrapper role means it must not silently interpret a
schema it does not recognize; surfacing the unknown schema in
`provenance` lets the caller (model and downstream user) know the
data carries assumptions cma-mcp cannot validate.

---

## AD-001: Manual JSON-RPC, no MCP SDK dependency

**Date:** 2026-05-06

**Decision.** Implement the MCP protocol directly in `mcp_server.py`
using JSON-RPC 2.0 over stdio. No third-party MCP SDK in
`pyproject.toml` dependencies.

**Rationale.** STRATEGY DD-2. Echoes frame-check-mcp's
self-containment convention. The protocol surface used here
(initialize, tools/list, tools/call, resources/list, resources/read,
ping, notifications) fits in a few hundred lines and removes a class
of version-skew failures.

---

*Future architectural decisions append above this line, newest first.*
