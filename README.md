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

The iOS app, native Collector capture, generated ledger, and reconciliation CLI
are operational. E000 established a connected OTLP/HTTP control: disabled,
default persistence, and instant persistence each delivered 100/100 unique spans
with no duplicates. Outage and lifecycle claims are still untested.

No reliability claim is valid until its experiment has a committed plan, raw
evidence, and reconciliation report.

## Quick start

```shell
scripts/install-collector.sh
scripts/test-core.sh
scripts/build-simulator.sh
scripts/run-collector.sh <run-id>
scripts/reconcile-run.sh evidence/raw/<run-id>
```

`scripts/run-collector.sh` needs permission to bind local OTLP and internal
telemetry ports. Generated Xcode projects and downloaded binaries are ignored;
their sources of truth are `project.yml` and the pinned installer.

## Experiment index

| ID | Question | State |
|---|---|---|
| E000 | Does the connected HTTP control reconcile exactly? | Complete: 3/3 conditions at 100% |
| E001 | What happens when the Collector starts after generation? | Planned |
| E002 | What survives abrupt process termination? | Planned |
| E003 | What is recovered after relaunch? | Planned |
