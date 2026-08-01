# E017 results: Additive sizing passes core proof; runtime pending

## Status

The pre-runtime hypotheses are complete. The registered iOS Simulator matrix is
not run and no delivery or main-queue improvement is claimed yet. The app and
runner source accept the new strategy, but the application build and runtime
capture remain pending because external Simulator execution approval was
unavailable after E016.

## Correctness result

`incrementalJSONElementEncoding` now:

1. encodes each JSON element independently;
2. adds brackets, inter-element commas, and the persistence trailing comma;
3. creates maximal prefixes under the byte budget; and
4. full-encodes each committed chunk or rejection and compares actual bytes to
   the estimate before returning a decision.

The core suite has 35 tests across 10 suites. New coverage confirms:

- the same maximal-prefix decisions as exact binary search for fixed
  heterogeneous JSON strings;
- the same decisions across 200 deterministic cases containing ASCII, quotes,
  backslashes, newlines, emoji, empty strings, varied budgets, and indivisible
  values;
- a typed `missingEncodedElementByteCount` error when the required encoder is
  omitted;
- a typed `additiveEncodingMismatch` when collection encoding is deliberately
  made non-additive; and
- a typed overflow rather than wrapping an impossible byte sum.

The full-encode guard is important. Without it, the optimization would silently
turn an SDK representation assumption into a durability decision.

## Synthetic cost result

Command:

```sh
scripts/run-partition-cost.sh 500 1024 262144
```

Both strategies produced the exact same accepted partitions:

| Chunk | Sequences | Elements | Encoded object |
|---:|---|---:|---:|
| 1 | 1...248 | 248 | 261,286 bytes |
| 2 | 249...496 | 248 | 261,394 bytes |
| 3 | 497...500 | 4 | 4,218 bytes |

| Strategy | Collection encodes | Element encodes | Encoded output processed |
|---|---:|---:|---:|
| Binary search | 22 | 0 | 3,983,190 bytes |
| Incremental + exact guard | 5 | 500 | 1,055,402 bytes |

The incremental strategy made more calls because it encoded 500 small values,
but processed 73.50% fewer encoded output bytes. This passes the preregistered
cost-shape hypothesis; it is not a wall-clock benchmark and does not predict an
iOS flush duration by itself.

Raw structured output is committed as `cost-500x1024.json` with SHA-256
`4392fbc6326b87fb841ab886d397ab217e6246b40d6bd9019e97ea28cfab8306`.

## Trial record

The first core build failed because adding a third switch case removed Swift's
implicit return behavior from the two existing branches. Explicit `return`
statements fixed the compile error; no test result preceded that repair.

The first cost-probe command called the Command Line Tools `swift` directly.
It failed because that compiler/toolchain and SDK did not match and its default
module cache was sandbox-inaccessible. `scripts/run-partition-cost.sh` now pins
Xcode through `DEVELOPER_DIR` and routes Clang, SwiftPM, and scratch caches to
temporary directories, matching the established core-test harness.

## Remaining acceptance work

- Build the iOS application with the new `SpanData` element encoder.
- Run the four preregistered Simulator conditions with main-queue probes.
- Require exact policy identity coverage and accepted bytes at or below budget.
- Compare partitions, flush duration, queue delay, and delivery with E015/E016.

Until those steps exist as committed evidence, E017 supports only the generic
JSON correctness and encoding-work claims above.
