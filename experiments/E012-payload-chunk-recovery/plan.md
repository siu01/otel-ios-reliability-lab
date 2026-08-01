# E012 plan: Split payload-heavy spans into smaller export objects

## Question

Can lowering `maxExportBatchSize` from 100 to 50 restore exact recovery for the
same 100-span, 1,536- and 2,048-byte payloads that E011 silently lost?

## Intervention

No code or persistence configuration changes are required. E012 changes one
recorded count parameter so the same total workload becomes two encoded
objects. For this payload, each 50-span object is expected to remain below the
256-KiB persistence ceiling.

## Hypotheses

- All four runs will create durable content before abrupt stop and recover
  100/100 exactly once after relaunch.
- The two 50-span objects will be appended into one file and later flattened
  into one OTLP request, as in E010.
- Default and instant may differ in flush duration but will not differ in
  receipt identity.
- Provider force-flush will complete within the existing ten-second bound.

These hypotheses and IDs were registered before execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- 100 spans, `maxExportBatchSize=50`.
- `lab.payload` is 1,536 or 2,048 ASCII bytes on every span.
- Official persistence over the stateless lab OTLP/HTTP exporter.
- Actual `scenePhase.background` provider flush; 15,000-ms schedule.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Same immutable run on resume; 30-second capture.

## Registered matrix

| Persistence | Payload bytes / span | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 1,536 | `E012-default-payload-1536-batch50-001` | `00000000-0000-0000-0012-000000000001` |
| default | 2,048 | `E012-default-payload-2048-batch50-001` | `00000000-0000-0000-0012-000000000002` |
| instant | 1,536 | `E012-instant-payload-1536-batch50-001` | `00000000-0000-0000-0012-000000000003` |
| instant | 2,048 | `E012-instant-payload-2048-batch50-001` | `00000000-0000-0000-0012-000000000004` |

## Measurements and acceptance

Record lifecycle timing, flush duration, file bytes and digest, HTTP body bytes,
reconciliation identities, and evidence stability. Preserve every outcome.

Exclude only for metadata mismatch, wrong ledger count, background at or beyond
15 seconds, first-process HTTP, invalid lifecycle sequence, evidence mutation,
or foreign-run receipts. Do not add a post-flush wait or lower chunks again
inside E012.

## Scope limit

Batch 50 is still a count proxy, not a byte-aware production solution. Success
would validate this controlled intervention and payload range only; a single
larger span can still exceed the SDK's per-object ceiling.
