# E000 connected HTTP/default-persistence control

- Outcome: Successful control run
- Date: 2026-08-01
- App source commit: `b464229`
- Run ID: `00000000-0000-0000-0000-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official `default` (`lowRuntimeImpact`, asynchronous writes)
- Planned/generated/received: 100/100/100
- Duplicate receipts: 0
- Missing receipts: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `03bd586cb3f1a7849e5b24214341ab497bf57d25b0882d86f7f9b997ea77a756` |
| `received-otlp.jsonl` | `9d20dc608221e93b8d85ba88e772dd13ce0aca4538213465deae74eff2bab4dd` |
| `generated.jsonl` | `7defcd0b96f96d67d8ce79d175ce40e66ea61babe88d48719e29bd8aafb407ad` |
| `run.json` | `6f234f8c633e4c329c0af9e077f1b0154457980c2c3b218ce459ed0db40e218d` |
| `reconciliation.json` | `c5463f1ddd63cd39db739b9118d5f63578c411737bba283132eb5d19bb42335a` |

Connected delivery is complete and duplicate-free. This is only a control; the
default preset's outage and termination behavior remains untested.

