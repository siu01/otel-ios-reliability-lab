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
- E009: scaling that intervention exposed a silent 256-KiB object boundary;
  both presets recovered 0/500 and only the final 232/1,000 even though provider
  force-flush reported completion.
- E010: reducing only `maxExportBatchSize` from 256 to 100 changed those direct
  comparisons to 500/500 and 1,000/1,000 for both presets with no duplicates.
- E011: with 100 spans and batch 100 fixed, increasing one attribute from 1,024
  to 1,536 bytes changed both presets from 100/100 to silent 0/100 while flush
  still completed in about the same time.
- E012: lowering only that payload-heavy export batch from 100 to 50 restored
  all 1,536- and 2,048-byte conditions to 100/100 with no duplicates.
- E013: a single 240-KiB span recovered 1/1 at batch 1, while 256- and 300-KiB
  spans silently recovered 0/1; count tuning therefore has a hard limit.
- E014: an SDK-external encoded-byte policy recovered the known 100- and
  500-span losses, and replaced single-span silence with an identity-bearing
  local oversize rejection; its linear search took up to 7.04 seconds.
- E015: exact binary search preserved those byte partitions and deliveries while
  cutting matched flush duration by 85–93% to 135–540 ms.

Across the E003 4/6/8/10-second matrix, delivered multiplicity equaled completed
HTTP failures plus one. See
[`experiments/E003-http-attempt-amplification/results.md`](experiments/E003-http-attempt-amplification/results.md)
for the scoped conclusion and limitations.
The distinct persistence boundary is summarized in
[`experiments/E006-write-boundary/results.md`](experiments/E006-write-boundary/results.md).
The real-background intervention is summarized in
[`experiments/E008-background-transition/results.md`](experiments/E008-background-transition/results.md).
The count-versus-byte size failure is summarized in
[`experiments/E009-background-flush-scale/results.md`](experiments/E009-background-flush-scale/results.md).
The configuration intervention is summarized in
[`experiments/E010-safe-export-chunk/results.md`](experiments/E010-safe-export-chunk/results.md).
The payload-size boundary is summarized in
[`experiments/E011-payload-size-boundary/results.md`](experiments/E011-payload-size-boundary/results.md).
Its matched chunk intervention is summarized in
[`experiments/E012-payload-chunk-recovery/results.md`](experiments/E012-payload-chunk-recovery/results.md).
The irreducible single-span case is summarized in
[`experiments/E013-single-span-oversize/results.md`](experiments/E013-single-span-oversize/results.md).
The byte-aware policy is summarized in
[`experiments/E014-byte-aware-policy/results.md`](experiments/E014-byte-aware-policy/results.md),
and its search-cost intervention in
[`experiments/E015-byte-policy-search-cost/results.md`](experiments/E015-byte-policy-search-cost/results.md).

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
  <officialInstant-or-officialDefault> <disabled-or-explicit> \
  [<experiment-id> <span-count> \
  [<schedule-delay-ms> [<max-export-batch-size> [<payload-bytes> \
  [<sdkNative-or-encodedByteBudget> [<object-byte-budget> \
  [<linearPrefixEncoding-or-binarySearchEncoding>]]]]]]]
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
| E009 | Does background flush remain durable from 100 to 1,000 spans? | Complete: both presets fell from 100/100 to 0/500 and 232/1,000 at the 256-KiB object boundary |
| E010 | Can smaller export chunks avoid the silent byte-limit loss? | Complete: batch 100 restored exact 500/500 and 1,000/1,000 recovery for both presets |
| E011 | Does a safe span count remain safe as attribute payload grows? | Complete: at batch 100, 1,024 bytes recovered 100/100 while 1,536 bytes silently lost 100/100 for both presets |
| E012 | Can smaller chunks recover those exact payload-heavy spans? | Complete: batch 50 restored all four 1,536/2,048-byte conditions to 100/100 with no duplicates |
| E013 | Can count tuning save one individually oversized span? | Complete: batch 1 recovered 240 KiB but silently lost 256 and 300 KiB |
| E014 | Can a byte-aware policy recover batches and surface indivisible loss? | Complete: 100/500-span losses recovered exactly; single oversize recorded explicitly; linear search cost up to 7.04 s |
| E015 | Can exact byte partitioning fit a mobile background budget? | Complete: binary search preserved delivery and cut matched flushes by 85–93% to 135–540 ms |
