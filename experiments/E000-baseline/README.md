# E000: Connected HTTP control

## Question

Before introducing outages or lifecycle faults, can each persistence mode deliver
exactly the same 100 generated sequence IDs through OTLP/HTTP to the local
Collector?

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1.
- `opentelemetry-swift` 2.5.0.
- `opentelemetry-swift-core` 2.5.1.
- `otelcol` 0.157.0.
- OTLP/HTTP JSON to `127.0.0.1:4318/v1/traces`.
- `BatchSpanProcessor`: 250 ms schedule delay, 2 s export timeout, queue 4,096,
  maximum batch 256.
- Collector batch: 200 ms timeout, batch size 64.
- 100 one-span traces per run.
- Explicit exporter flush after the generated ledger is written.

## Compared conditions

1. Persistence disabled.
2. Official default/`lowRuntimeImpact` preset.
3. Official `instantDataDelivery` preset.

## Results

| Condition | Generated | Unique received | Duplicates | Missing | Delivery |
|---|---:|---:|---:|---:|---:|
| Disabled | 100 | 100 | 0 | 0 | 100% |
| Default | 100 | 100 | 0 | 0 | 100% |
| Instant | 100 | 100 | 0 | 0 | 100% |

All three runs arrived as two Collector batches of 64 and 36 spans. Sequence
reconciliation—not the batch summaries—establishes the counts above.

## Infrastructure failure retained

Attempt `E000-baseline-http-none-001` failed before the Collector opened its OTLP
ports because the local network permission for its internal metrics listener on
port 8888 had not yet been granted. Attempt `002` used the required host
permission and succeeded. The failed run remains committed.

## Conclusion boundary

The lab pipeline can produce, capture, and reconcile a connected control without
loss or duplication. E000 says nothing about:

- Collector outages.
- App termination before or during export.
- Relaunch recovery.
- Physical-device performance or energy.
- gRPC behavior.

## Next experiment

E001 will start with the Collector unavailable, end 100 spans, then bring the
Collector online without terminating the app. This isolates retry and persistence
behavior from process death.

