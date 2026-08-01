# E003 instrumented HTTP attempts, 6-second outage, attempt 001

- Outcome: Successful formal run with one-step retry amplification
- Date: 2026-08-01
- App instrumentation commit: `c2aab41`
- Host runner commit: `70dc281`
- Plan commit: `d4e8f27`
- Run ID: `00000000-0000-0000-0003-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Collector delay after app launch returned: 6 seconds
- Capture after Collector readiness: 30 seconds

## HTTP attempt lifecycle

| Attempt | Body bytes | Completion | Interpretation |
|---:|---:|---|---|
| 1 | 27,818 | failure, connection refused (`NSURLErrorDomain -1004`) | 100-span logical body |
| 2 | 55,418 | success | 200-span amplified body |

The failed request completed before Collector readiness. The next request began
about 1.498 seconds after readiness and was exactly 27,600 bytes larger.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 200
- Duplicate receipts: 100
- Missing receipts: 0
- Exact multiplicity: every sequence from 1 through 100 appeared twice
- Collector batches: 64, 64, 64, and 8 spans
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `ef6f9108136ef6f71da51ed6a9366adf34f99ca8beb3ef227d717f68625f4651` |
| `generated.jsonl` | `88b8204672ac7666184634832a9fb76324eea7455e39dcf3969f925a8e94ebbb` |
| `host-timing.tsv` | `4381150ad498d623f0cf0e2b150747ad0d61318fd62ea3b6b990f541737b09b2` |
| `http-attempts.jsonl` | `03142c5db9086858280fb324d4f62724bca956ab16753a99dc7da4e364722e49` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `76d563105574fd6c13c91b1ea253376b2761660cce540df1e00ac6a183664215` |
| `reconciliation.json` | `27bc3dd1ad8d93b7be43bde9612ed57f46e1c35ceeda9374c4a050d10a1628db` |
| `run.json` | `264a11871ffbed52e254df655e84f8aa68f3dcaef069900a88ac36c3f5f14c84` |

Together with the four- and eight-second runs, this intermediate condition
supports a direct relationship between completed failures, next-request body
growth, and received multiplicity.
