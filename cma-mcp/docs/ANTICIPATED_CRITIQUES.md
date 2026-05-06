# Anticipated critiques

This document enumerates the strongest adversarial readings of
cma-mcp's design, named openly so a reader does not have to
discover them through use. Each critique is followed by the
project's current position. Some critiques are accepted (a
trade-off cma-mcp deliberately pays); some are deflected (a
misreading of the design); some are open questions (cma-mcp does
not yet have an answer beyond candor).

The discipline of self-enumeration is shared with [frame-check-mcp's
ANTICIPATED_CRITIQUES.md](https://github.com/Clarethium/frame-check-mcp/blob/master/docs/ANTICIPATED_CRITIQUES.md).
Both projects publish their weak points up front because surfacing
limits is the price of construct-honesty.

---

## C-1: "Why ship an MCP for cma at all? Bash cma already has Claude Code hooks."

**Position: accepted as a real question; answered by reach.**

bash cma's Claude Code hooks (PreToolUse + SessionStart) cover one
operator environment. cma-mcp covers the rest: Claude Desktop,
Cursor, Cline, Continue.dev, and any future MCP-compatible client.
Operators using these clients have no path to cma's compound
practice loop without the MCP layer. The contribution is reach,
not new capability. STRATEGY §3.

The trade-off: each new MCP client expands cma-mcp's surface even
though cma-mcp itself stays thin. That is by design.

## C-2: "A subprocess wrapper is fragile. Why not reimplement cma in Python?"

**Position: accepted as a trade-off, deliberately paid.**

Reimplementation would lift the bash dependency and remove
subprocess-launch overhead. It would also duplicate cma's
seven-primitive surface (98-test suite as of 1.0), texture
preservation, recurrence detection, and leak-detection logic in a
parallel codebase that lags whenever bash cma evolves. Drift is the
enemy.

The wrapper is fragile in a narrow sense: a missing `cma` binary
fails the tool dispatch. cma-mcp surfaces this clearly (the
`isError` payload names `reason: missing_binary` and points the
operator at the install URL). No silent failures.

STRATEGY DD-1; further evidence that thin distribution wrappers are
the empire-correct shape: frame-check-mcp's similar choice to keep
the analysis library separate from the MCP packaging.

## C-3: "Bash dependency means Windows-native operators are excluded."

**Position: accepted; WSL is the documented stance.**

STRATEGY DD-3 is explicit. Operators on a pure Windows host with no
WSL cannot run cma-mcp. The README and `pyproject.toml` classifiers
document the platform stance up front so no operator reaches
install-time confusion. Every operator running an MCP-compatible AI
client on Windows is reasonably expected to have WSL available, and
Claude operators specifically tend to use WSL because Claude Code's
own integration patterns favor it.

If WSL universality fails — if a meaningful population of Windows
operators using MCP clients lacks WSL — the answer is a separate
Python-native cma reimplementation, not a hybrid. cma-mcp would
remain the thin wrapper.

## C-4: "The three-section payload is verbose. Plain stdout would be cleaner."

**Position: deflected. Verbosity is the construct-honesty tax.**

Plain stdout would let an agent paraphrase cma's output as the
agent's own observation, stripping the citation discipline that
makes the loop's evidence worth keeping. The agent_guidance and
provenance blocks are not decoration; they are the structure that
carries the discipline forward to whatever the agent shows the
user.

frame-check-mcp ships the same pattern (its
`how_to_cite_faithfully` field exists for the same reason). Both
projects accept the verbosity tax because the alternative is
construct-honesty erosion at the agent boundary.

## C-5: "cma-mcp does not parse cma stdout into structured records. Why?"

**Position: deferred to v0.2; v0.1 passes stdout through unchanged.**

cma's stdout shape varies by verb (a confirmation for `cma miss`, a
table for `cma stats --leaks`). Robust parsing requires knowing each
verb's exact output format, which couples cma-mcp to bash cma's
formatting choices. v0.1 includes the raw stdout in
`analysis.cma_stdout` so callers see what cma reported; v0.2 may add
structured `analysis.record` extraction for the capture verbs whose
output format is stable.

Forward-compat: when bash cma changes its output format, cma-mcp
v0.1 keeps working (the raw text passes through). v0.2's structured
extraction would require versioning.

## C-6: "cma-mcp is methodology-agnostic but the README references Lodestone repeatedly."

**Position: deflected. Reference is not bundling.**

Methodology-agnostic means the substrate (cma's data files, cma-mcp's
schemas) does not encode any specific methodology's vocabulary.
Operators using Lodestone tag captures with FM-1..10; operators using
a different methodology tag with that methodology's catalog. cma-mcp
does not validate, expand, or interpret the tag.

The README and tool descriptions reference Lodestone because it is
the canonical Clarethium methodology and the empirical case study
operators are most likely to read. References are pointers, not
enforcement. STRATEGY DD-4; pinned by the
`test_tool_descriptions_reference_lodestone_for_methodology` test
which forbids bundling FM definitions while requiring the pointer.

## C-7: "Single-curator BDFL governance is fragile. What if Lovro disappears?"

**Position: accepted; named-authorship is the v0.x credibility asset.**

GOVERNANCE.md is honest: cma-mcp is a single-curator project. The
move to a named-reviewer model is a `STRATEGY.md` durable decision
trigger when a sustained external contributor exists. Until then,
the named curator is the credibility asset (matching frame-check-mcp's
explicit position).

Disappearance is a real risk for any single-curator open-source
project. The mitigations: Apache-2.0 license (anyone can fork);
public methodology in Lodestone (non-cma-mcp operators retain access
to the canon); bash cma is canonical and lives independently.

## C-8: "cma-mcp's tests do not exercise the live MCP wire protocol over a real subprocess pair."

**Position: accepted gap; in-process dispatch tests cover the
handler logic, but full wire-level adversarial testing is a v0.2
target.**

Current tests invoke the dispatcher's request handlers directly
(via `conftest.call_handler`). They cover schema validation,
three-section payload discipline, JSONL parsing tolerance, and
error envelopes. They do not exercise the JSON-RPC parser through
real stdin/stdout pipes against a separate process.

frame-check-mcp's `test_mcp_adversarial.py` runs subprocess
roundtrips at the wire level (rapid-fire sequential stdio,
determinism normalization). cma-mcp v0.2 will add an equivalent.

## C-9: "Schema-version handling is permissive: legacy records and unknown schema versions both pass."

**Position: deliberate, with surface in provenance.**

A strict schema would reject legacy records (no schema_version
field) and break operators with pre-1.0 cma data. cma-mcp's read
path accepts both legacy and unknown-schema-version records, but
counts each in the `provenance.data_source` block so the caller
sees the parse-trust signal. The discipline is "tolerant read,
honest provenance" — match cma's own stance (`cma`'s tolerant-read
discipline, CHANGELOG "Tolerant read").

If a future schema-version is genuinely incompatible, cma-mcp will
add a strict check at parse time and emit an `isError` for that
specific schema. Until then, permissiveness with full provenance is
the right balance.

## C-11: "Same-repo with cma is a monorepo and monorepos rot. Why not a separate Clarethium/cma-mcp like frame-check-mcp?"

**Position: deflected. Wrapper-of relationships belong with their
wrapped subject; substrate-uses relationships do not.**

cma-mcp wraps cma as a thin subprocess layer: every flag is a tool
argument, every JSONL field a parser concern, the surface-events
schema load-bearing for leak detection. That coupling makes drift
the failure mode and the wrapper-vs-wrapped repo split a
coordination tax the empire's compounding logic actively works
against (DECISIONS AD-008).

frame-check-mcp's separate-repo pattern doesn't apply because it
*uses* Touchstone as a substrate. Touchstone can ship a new
measurement layer without forcing a frame-check-mcp release; the
relationship is loose enough that separation has value.
Substrate-uses and wrapper-of are structurally different and
accept different repo shapes.

The monorepo cost is mitigated by: two release tracks via tag
prefixing (`cma-1.x`, `cma-mcp-0.x`); per-component CHANGELOG;
path-filtered CI (`tests-mcp.yml` only fires on `cma-mcp/**`
changes, `test.yml` only on bash cma changes); clear component
partition in the repo tree. The repo can be split via
`git filter-repo` if a future evidence point demands it
(AD-008 §Reversibility).

**Concrete worked example of the drift the consolidation prevents.**
cma's DATA.md schema names a JSONL field `revisit_when` on
rejection records. If cma adds a new optional field tomorrow
(say `revisit_after_date`) and the wrapper lives in a separate
repo, three states become possible: cma-mcp parses the new field
(but cma's release lags), cma writes the new field but cma-mcp
ignores it, or both update but releases interleave. Same-repo
collapses the three to one: a PR that adds the field touches both
sides and a single review confirms the alignment.

## C-10: "`cma_surface` is a tool, not a resource. That's surprising for a read-only query."

**Position: deliberate; the side effect is load-bearing.**

`cma surface` writes to `surface_events.jsonl` for every invocation.
The leak-detection view (`cma_stats view=leaks`) joins these events
against subsequent misses to flag failures that occurred despite a
warning being surfaced. Without the log, leak detection cannot
function.

Modeling `cma_surface` as a resource would either suppress the log
(breaking leak detection) or have the resource act as a side-effect
producer (violating the MCP norm that resources are read-only).
Tool semantics fit the actual behavior. DECISIONS AD-007.

---

*Open critiques worth raising are welcome at the issue tracker.
Construct-honesty improves when the questions arrive earlier.*
