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

The current result is a retry-composition warning for the pinned Swift SDK:

- E000: all connected controls delivered 100/100 exactly once.
- E001: an eight-second Collector outage delivered 0/100 without persistence,
  100/100 exactly once with the default preset, and 100/100 twice with the
  instant preset.
- E002: disabling explicit provider flush did not remove instant-preset
  duplication; the Collector received all 100 logical spans three times.
- E003: request instrumentation directly recorded bodies growing from the
  100-span size to 200-span and 300-span sizes after completed failures.

Across the E003 4/6/8/10-second matrix, delivered multiplicity equaled completed
HTTP failures plus one. See
[`experiments/E003-http-attempt-amplification/results.md`](experiments/E003-http-attempt-amplification/results.md)
for the scoped conclusion and limitations.

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
  officialInstant disabled instrumentedBase <collector-delay-seconds>
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
| E004 | Can single-owner retry stop amplification without reintroducing loss? | Next |
| E005 | What survives process termination and relaunch? | Planned |
