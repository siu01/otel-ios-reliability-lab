# E003 instrumented HTTP attempts, 10-second outage, attempt 001

- Outcome: Successful formal run with two-step retry amplification
- Date: 2026-08-01
- App instrumentation commit: `c2aab41`
- Host runner commit: `70dc281`
- Plan commit: `d4e8f27`
- Run ID: `00000000-0000-0000-0003-000000000004`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 10 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion | Interpretation |
|---:|---:|---|---|
| 1 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) | 100-span logical body |
| 2 | 55,418 | failure, connection refused (`NSURLErrorDomain -1004`) | 200-span amplified body |
| 3 | 83,018 | success | 300-span amplified body |

Attempt 3 began about 1.840 seconds after Collector readiness. Backoff limited
the number of completed failures to two, so the ten-second run had the same 3x
multiplicity as the eight-second run rather than growing to 4x.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 300
- Duplicate receipts: 200
- Missing receipts: 0
- Exact multiplicity: every sequence from 1 through 100 appeared three times
- Collector batches: 64, 64, 64, 64, and 44 spans
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `947a89acd8a41fcbb86cb90da89eecff6e34f18559d8ddf88114a1b0dc7b3b26` |
| `generated.jsonl` | `d7c055961f92940f41769ce48ccd357a0c5656ad78f0e98f1a570338c632e78c` |
| `host-timing.tsv` | `f7709b1af35e95a9dd96e7d344edff1b1acd82a49a6cf3a48be84bdacdcb0594` |
| `http-attempts.jsonl` | `aea541d958b55009222e839fd2a4cc831c3c1f61c5b73469b64ca74df4c8d473` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `d01027ba9e0e629cce3ed282081752baf5f64b57d95e621aa63fb41ec44c7ab0` |
| `reconciliation.json` | `e693e22f61306e85a9249556ff626630670680cf00fb8f1523b22031c5fd6917` |
| `run.json` | `9571e16134818a5a508609ad84d807cbd56cc4038a25490261a0ea5fb08aa09f` |

This run supports failure-count, not wall-clock outage duration, as the direct
predictor of delivered multiplicity under the tested dual-retry composition.
