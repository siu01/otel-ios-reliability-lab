# E004 stateless HTTP exporter, 10-second outage, attempt 001

- Outcome: Successful formal intervention replication
- Date: 2026-08-01
- Stateless exporter commit: `5fcb537`
- Host runner commit: `b3cdbab`
- Plan commit: `b14e9a4`
- Run ID: `00000000-0000-0000-0004-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 10 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion |
|---:|---:|---|
| 1 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) |
| 2 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) |
| 3 | 27,818 | success |

Two completed failures caused two file retries, but all three requests retained
the identical one-batch body size. Attempt 3 began about 2.462 seconds after
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
| `collector.log` | `9f12fd68ece1217628ec1d7ef6868e1769bf26cab7d007d4aebf27755244a78c` |
| `generated.jsonl` | `c2a2c8d4756bc22a309824c9111677b6e6d2de43bbbbc8e8743f779c6fdea3b2` |
| `host-timing.tsv` | `5df7baca18f427201aa8adc988fecb81417f145e49b60b6fa8a320678826b076` |
| `http-attempts.jsonl` | `40532c2365bb1e7b5617ffc703dff996b3ebeb490e307d3a18b40d104abf5eb7` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `acb3fe51e59a241ea8242f1da57cb4b4eafcbe325bf7cfd59ee30aa3dababbdd` |
| `reconciliation.json` | `ccffa7a9c257c94488b5307d45f84312bfaeb559b15236c8aaa9be5fa90c7b14` |
| `run.json` | `7759b13b3631b14d9f912dac600211085fd3191e313c3122a79bb1272d747cc3` |

This second duration confirms the eight-second mechanism proof: with retry state
owned by persistence alone, multiple transport failures no longer accumulate
additional copies in the successful request.
