# E001 HTTP/no-persistence attempt 003

- Outcome: Successful formal run
- Date: 2026-08-01
- App source commit: `568b96a`
- Run ID: `00000000-0000-0000-0001-000000000005`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Collector: `otelcol` 0.157.0 darwin arm64
- Transport: OTLP/HTTP JSON, no compression
- Persistence: disabled
- Planned spans: 100
- Timing: Collector became ready 8 seconds after app launch returned
- Capture after Collector readiness: 30 seconds

## Reconciliation

- Unique generated: 100
- Unique received: 0
- Duplicate receipts: 0
- Missing receipts: 100
- Eventual delivery in the fixed window: 0%
- Additional app-side action after Collector recovery: none

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `d26d5497eedcf0b7af647df3b926919c90ab5ca8b176b8ec75c4299dbdb269b5` |
| `host-timing.tsv` | `4fa9f5f31ed843f16eae5d99ed2d62186b25ae57eaf5216275e4cf383e143603` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `generated.jsonl` | `31b9f646822f96b3d70004842f9bed49c4722351a6508ca75e4eb1d03f0a7a54` |
| `run.json` | `2bb8e81c63540d6be6ec9485fbe04e336b14ddb419f8f4eafa1c1cc9ea69c602` |
| `reconciliation.json` | `77ddb3c3be284bef96e368fbe7acaea830edf1a2b657163f23e7e6c78542688d` |

The generated ledger records experiment `E001`, and the Collector log confirms
that both OTLP receivers remained ready for the complete capture window. The
absence of receipts therefore measures a lack of automatic recovery in this
specific configuration and window, not a Collector startup failure.
