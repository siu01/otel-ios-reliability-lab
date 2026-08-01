# E001 HTTP/official-default persistence attempt 001

- Outcome: Successful formal run
- Date: 2026-08-01
- App source commit: `568b96a`
- Run ID: `00000000-0000-0000-0001-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official default (`PersistencePerformancePreset.default`)
- Planned spans: 100
- Timing: Collector became ready 8 seconds after app launch returned
- Capture after Collector readiness: 30 seconds

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Eventual delivery in the fixed window: 100%
- First Collector batch: 64 spans, 3.586 seconds after readiness
- Second Collector batch: 36 spans, 3.789 seconds after readiness
- Additional app-side action after Collector recovery: none
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `bbf3a377790f5a2f2a749526ca5b2b2bb949ba9097a8d9568ae4f43298820340` |
| `host-timing.tsv` | `4f3bcb4bb3706a12f857eaa9d1cf4f1872570b77f17e2eede9993fb03db40eb5` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `5c7bd3e1974565383f8a6545c9ed4207cb4d6463d953510d59e958343cb8e2ee` |
| `generated.jsonl` | `400b58d04c17184301f8bfbf08b86f430efce7944b2ddfe52f5392ce3d6ece31` |
| `run.json` | `2da413f7f0674da19af1ace873ea10202290f287b4b7e9b8fe06888666339826` |
| `reconciliation.json` | `46f24d02b2eaf8eace2e875ea1c9a572c53fd80173796891f6777bd7947e880c` |

The Collector received no spans before it was ready because it did not exist.
After recovery, the official default persistence worker drained the complete
100-span backlog without a user action, a second burst, or duplicate delivery.
