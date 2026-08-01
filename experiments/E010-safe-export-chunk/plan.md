# E010 plan: Lower export chunks beneath the observed byte boundary

## Question

Can changing only `BatchSpanProcessor.maxExportBatchSize` from 256 to 100 turn
E009's silent 0/500 and 232/1,000 outcomes into exact background-restart
recovery for both official persistence presets?

## Intervention

Add `maxExportBatchSize` to immutable run metadata and automation. Historical
runs decode with the lab's previous value of 256. E010 sets it to 100 while
keeping the E009 payload, lifecycle action, schedule window, exporter, and stop
mechanism unchanged.

This is a configuration-level mechanism proof. It does not patch the SDK's
swallowed error or make the chunking byte-aware.

## Hypotheses

- Each 100-span JSON persistence object will remain below the observed 256-KiB
  object limit for the current payload.
- All four runs will have durable persistence content before abrupt stop and
  recover every registered sequence exactly once after relaunch.
- 500 spans will be exported as five objects and 1,000 as ten objects. The
  orchestrator may append them to one file, so file count is not expected to
  equal object count.
- Provider flush duration may increase because it performs more export calls,
  but all four calls will finish inside the existing ten-second runner bound.
- Instant and default may differ in flush duration and file visibility timing;
  no preset winner is preregistered.

These hypotheses and run IDs were registered before metadata implementation or
execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- Planned spans: 500 or 1,000 with the same six lab attributes.
- `maxExportBatchSize=100`, `maxQueueSize=4,096`.
- Official persistence decorator over stateless lab OTLP/HTTP exporter.
- Provider force-flush from actual `scenePhase.background`.
- Processor schedule delay 15,000 ms; event must occur before that boundary.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Collector startup and resume use the same immutable run evidence.
- 30-second capture after Collector readiness and resume launch.

## Registered matrix

| Persistence | Spans | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 500 | `E010-default-background-500-batch100-001` | `00000000-0000-0000-0010-000000000001` |
| default | 1,000 | `E010-default-background-1000-batch100-001` | `00000000-0000-0000-0010-000000000002` |
| instant | 500 | `E010-instant-background-500-batch100-001` | `00000000-0000-0000-0010-000000000003` |
| instant | 1,000 | `E010-instant-background-1000-batch100-001` | `00000000-0000-0000-0010-000000000004` |

## Measurements

- Run-recorded maximum export batch size.
- Ledger-to-background interval and provider flush duration.
- File count, total persisted bytes, and SHA-256 after termination.
- HTTP request count and body bytes after resume.
- Exact generated, received, duplicate, missing, and unexpected identities.
- Evidence digest stability across the process boundary.

## Acceptance and stop rules

Preserve every run. Exclude a condition if metadata does not say `E010` and
batch size 100, ledger count differs, background reaches or exceeds 15 seconds,
the first process starts HTTP, lifecycle events are not unique and ordered,
resume mutates evidence, or a different run reaches the Collector.

Partial or total loss is an accepted result. Do not add an unregistered wait
after provider flush to make an asynchronous write pass. If default provider
flush still returns before all writes are durable, preserve that result for a
separate exporter-barrier experiment rather than changing E010 mid-matrix.

## Scope limit

An exact E010 result would validate 100-span chunks only for this encoded
payload. It would not establish a universal safe item count, surface SDK write
errors, protect a single unusually large span, or prove real-device background
time and energy suitability.
