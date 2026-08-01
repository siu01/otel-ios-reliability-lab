# E000 baseline HTTP/no-persistence attempt 002

- Outcome: Successful control run
- Date: 2026-08-01
- App source commit: `10919f9`
- Run ID: `00000000-0000-0000-0000-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: disabled
- Planned spans: 100

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Eventual delivery: 100%
- Collector batches: 64 spans, then 36 spans

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `735694f0c43bf098e1bcfa1a892bd3229c3195c76e299f4f87ac718bb8eb9d46` |
| `received-otlp.jsonl` | `ed9ac872f9240e9cdb53461cbc583d867d8d9e51518c5ae2676a1088249c822c` |
| `generated.jsonl` | `7026f756dbb4942e1de464b831fe9678f1bb4dbcf5e101cd32e76b7a2118bb3e` |
| `run.json` | `f2080c34418694d8a9b18df0e1b19f530370e277c1f4b1d762fd1eeeb16bdadc` |
| `reconciliation.json` | `3cc76304072a2822fe06ef4b1a4a269a12c8fc3c9b90e470c1ac880bcb02794a` |

The successful connected control establishes that the generator, OTLP endpoint,
Collector capture, and reconciliation path can agree on exact sequence identity.
It does not establish outage or lifecycle reliability.

