# E003 instrumented HTTP attempts, 4-second outage, attempt 001

- Outcome: Successful formal run with no retry amplification
- Date: 2026-08-01
- App instrumentation commit: `c2aab41`
- Host runner commit: `70dc281`
- Plan commit: `d4e8f27`
- Run ID: `00000000-0000-0000-0003-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 4 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion | Relative timing |
|---:|---:|---|---|
| 1 | 27,818 | success | started about 0.694 seconds after Collector readiness |

No HTTP attempt started while the Collector was unavailable. The first eligible
persistence read occurred after recovery, so neither retry owner accumulated a
failed copy.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Collector batches: 64 and 36 spans
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `0e226e35eb37db636433eea99990a220676e147ab449ca9e9f4d461209acec95` |
| `generated.jsonl` | `c5476b3274aee6191cbca510333b5290cd3bdce0ceaf663232227e6a1773f9e9` |
| `host-timing.tsv` | `5c23538dc05264aa2ae0a44f5035b7c7918bf4a9f5a8961059251d501cf2d9e4` |
| `http-attempts.jsonl` | `ecbb4713cd5105b8bea0ff9a71f908bb0d817c6e6b8c0a680b2a7509f82f9bc9` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `baa352252ce6b9e74dc247092ebc4c152bfe43a1f254db85d7005d8e77df2bbb` |
| `reconciliation.json` | `fe53f57a055f9583dec3fb9b0cdbf5b962e204c58c6ac3c6e6ff0c72c2c1b4f0` |
| `run.json` | `0e52ffddac5d6fddcc7912f5c4128aea8dc86fb3447cc929e1e4c06a1dafd379` |

This shorter outage provides a negative control for the eight-second result:
the same instrumented stack delivered exactly once when no failed attempt
preceded the successful request.
