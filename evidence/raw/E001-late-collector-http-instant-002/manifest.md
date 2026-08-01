# E001 HTTP/official-instant persistence attempt 002

- Outcome: Successful post-observation replication of duplicate delivery
- Date: 2026-08-01
- App source commit: `568b96a`
- Host procedure commit: `d1fe794`
- Replication registration commit: `df0ca3c`
- Run ID: `00000000-0000-0000-0001-000000000006`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: official instant (`PersistencePerformancePreset.instantDataDelivery`)
- Planned spans: 100
- Timing: Collector startup was requested 8 seconds after app launch returned
- Capture after Collector readiness: 30 seconds

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 200
- Duplicate receipts: 100
- Missing receipts: 0
- Exact multiplicity: every sequence from 1 through 100 appeared twice
- Collector batches: 64, 64, 64, and 8 spans
- First Collector batch: 0.441 seconds after readiness
- Additional app-side action after Collector recovery: none
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `fedd7e95aff7cb0408d53bc6106d53e33c0d40f2a9000655a2b572d363e4f29b` |
| `host-timing.tsv` | `d8f6e169b32352f66ab1755daa9cef16e942a4336a91cebb527784da54ff93ef` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `f4de96bc4ca3f24f9b15aa8f46fd9394ec71b557125f0c0ba1737efdd5f8d4d9` |
| `generated.jsonl` | `dbaa1c86ee7e27cc945cc059547115e85a6b4d061d7991ab4ee84b9a0c2acfb1` |
| `run.json` | `6b5ad29483d13fcc98b08384b272ee1ac206c9dd3821e55f1c9b8efcddd5125f` |
| `reconciliation.json` | `e2b081ecca9d194ea06f8037a2a2df86c5c6ae7452c5c9e1cd1ad8801fbed01f` |

This fresh-install run reproduced the exact 2x multiplicity from attempt 001.
The observation is now 2/2 under the fixed procedure. It still does not isolate
whether the instant preset alone or its interaction with explicit force flush is
the causal factor.
