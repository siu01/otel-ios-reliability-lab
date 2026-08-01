# E001 HTTP/no-persistence attempt 002

- Outcome: Mechanically complete, invalidated for metadata error
- Intended experiment: `E001`
- Recorded experiment attribute: `E000`
- Span run ID: `00000000-0000-0000-0001-000000000004`
- Generated/received: 100/0
- Timing: Collector became ready 8 seconds after app launch returned; capture
  remained open for 30 seconds.

The run would indicate no automatic recovery for the non-persistent exporter, but
the app hard-coded `E000`. The result is therefore not admitted to the E001 result
table. It motivated adding a validated `--lab-experiment-id` launch argument.

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `5e343b7f96572d04c5fdc50d5d380557f5b09a2ed54a1a96a3ddacd44961269f` |
| `host-timing.tsv` | `c914a76ee39e6fbf9dcb2b7a398775eed1481d276d0251dfa5e455bced642054` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `generated.jsonl` | `386863640214f272a5d5793733c4f15268470aa0e28fe6d295b891c8344f6242` |
| `run.json` | `ef9a96acb4eadd15fda354544015f5da76dc4f2cae03adddbea503ffc78b340c` |
| `reconciliation.json` | `4673c596fd4b91fc5498c56bfea3e12affc24a32cbffbb9ac4a6bb2cda365f2f` |

