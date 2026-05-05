# cma

Executable compound practice loop. The terminal-side companion to [Lodestone](https://github.com/Clarethium/lodestone).

## What this is

cma is the operator's tool for running the compound practice loop on the local machine. It captures failures, surfaces warnings at the moment of action, tracks decisions, and detects recurrence patterns. It is the executable instantiation of the practice defined in Lodestone.

The methodology lives in Lodestone. cma is what running that methodology looks like in a terminal.

## Status

cma 1.0 reference implementation. All seven primitives present in the surface. Five fully functional: `cma miss`, `cma decision`, `cma reject`, `cma prevented`, `cma surface`. Two partial: `cma distill` (default mode promotes learnings to permanent surfacing; `--retire` and `--review` stubbed), `cma stats` (default summary plus `--rejections` and `--preventions` views work; `--leaks` and `--recurrence` views require capture-similarity analysis and remain pending). Test suite covers all functional paths and pending flags.

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

## Roadmap

The 1.0 surface is locked (see [DESIGN.md](DESIGN.md)). Pending work toward functional 1.0.0:

- `cma distill --retire` and `--review` modes
- `cma stats --leaks` and `--recurrence` views

Beyond 1.0: action-time injection (hook integration so captures surface automatically at the moment of operator action), texture preservation on misses, counterfactual capture. See [CHANGELOG.md](CHANGELOG.md) for the full pending list.

## License

Apache 2.0. See [LICENSE](LICENSE).

## Author

L. Lucic. Published under Clarethium.
