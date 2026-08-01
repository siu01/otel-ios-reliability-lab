# E003 instrumented HTTP attempts, 8-second outage, attempt 001

- Outcome: Successful formal run; retry amplification model directly observed
- Date: 2026-08-01
- App instrumentation commit: `c2aab41`
- Host runner commit: `70dc281`
- Plan commit: `d4e8f27`
- Run ID: `00000000-0000-0000-0003-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official instant (`PersistencePerformancePreset.instantDataDelivery`)
- Explicit flush: disabled
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 8 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion | Interpretation |
|---:|---:|---|---|
| 1 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) | 100-span logical body |
| 2 | 55,418 | failure, connection refused (`NSURLErrorDomain -1004`) | 200-span amplified body |
| 3 | 83,018 | success | 300-span amplified body |

The body grew by exactly 27,600 bytes at each retry. Both failed requests
completed within milliseconds, so this run does not depend on abandoned HTTP
tasks surviving their two-second timeout.

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
| `collector.log` | `d9eeb1961aee6cedcfe4be602d894ef134ffd667c711443fa7090aa1fe4c7522` |
| `generated.jsonl` | `cca644f9e6b90f07620a269c337fc93295eb8c3ac66957e0384bf3144adcd76f` |
| `host-timing.tsv` | `9f94a8042522c682ecd2fc1e8dc8ad601b2ff06181672c3b529e99c5010de0b7` |
| `http-attempts.jsonl` | `6bacdadddb70f16aab448326f4cc02742b22e5935407f269e5aa24043828782a` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `6b97a89239eaa7401a651e715beb11927ecb4dc3fdbf1d70a9628c5e79afa566` |
| `reconciliation.json` | `353a5b3b237dd8f777275e3641d9072a28378c4a9a8d0c9f404712e819e15f6f` |
| `run.json` | `bb0181737b1757ef0292d4c07a9948ec7904e2d6f10398e160ca86bd30e5dd1e` |

This run directly supports the dual-retry amplification mechanism: after each
completed HTTP failure, the next persistence retry contained one more copy of
the original logical batch. Shorter and longer delays remain necessary to test
whether this relationship holds across different failure counts.
