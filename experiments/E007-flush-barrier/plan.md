# E007 plan: Close the upstream durability gap with a flush barrier

## Question

Can a lifecycle-style flush move all 100 ended spans through
`BatchSpanProcessor` and into recoverable persistence before an abrupt process
stop, and is provider force-flush alone sufficient for both persistence presets?

## Intervention

Add app-side lifecycle evidence with ordered nanosecond timestamps for generated
ledger commit, flush start, flush completion, and burst completion. Add a new
`durabilityBarrier` flush mode alongside the existing modes:

- `explicit`: call `TracerProviderSdk.forceFlush`, which drains the batch
  processor into the configured exporter.
- `durabilityBarrier`: perform the provider force-flush, then directly flush the
  configured top-level exporter. For the persistence decorator this waits for
  queued file writes and invokes its file export worker.

The Collector remains unavailable during the first process. The host waits for
the flush-completed lifecycle event, checks for a persistence file, and sends
direct `SIGKILL` at zero additional delay. It then starts the Collector and
resumes the same run without generating spans.

This simulates work an application might initiate from a lifecycle callback; it
does not yet use an actual iOS scene/background notification.

## Baseline

E006 already supplies the no-flush boundary control. With the same stateless
exporter, complete generated ledger, direct `SIGKILL`, and no file before the
signal, default zero-offset runs recovered 0/100 twice and instant zero-offset
recovered 0/100 once.

## Hypotheses

- Waiting for either flush mode to complete will close the upstream batch queue
  gap and improve the E006 zero-offset outcome from 0/100 to 100/100.
- Instant plus provider force-flush will have a complete file when flush returns
  because its persistence write is synchronous.
- Default plus provider force-flush may still expose an async writer interval,
  because batch force-flush calls `export` but not the persistence decorator's
  own `flush` method.
- The durability barrier will make a complete file observable for both presets
  before the stop and recover exactly 100 spans at 1x.
- The durability barrier can block longer or cause a failed HTTP attempt while
  the Collector is unavailable; that cost must be measured rather than hidden.

These hypotheses and conditions were registered before implementation or E007
execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- 100 spans and 0.25-second `BatchSpanProcessor` schedule delay.
- Official persistence decorator over the stateless lab OTLP/HTTP exporter.
- Instrumented `BaseHTTPClient`, two-second request timeout.
- Collector unavailable until after direct `SIGKILL`.
- Host sends the signal with zero registered delay after first observing the
  flush-completed lifecycle event.
- 30-second capture after Collector readiness and resume launch.

## Registered matrix

| Persistence | Flush | Evidence directory | Span run ID |
|---|---|---|---|
| default | provider explicit | `E007-default-explicit-001` | `00000000-0000-0000-0007-000000000001` |
| instant | provider explicit | `E007-instant-explicit-001` | `00000000-0000-0000-0007-000000000002` |
| default | durability barrier | `E007-default-barrier-001` | `00000000-0000-0000-0007-000000000003` |
| instant | durability barrier | `E007-instant-barrier-001` | `00000000-0000-0000-0007-000000000004` |

## Measurements

- App lifecycle event order and wall-clock nanoseconds.
- Flush duration measured with a monotonic clock inside the app.
- Host interval from observing flush completion to signal request.
- File visibility immediately before the signal and file inventory after stop.
- HTTP attempt lifecycle before and after resume.
- Generated/received identity reconciliation and before/after evidence hashes.

## Acceptance and stop rules

Preserve every registered outcome. Exclude a run from comparison if the
lifecycle file lacks exactly one ordered flush-start/flush-completed pair, its
generated ledger is not exactly 100 records, the Collector was reachable in the
first process, metadata differs from the registered mode, resume mutates the
ledger or metadata, or earlier persistence files contaminate the clean install.

Provider explicit and durability barrier are distinct interventions even if
both happen to produce the same file state under Simulator timing. Do not infer
that the extra exporter flush is required unless their evidence differs.
