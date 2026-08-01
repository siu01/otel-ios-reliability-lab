# E000 connected HTTP/instant-persistence control

- Outcome: Successful control run
- Date: 2026-08-01
- App source commit: `b464229`
- Run ID: `00000000-0000-0000-0000-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official `instantDataDelivery` (synchronous writes)
- Planned/generated/received: 100/100/100
- Duplicate receipts: 0
- Missing receipts: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `36052cebf30b3ed5ebf4dae4c74aa18e5dab2e033520bd2b348449868bb7d38a` |
| `received-otlp.jsonl` | `c2e6bae03be38fc45f2ba5bb3cc3ece92867a4d36beb16cb497500559f7245c6` |
| `generated.jsonl` | `168b8c88108b42fd3a66098f80d432f2970d45016b2de6e1e99375d854925dd7` |
| `run.json` | `1ffe11f67cbc445a6783d93d117b1c08a912624e55f5e81741959195ec3cfd53` |
| `reconciliation.json` | `083787fc293e048a6daf9bd6d6dc9e6adf558bf89f55ad70fa1ae3b50305bb30` |

Connected delivery is complete and duplicate-free. Runtime cost and abrupt
termination survival are not inferred from this control.

