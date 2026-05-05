# cma

Executable compound practice loop. The terminal-side companion to [Lodestone](https://github.com/Clarethium/lodestone).

## What this is

cma is the operator's tool for running the compound practice loop on the local machine. It captures failures, surfaces warnings at the moment of action, tracks decisions, and detects recurrence patterns. It is the executable instantiation of the practice defined in Lodestone.

The methodology lives in Lodestone. cma is what running that methodology looks like in a terminal.

## Status

cma 1.0 reference implementation in progress. Five of seven primitives functional: the four capture verbs (`cma miss`, `cma decision`, `cma reject`, `cma prevented`) and `cma surface` (filter and recency-sort prior captures). Two operational verbs remain partial: `cma distill` (stubbed) and `cma stats` (default summary works; flag-based views pending).

The full surface is specified in [DESIGN.md](DESIGN.md). Additive features (action-time injection, texture preservation, counterfactual capture, recurrence detection) layer on without changing the locked surface.

## Quick start

Clone the repository and add the script to your `PATH`:

```bash
git clone https://github.com/Clarethium/cma.git
ln -s "$(pwd)/cma/cma" ~/.local/bin/cma   # or copy to anywhere on PATH
```

Capture a failure:

```bash
cma miss "fix removed the error message instead of addressing the defect" \
    --surface infra --fm speed-over-understanding
```

Captures are written to `~/.cma/` as JSON Lines files (one record per line, append-only). The data directory can be overridden with `CMA_DIR=/path/to/data cma ...`.

Run `cma --help` for the full command surface.

## Testing

```bash
./test.sh
```

Tests cover all capture verbs (normal and edge cases including special characters, missing arguments, unknown flags) and the operational-verb stubs.

## The Clarethium body

cma sits alongside three reference artifacts published by Clarethium:

- **Touchstone** validates work against quality standards.
- **Whetstone** sharpens craft.
- **Lodestone** orients practice.

cma is the executable companion to Lodestone. The doctrine is in Lodestone; the running code is here.

## License

Apache 2.0. See [LICENSE](LICENSE).

## Author

L. Lucic. Published under Clarethium.
