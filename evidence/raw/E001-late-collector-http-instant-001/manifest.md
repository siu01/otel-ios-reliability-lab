# E001 HTTP/official-instant persistence attempt 001

- Outcome: Successful formal run with unexpected duplicate delivery
- Date: 2026-08-01
- App source commit: `568b96a`
- Host procedure commit: `d1fe794`
- Run ID: `00000000-0000-0000-0001-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official instant (`PersistencePerformancePreset.instantDataDelivery`)
- Planned spans: 100
- Timing: Collector became ready 8 seconds after app launch returned
- Capture after Collector readiness: 30 seconds

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 200
- Duplicate receipts: 100
- Missing receipts: 0
- Eventual delivery in the fixed window: 100%
- Exact multiplicity: every sequence from 1 through 100 appeared twice
- Collector batches: 64, 64, 64, and 8 spans
- First Collector batch: 1.008 seconds after readiness
- Additional app-side action after Collector recovery: none
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `f1d2012bc5fccf93122186c9403c08ccce2e9f1ca3d75322126e956c644ef699` |
| `host-timing.tsv` | `ce1fbd8747444c3dae29bef8afddccf291ce9ca2960246ba65c915b16981cf16` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `c5eae47c00049e132dd564a4abdd7e5bb636cbd2c8ab7850f350981ddb4fcef6` |
| `generated.jsonl` | `006c88e9361cba95917c1e4f100b3df071d14aeadd32240ec015b7aa6dcdb93a` |
| `run.json` | `07b7460752a67a649225eaa1275afacbb4a44bee54666ba1cb0c62ed57e0db95` |
| `reconciliation.json` | `67f917750c961344130073b42012adc3388f2f8a3eeccfab043e9ed6a27ed50c` |

This is an accepted measurement, but the duplicate behavior is not yet treated
as a general conclusion. A fresh-run replication is required before attributing
it to the instant preset or to an interaction between its worker and force flush.
