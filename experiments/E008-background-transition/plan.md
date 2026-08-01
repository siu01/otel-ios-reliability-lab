# E008 plan: Flush from an actual iOS background transition

## Question

When an actual SwiftUI scene enters background before the batch processor's
scheduled export, can a provider force-flush triggered by that lifecycle event
move all ended spans into recoverable persistence before suspension or an abrupt
stop?

## New recorded dimensions

Add two run dimensions without changing historical defaults:

- `flushTrigger`: `afterBurst` or `background` (legacy evidence decodes as
  `afterBurst`).
- `processorScheduleDelayMilliseconds`: the configured
  `BatchSpanProcessor` delay (legacy evidence decodes as 250 ms).

E008 uses a 5,000-ms schedule delay so launching another app cannot trivially
wait out the lab's earlier 250-ms interval. This is also the default delay used
by the pinned `BatchSpanProcessor` initializer, although the rest of the lab
configuration remains custom.

## Lifecycle mechanism

After the host observes the complete generated ledger, it launches Mobile
Safari in the same Simulator. SwiftUI should deliver `scenePhase.background` to
the lab app. The controller records `backgroundObserved` in the run lifecycle
JSONL.

- No-flush controls record the background event but do not drain the batch.
  The host sends direct `SIGKILL` after observing that event.
- Provider-flush interventions call `TracerProviderSdk.forceFlush` from the
  background handler. The host waits for the ordered flush-completed event and
  then sends direct `SIGKILL`.

The Collector remains unavailable until the lab app has stopped. The host then
starts it and resumes the same run without generating spans.

## Hypotheses

- With a five-second batch delay, both no-flush controls will have no persistence
  file at the background event and recover 0/100 after abrupt stop.
- Background provider force-flush will create a complete file for both
  persistence presets and recover 100/100 exactly once after resume.
- The background callback and flush-completed lifecycle events will be recorded
  before the app is stopped, demonstrating execution inside the real scene
  transition rather than an after-burst simulation.
- Provider flush will remain below 200 ms for these 100-span Simulator runs,
  but the single-run durations are mechanism observations rather than an iOS
  background-time guarantee.

These hypotheses and the four conditions were registered before E008
implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- 100 spans and 5,000-ms batch schedule delay.
- Official persistence decorator over the stateless lab OTLP/HTTP exporter.
- Instrumented `BaseHTTPClient`; no durability-barrier exporter flush.
- Mobile Safari launch initiates the background transition.
- Collector unavailable until after direct `SIGKILL`.
- 30-second capture after Collector readiness and resume launch.

## Registered matrix

| Persistence | Background action | Evidence directory | Span run ID |
|---|---|---|---|
| default | no flush | `E008-default-background-disabled-001` | `00000000-0000-0000-0008-000000000001` |
| instant | no flush | `E008-instant-background-disabled-001` | `00000000-0000-0000-0008-000000000002` |
| default | provider flush | `E008-default-background-explicit-001` | `00000000-0000-0000-0008-000000000003` |
| instant | provider flush | `E008-instant-background-explicit-001` | `00000000-0000-0000-0008-000000000004` |

## Measurements

- Generated-ledger, background-observed, flush, and burst lifecycle event order.
- Host timing for Safari launch, background event detection, signal, and resume.
- App-recorded flush duration for intervention runs.
- Persistence file inventory after stop and after resume.
- HTTP attempts before and after resume.
- Exact generated/received identities and evidence digest stability.

## Acceptance and stop rules

Preserve all outcomes. Exclude a run if Mobile Safari fails to launch, no
`backgroundObserved` event appears within 10 seconds, the first process remains
foreground, the generated ledger is not exactly 100 records, metadata differs
from the registered trigger/delay/mode, the Collector was reachable before the
stop, or resume mutates run evidence.

If iOS suspends the app before a flush-completed event, preserve that as the
lifecycle result rather than replacing it with a synthetic callback. Simulator
background behavior must not be generalized to real-device jetsam or background
execution budgets.
