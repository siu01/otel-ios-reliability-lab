# OTel iOS Reliability Lab

An evidence-first lab for measuring how reliably an iOS app delivers
OpenTelemetry spans when networks and application lifecycles are hostile.

## Research question

How many spans survive collector outages, temporary network loss, backgrounding,
termination, and relaunch—and what does persistence change?

## Principles

- Every claim links to a reproducible experiment ID.
- Generated and received sequence IDs are reconciled, not estimated.
- Failures, abandoned approaches, and negative results remain in the history.
- Screenshots support raw evidence; they never replace it.
- Dependency versions, device runtime, commands, and timestamps are recorded.

## Planned comparison

1. Standard `BatchSpanProcessor` with OTLP/gRPC.
2. Standard `BatchSpanProcessor` with OTLP/HTTP.
3. The official `PersistenceSpanExporterDecorator` around each transport.
4. Any corrective implementation justified by observed failure modes.

## Repository map

- `App/`: iOS experiment controller and live delivery ledger.
- `Packages/ReliabilityCore/`: deterministic experiment models and reconciliation.
- `collector/`: local OpenTelemetry Collector configuration.
- `experiments/`: immutable plans and summarized results by experiment ID.
- `evidence/`: screenshots and checksummed raw observations.
- `docs/lab-notebook/`: chronological decisions, failures, and discoveries.
- `article/`: article outline and draft backed by experiment IDs.

## Status

The iOS app, native Collector capture, generated ledger, HTTP request lifecycle
instrumentation, and reconciliation CLI are operational.

The current results expose retry-composition and durability-boundary warnings
for the pinned Swift SDK:

- E000: all connected controls delivered 100/100 exactly once.
- E001: an eight-second Collector outage delivered 0/100 without persistence,
  100/100 exactly once with the default preset, and 100/100 twice with the
  instant preset.
- E002: disabling explicit provider flush did not remove instant-preset
  duplication; the Collector received all 100 logical spans three times.
- E003: request instrumentation directly recorded bodies growing from the
  100-span size to 200-span and 300-span sizes after completed failures.
- E004: a stateless exporter beneath official persistence kept every retry at
  the 100-span body size and recovered 100/100 with no duplicates after one and
  two completed failures.
- E005: after a persisted file was observed and the app process terminated,
  both instant and default presets recovered 100/100 exactly once from a new
  process without regenerating spans.
- E006: after all 100 `span.end()` calls and the independent ledger completed,
  abrupt stops at effective host intervals through 181 ms recovered 0/100;
  300-ms conditions had complete files and recovered 100/100 for both presets.
- E007: waiting for provider force-flush completion created a file and changed
  abrupt-relaunch recovery from 0/100 to 100/100 for both presets; an additional
  exporter barrier added a failed request and blocking without more recovery.
- E008: an actual SwiftUI background transition before the five-second batch
  schedule lost 100/100 without flush for both presets; provider force-flush in
  the background handler completed in 45–52 ms and recovered 100/100 exactly.

Across the E003 4/6/8/10-second matrix, delivered multiplicity equaled completed
HTTP failures plus one. See
[`experiments/E003-http-attempt-amplification/results.md`](experiments/E003-http-attempt-amplification/results.md)
for the scoped conclusion and limitations.
The distinct persistence boundary is summarized in
[`experiments/E006-write-boundary/results.md`](experiments/E006-write-boundary/results.md).
The real-background intervention is summarized in
[`experiments/E008-background-transition/results.md`](experiments/E008-background-transition/results.md).

No reliability claim is valid until its experiment has a committed plan, raw
evidence, and reconciliation report.

## Quick start

```shell
scripts/install-collector.sh
scripts/test-core.sh
scripts/build-simulator.sh
scripts/run-collector.sh <run-id>
scripts/reconcile-run.sh evidence/raw/<run-id>
scripts/run-late-collector.sh E003 <evidence-run-id> <span-run-uuid> \
  officialInstant disabled instrumentedBase <collector-delay-seconds> \
  <officialStateful-or-statelessHTTP>
scripts/run-process-relaunch.sh <evidence-run-id> <span-run-uuid> \
  <officialInstant-or-officialDefault>
scripts/run-write-boundary.sh <evidence-run-id> <span-run-uuid> \
  <officialInstant-or-officialDefault> <ledger-offset-ms>
scripts/run-flush-barrier.sh <evidence-run-id> <span-run-uuid> \
  <officialInstant-or-officialDefault> <explicit-or-durabilityBarrier>
scripts/run-background-transition.sh <evidence-run-id> <span-run-uuid> \
  <officialInstant-or-officialDefault> <disabled-or-explicit>
```

`scripts/run-collector.sh` needs permission to bind local OTLP and internal
telemetry ports. Generated Xcode projects and downloaded binaries are ignored;
their sources of truth are `project.yml` and the pinned installer.

## Experiment index

| ID | Question | State |
|---|---|---|
| E000 | Does the connected HTTP control reconcile exactly? | Complete: 3/3 conditions at 100% |
| E001 | What happens when the Collector starts after generation? | Complete: 0%, exact 100%, and duplicated 100% diverged by preset |
| E002 | Is explicit force flush required for instant-preset duplication? | Complete: no; 3x delivery occurred without it |
| E003 | Do HTTP attempts reveal retry amplification? | Complete: 1x/2x/3x matched 0/1/2 completed failures |
| E004 | Can single-owner retry stop amplification without reintroducing loss? | Complete: 100/100 exactly once after one and two failures |
| E005 | What survives process termination and relaunch? | Complete: both presets recovered 100/100 exactly once after controlled termination |
| E006 | What survives termination during the persistence write boundary? | Complete: 0/100 before an observable file, 100/100 after it |
| E007 | Can a lifecycle flush close the upstream durability gap? | Complete: provider flush changed 0/100 to 100/100 for both presets |
| E008 | Does the same intervention fit a real iOS background transition? | Complete: no-flush lost 100/100; background flush recovered 100/100 for both presets |
