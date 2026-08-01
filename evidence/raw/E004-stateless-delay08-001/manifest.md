# E004 stateless HTTP exporter, 8-second outage, attempt 001

- Outcome: Successful formal intervention; complete delivery without amplification
- Date: 2026-08-01
- Stateless exporter commit: `5fcb537`
- Host runner commit: `b3cdbab`
- Plan commit: `b14e9a4`
- Run ID: `00000000-0000-0000-0004-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 8 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion |
|---:|---:|---|
| 1 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) |
| 2 | 27,818 | success |

The persistence layer retried the file after one completed failure, but the
stateless exporter did not retain a second in-memory copy. The successful body
remained the original one-batch size. It started about 0.388 seconds after
Collector readiness.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Trace/span ID pair multiplicity: 100 pairs at exactly 1x
- Collector batches: 64 and 36 spans
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `3240aa1ac47d0c120d7a4c25cde2a1ac6347ee249b91d3dddc646dd91825a80c` |
| `generated.jsonl` | `3d536118c8e6413668763bbc7cc668bc25c7ae6d7163a0484f12e3bf930a825c` |
| `host-timing.tsv` | `c27017f2504d7f1bee6bfdceff12337b2fa1653b700b08a7461f071efb3e45ac` |
| `http-attempts.jsonl` | `9bd52df07ea906422d3a286b0760683d1427587d5c83a5a5397cf3b4e19761ef` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `4bdd72a7f67557f509717df1a9a2efe1b821bb9039eff7632048c79dc2c153e8` |
| `reconciliation.json` | `64c8ccf7d34e0ca6d4004a4a86cce3e5b306fd36eb9805b9ee702eca4a057780` |
| `run.json` | `c6dd7a70c0c8487bcfc766e2e32bb65f7d4fd8735cc45b494011c4651c44e6e8` |

This run is a mechanism proof: after a real failed request, assigning retention
to persistence alone preserved full eventual delivery and removed the duplicate
copy. Production readiness and protocol parity remain outside this result.
