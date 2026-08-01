# E002 HTTP/official-instant without explicit flush attempt 001

- Outcome: Successful formal run; explicit-flush-only hypothesis rejected
- Date: 2026-08-01
- App source commit: `99fa2f5`
- Host runner commit: `701f4c3`
- Plan commit: `55d43fc`
- Run ID: `00000000-0000-0000-0002-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official instant (`PersistencePerformancePreset.instantDataDelivery`)
- Explicit flush: disabled
- Planned spans: 100
- Timing: Collector startup was requested 8 seconds after app launch returned
- Capture after Collector readiness: 30 seconds

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 300
- Duplicate receipts: 200
- Missing receipts: 0
- Exact multiplicity: every sequence from 1 through 100 appeared three times
- Collector batches: 64, 64, 64, 64, and 44 spans
- First Collector batch: 3.972 seconds after readiness
- Additional app-side action after Collector recovery: none
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `b5c8078ec83c4f828d13ef9a9ae440b9ed27869e43f5ae5edd26f15edab3bea9` |
| `host-timing.tsv` | `4ed1844b10f8c9e3bad6ec9fe8edf46c7457f9ebd2e310fa192462c7e0d7f86b` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `eacb9c66106b35f9898c20c47e0604a44fc6360096d6aaf88212c1d6e8ad9367` |
| `generated.jsonl` | `51312d496d375eb4b360126da8c794c30fc4c773f27719fb6851058979a6d28f` |
| `run.json` | `c1dca3096cd4c5b955f0ff740809e79cfa202f749ed577c41fae349ad52d79d5` |
| `reconciliation.json` | `9dc1e09e618d2fce183cceb762e0f7cd82e561c909b114ec8abba5795d9af095` |

Disabling explicit force flush did not remove duplicate delivery; multiplicity
increased from 2x in both E001 instant runs to 3x here. This rejects the narrow
claim that concurrent explicit flush and the scheduled persistence worker are
required for the behavior. The timing is consistent with multiple earlier HTTP
attempts completing after the Collector becomes reachable, but that mechanism
requires a targeted request-lifecycle experiment.
