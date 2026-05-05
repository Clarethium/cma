# cma

Executable compound practice loop. The terminal-side companion to [Lodestone](https://github.com/Clarethium/lodestone).

## What this is

cma is the operator's tool for running the compound practice loop on the local machine. It captures failures, surfaces warnings at the moment of action, tracks decisions, and detects recurrence patterns. It is the executable instantiation of the practice defined in Lodestone.

The methodology lives in Lodestone. cma is what running that methodology looks like in a terminal.

## Status

The cma 1.0 surface is specified in [DESIGN.md](DESIGN.md): seven primitives mapped to the discipline defined in Lodestone. The reference implementation port from the working version is the next phase. Additive features (action-time injection, texture preservation, counterfactual capture, recurrence detection) layer on without changing the locked surface; the design document specifies what is in v1 and what is out of scope.

## The Clarethium body

cma sits alongside three reference artifacts published by Clarethium:

- **Touchstone** validates work against quality standards.
- **Whetstone** sharpens craft.
- **Lodestone** orients practice.

cma is the executable companion to Lodestone. The doctrine is in Lodestone; the running code is here.

## License

MIT. See [LICENSE](LICENSE).

## Author

L. Lucic. Published under Clarethium.
