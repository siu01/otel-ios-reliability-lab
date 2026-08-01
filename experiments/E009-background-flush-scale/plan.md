# E009 plan: Scale the real-background flush from 100 to 1,000 spans

## Question

Does the E008 `scenePhase.background` intervention still cross the observed
durability boundary as a pending batch grows from 100 to 500 and 1,000 spans,
and what flush time, persistence size, and restart delivery cost does it add for
the default and instant presets?

## Why this follows E008

E008 changed recovery from 0/100 to 100/100 by calling provider force-flush in
an actual SwiftUI background handler. That mechanism is only operationally
interesting if it is not a 100-span timing accident. E009 varies one dimension,
planned span count, while preserving E008's lifecycle and transport controls.

## Hypotheses

- All six intervention runs will create at least one complete persistence file
  before abrupt stop and recover every planned sequence exactly once.
- Flush duration and persisted bytes will increase with planned span count for
  each preset, although no winner between default and instant is preregistered.
- The 1,000-span provider flushes will complete within 1,000 ms in this
  Simulator. A timeout, suspension, or partial recovery is an accepted outcome,
  not a reason to shrink the workload after execution.
- The successful request body and Collector record count will scale with the
  planned workload, while the stateless exporter keeps one retry owner and
  avoids duplicate logical spans.

These hypotheses and run IDs were registered before runner generalization or
execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- Official persistence decorator over the stateless lab OTLP/HTTP exporter.
- Instrumented `BaseHTTPClient`; provider force-flush only.
- `flushTrigger=background`; processor schedule delay 5,000 ms.
- Mobile Safari launch initiates the real scene transition.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Collector startup and resume launch use the same immutable run evidence.
- 30-second capture after Collector readiness and resume launch.

## Registered matrix

| Persistence | Spans | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 100 | `E009-default-background-100-001` | `00000000-0000-0000-0009-000000000001` |
| default | 500 | `E009-default-background-500-001` | `00000000-0000-0000-0009-000000000002` |
| default | 1,000 | `E009-default-background-1000-001` | `00000000-0000-0000-0009-000000000003` |
| instant | 100 | `E009-instant-background-100-001` | `00000000-0000-0000-0009-000000000004` |
| instant | 500 | `E009-instant-background-500-001` | `00000000-0000-0000-0009-000000000005` |
| instant | 1,000 | `E009-instant-background-1000-001` | `00000000-0000-0000-0009-000000000006` |

## Measurements

- App-recorded ledger-to-background interval and flush duration.
- Host timing from background request through flush observation and stop.
- Persistence file count, bytes, and SHA-256 after termination.
- HTTP attempt count, body bytes, outcome, and timing across resume.
- Exact unique, missing, duplicate, and unexpected sequence counts.
- Evidence digest stability across the process boundary.

Derived comparisons may report milliseconds per 100 spans and persisted bytes
per span, but those ratios remain descriptive because each condition has one
registered run.

## Acceptance and stop rules

Preserve every run directory. Exclude a run from the scale comparison if its
generated ledger does not match the registered count, its metadata does not say
`E009`, the background event occurs after an automatic scheduled export, an HTTP
attempt starts in the first process, Safari fails to produce one background
event, resume mutates evidence, or a different run reaches the Collector.

Wait up to 10 seconds for background observation and 10 seconds for flush
completion. If a registered workload exceeds either bound, preserve and report
the timeout. Do not replace it with a smaller unregistered count.

## Scope limit

E009 measures a cooperative iOS Simulator callback and loopback recovery. It
does not measure main-thread frame stalls, energy, real-device background time,
jetsam, storage pressure, or an operating-system kill during the flush itself.
