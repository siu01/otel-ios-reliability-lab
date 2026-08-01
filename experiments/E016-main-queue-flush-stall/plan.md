# E016 plan: Measure the main-queue stall around background flush

## Question

Does the synchronous provider flush used by the real SwiftUI background
callback prevent already-enqueued main-queue work from executing, and for how
long under the fixed-count and byte-aware policies?

## Measurement design

Add a run-level `mainQueueProbeEnabled` dimension. Immediately before
`forceFlush`, the `@MainActor` controller will:

1. append a `mainQueueProbeScheduled` lifecycle event;
2. enqueue one closure with `DispatchQueue.main.async`;
3. synchronously call the existing provider flush; and
4. let the closure append `mainQueueProbeExecuted` with elapsed monotonic time.

The queued closure cannot execute until the current main-queue callback yields.
Its delay therefore measures the user-interface queue stall around the flush,
rather than treating provider duration as an unverified proxy. The host runner
will wait for exactly one scheduled/executed pair before stopping the process,
copy the immutable lifecycle evidence, and validate the pair and delay.

Historical runs decode with the probe disabled. Probe timestamps and delay are
evidence only; they must not alter export partitioning or receipt identity.

## Hypotheses

- Every registered run will record exactly one scheduled and one executed probe.
- Probe delay will be at least the recorded provider flush duration because the
  execution is queued before a synchronous main-actor flush and runs afterward.
- Probe delay minus flush duration will remain below 100 ms.
- Every run will still recover all 500 generated spans exactly once.
- Binary byte-aware partitioning will stall the queue for less than 1 second,
  while the E014 linear cost comparison remains an historical reference rather
  than being rerun as a multi-second UI stall.

These hypotheses and IDs were registered before implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1 remain unmodified.
- Official persistence over the stateless lab OTLP/HTTP exporter.
- 500 ordinary spans, no extra payload, actual `scenePhase.background` callback.
- 15,000-ms processor schedule delay; collector unavailable through probe
  execution; direct `SIGKILL`; same immutable run on resume; 30-second capture.
- Encoded byte budget 262,144 and binary search where byte-aware policy is used.

## Registered matrix

| Persistence | Processor batch | Object policy | Evidence directory | Span run ID |
|---|---:|---|---|---|
| default | 100 | SDK native | `E016-default-native-batch100-001` | `00000000-0000-0000-0016-000000000001` |
| instant | 100 | SDK native | `E016-instant-native-batch100-001` | `00000000-0000-0000-0016-000000000002` |
| default | 256 | binary byte budget | `E016-default-binary-batch256-001` | `00000000-0000-0000-0016-000000000003` |
| instant | 256 | binary byte budget | `E016-instant-binary-batch256-001` | `00000000-0000-0000-0016-000000000004` |

## Measurements and acceptance

Record lifecycle timing, provider flush duration, main-queue probe delay,
persistence files, HTTP attempts, reconciliation identities, policy decisions,
and pre/post-relaunch digests. Preserve results even if a duration hypothesis
fails; responsiveness cost and delivery correctness are separate outcomes.

Exclude only for metadata mismatch, wrong ledger count, background at or beyond
15 seconds, first-process HTTP, invalid lifecycle/probe sequence, negative or
impossible delay, evidence mutation, foreign-run receipts, or policy
identity/byte mismatch.

## Scope limit

This probe measures one already-enqueued main-queue closure on Simulator. It
does not measure frame pacing, touch latency, energy, suspension deadlines, or
real-device scheduling. File appends after `forceFlush` are included in the
probe delay because they occur before the callback yields; the separate flush
duration allows that overhead to be reported rather than hidden.
