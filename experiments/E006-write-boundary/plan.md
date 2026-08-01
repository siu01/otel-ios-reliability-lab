# E006 plan: Terminate around the persistence write boundary

## Question

After the app has ended and independently recorded 100 spans, how soon does the
telemetry batch become recoverable by a new process, and does the official
default asynchronous write behave differently from the instant synchronous
write?

## Trigger

The Collector remains unavailable. The host polls for a complete 100-record
`generated.jsonl`, which is atomically written after the app finishes the span
emission loop. From its first observation of that ledger, the host waits the
registered offset and requests `simctl terminate`.

The host checks whether any persistence file is visible immediately before the
termination request, snapshots the directory after termination, starts the
Collector, and launches the same run with `--lab-resume`. Resume generates no
new spans. A 30-second window then measures recoverable receipts.

## Source model

`BatchSpanProcessor` first retains ended spans in memory and invokes the
persistence exporter on its worker. The app configures a 0.25-second schedule
delay. The instant preset performs its persistence append synchronously once
the exporter is invoked, while the default preset dispatches the append
asynchronously and returns. The detailed pinned-source analysis is in
[`persistence-write-boundary.md`](../../docs/research/persistence-write-boundary.md).

## Hypotheses

- At the shortest offsets, the independent ledger may contain all 100 records
  while no recoverable telemetry file exists yet.
- Longer offsets will transition from zero recovery to exact 100-span recovery.
- A complete valid persistence file will recover all 100 spans at 1x with the
  stateless exporter; the result should be batch-shaped rather than a gradual
  sequence-by-sequence increase.
- Instant should be no worse than default after the persistence exporter begins,
  but both presets can still lose spans terminated while they remain upstream
  in `BatchSpanProcessor` memory.
- Two zero-offset default repetitions may differ because host polling,
  Simulator command dispatch, and worker scheduling are nondeterministic.

These hypotheses and the full matrix were registered before E006 execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- 100 spans; `BatchSpanProcessor` schedule delay 0.25 seconds.
- Stateless lab OTLP/HTTP exporter beneath official persistence.
- Instrumented `BaseHTTPClient`; explicit provider flush disabled.
- Collector starts only after the first process has terminated.
- 30-second capture after Collector readiness and resume launch.

## Registered matrix

Offsets are additional host waits after first observing the complete generated
ledger, not exact process-stop times.

| Persistence | Offset | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 0 ms | `E006-default-ledger000-001` | `00000000-0000-0000-0006-000000000001` |
| default | 0 ms | `E006-default-ledger000-002` | `00000000-0000-0000-0006-000000000002` |
| default | 50 ms | `E006-default-ledger050-001` | `00000000-0000-0000-0006-000000000003` |
| default | 150 ms | `E006-default-ledger150-001` | `00000000-0000-0000-0006-000000000004` |
| default | 300 ms | `E006-default-ledger300-001` | `00000000-0000-0000-0006-000000000005` |
| instant | 0 ms | `E006-instant-ledger000-001` | `00000000-0000-0000-0006-000000000006` |
| instant | 300 ms | `E006-instant-ledger300-001` | `00000000-0000-0000-0006-000000000007` |

## Boundary classification

Each run is assigned one of these host-observable states:

1. **already visible**: a file existed at the pre-request check.
2. **appeared during termination**: none existed at the check but a file existed
   after `simctl terminate` returned.
3. **not persisted**: no file existed after termination.

This classification avoids pretending that a host offset pinpoints the exact
SDK instruction where the process stopped.

## Acceptance and stop rules

Preserve every registered run, including zero-receipt outcomes. Exclude a run
from comparison if the generated ledger was not observed within 20 seconds or
did not contain exactly 100 records, the Collector was reachable during the
first process, metadata differs from the registered condition, resume changed
the generated ledger or metadata digest, or an earlier install contaminated the
persistence directory.

An absent HTTP attempt log after a no-file run is expected and is represented
as an empty evidence file. A corrupt or undecodable file must be preserved and
reported rather than silently rerun.

## Protocol amendment after the first registered run

`E006-default-ledger000-001` revealed that `simctl terminate` was too slow for
the intended boundary. No file was visible at the pre-request check, but the
command took about 471 milliseconds to return and a complete file appeared in
that interval. The run recovered 100/100 and is preserved as a controlled-stop
calibration, not included in the sharp-stop comparison.

Before executing any other matrix entry, the stop mechanism was changed to
direct `SIGKILL` of the host-visible Simulator app PID returned by `simctl
launch`. A diagnostic launch confirmed that the returned PID identifies the
app executable and disappears after the signal. A small compiled UTC probe also
replaced Perl startup in the critical path, and two nonessential timestamp
probes were removed.

All remaining registered conditions use direct `SIGKILL`. The following run
replaces the first calibration entry while preserving the originally registered
second zero-offset repetition:

| Persistence | Offset | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 0 ms | `E006-default-ledger000-003` | `00000000-0000-0000-0006-000000000008` |

The signal is intentionally abrupt and differs from user-initiated app
termination. The host still cannot prove the exact SDK instruction at stop
time, so all original boundary-classification limits remain in force.
