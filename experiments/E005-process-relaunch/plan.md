# E005 plan: Recover persisted spans after process relaunch

## Question

If the app process terminates after spans have reached the official persistence
directory but before delivery, can a new process recover and export those exact
spans without regeneration?

## Isolation strategy

Use the stateless lab OTLP/HTTP exporter beneath the official persistence
decorator. E004 established that this leaves retry ownership in the persistence
layer and avoids the duplicate amplification measured with the official
stateful exporter. E005 can therefore isolate process-lifecycle durability.

The first process generates 100 spans while the Collector is unavailable. The
host waits until a persistence file is observable, records its size and digest,
and terminates the process before starting the Collector. A second process is
then launched with `--lab-resume` for the same run ID. Resume configures the
exporter against the existing persistence directory but does not generate new
spans or rewrite `run.json`.

## Hypotheses

- Both official persistence presets will retain 100 spans across controlled
  process termination and deliver all 100 after relaunch.
- Reconciliation will report 100 unique spans, zero duplicates, and zero
  missing spans because the stateless exporter has no second retry buffer.
- A persistence file will exist immediately before termination and no
  persistence file will remain after successful delivery.
- The generated ledger will contain exactly 100 records and will not change
  across the resume launch.

These hypotheses were registered before running E005.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- Stateless lab OTLP/HTTP exporter with instrumented `BaseHTTPClient`.
- Explicit provider flush disabled.
- 100 spans and OTLP/HTTP protobuf transport.
- Collector unavailable during generation and process termination.
- 30-second capture after Collector readiness and resume launch.

## Compared condition

- `officialInstant`: synchronous persistence writes and instant-delivery retry
  timings.
- `officialDefault`: asynchronous persistence writes and default retry timings.

The host waits for a file instead of using a common termination delay, so both
conditions enter the lifecycle boundary from the same verified persisted state.

## Run registry

| Persistence preset | Evidence directory | Span run ID |
|---|---|---|
| instant | `E005-relaunch-instant-stateless-001` | `00000000-0000-0000-0005-000000000001` |
| default | `E005-relaunch-default-stateless-001` | `00000000-0000-0000-0005-000000000002` |

## Measurements and stop rule

Record host lifecycle timestamps, the persistence file inventory immediately
before termination and after capture, the generated ledger digest before and
after resume, HTTP attempt outcomes across both processes, Collector output,
and exact sequence plus trace/span identity multiplicity.

Exclude but preserve a run if no persistence file appears within 20 seconds,
if the generated ledger changes across resume, if the run metadata does not
record `E005`, `statelessHTTP`, `instrumentedBase`, disabled flush, and the
registered persistence preset, or if evidence from an earlier install is
present.

`simctl terminate` is a controlled process-termination mechanism. Passing E005
would establish recovery across that boundary; it would not establish behavior
under jetsam, crash-time partial writes, device reboot, app upgrade, or iOS
background execution limits.
