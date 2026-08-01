# Research charter

## Working title

**What percentage of spans disappear when an iPhone goes offline or terminates?**

## Primary hypothesis

Persisting ended spans before network export will improve eventual delivery after
temporary failure and relaunch, at the cost of latency, storage, and possible
duplicate delivery.

This is a hypothesis, not a conclusion.

## Primary outcome

`eventual_delivery_rate = unique_received_sequence_ids / generated_sequence_ids`

## Guardrail outcomes

- Duplicate receive rate.
- Time from span end to first successful receipt.
- Storage growth per persisted span.
- Main-thread stalls attributable to instrumentation.
- Application launch and binary-size overhead.

## Initial fault model

- Collector unavailable before generation begins.
- Collector disappears during a burst.
- Collector returns while the app remains alive.
- App backgrounds before the next scheduled export.
- App terminates and later relaunches.
- Export endpoint responds slowly or rejects requests.

## Non-goals for the first milestone

- Claiming exactly-once delivery.
- Comparing commercial observability backends.
- Extrapolating simulator measurements to radio energy usage on physical devices.
- Treating screenshots as measurement data.

## Evidence rule

A result can enter the article only when all of the following exist:

1. A committed experiment plan.
2. A captured environment manifest.
3. Raw generated and received identifiers.
4. A deterministic reconciliation report.
5. A notebook entry covering surprises and limitations.

