# Changelog

All notable changes to cma are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] (1.0.0-dev)

### Added

- Initial cma 1.0 reference implementation (bash, no external dependencies; python3 used for JSON escape).
- Capture verbs fully functional: `cma miss`, `cma decision`, `cma reject`, `cma prevented`.
- `cma surface` with `--surface`, `--file`, `--type`, `--limit` filters and recency-ordered output.
- `cma distill` fully functional: default mode promotes a learning to permanent surfacing; `--review` shows recurring miss patterns as distillation candidates; `--retire <pattern>` marks matching core learnings as retired (preserved as retirement records).
- `cma stats` default summary plus `--rejections`, `--preventions`, and `--recurrence` views functional; `--leaks` view pending pending action-time injection data.
- Test suite (`test.sh`) with 42 cases covering all functional paths, edge cases (special characters, missing args, unknown flags), and JSON validity.
- CI workflow (GitHub Actions) running the test suite on every push and pull request.
- DESIGN.md specifying the seven-primitive surface and the migration from the working version.
- README with quick-start, status, and license information.

### Pending for 1.0.0

- `cma stats --leaks`: show failures that occurred despite active warnings (genuinely blocked on action-time injection data; manual surfacing alone produces a misleading signal).

### Future (post-1.0)

- Action-time injection: hook integration so captures surface automatically at the moment of operator action, not only on manual `cma surface` invocation.
- Texture preservation on misses: conversation excerpt, intended action, and corrected action captured alongside the description.
- Counterfactual capture: explicit "what was about to happen versus what happened" data structure for studying basin transitions.
- Per-project data scoping: optional separation of captures by project rather than a single global directory.
- Trained classifier on accumulated labeled corpus (long-term, requires data accumulation).
