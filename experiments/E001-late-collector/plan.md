# E001 plan: Collector starts after span generation

## Question

If the app ends 100 spans while the Collector is unavailable, which
configurations deliver them after the Collector starts while the app remains
alive?

## Why this precedes termination testing

Process death combines two failure modes: endpoint outage and loss of in-memory
state. E001 keeps the process alive so retry behavior can be measured separately.

## Hypotheses

- Disabled persistence may retain failed spans in the HTTP exporter's in-memory
  pending list but will not necessarily retry after the endpoint returns without
  another export or flush trigger.
- Both persistence presets will retry eligible files and eventually deliver.
- No condition should produce duplicate sequence IDs in this single-outage run.

These are hypotheses, not conclusions.

## Fixed conditions

- Same device, SDK, Collector, transport, processor, and count as E000.
- OTLP endpoint unavailable when the app starts.
- App completes its burst and explicit flush attempt before Collector startup.
- App remains foregrounded and alive.
- Collector starts 8 seconds after app launch.
- Capture window after Collector readiness: 30 seconds.
- One run each for disabled, official default, and official instant persistence.

## Run IDs

| Condition | Evidence directory | Span run ID |
|---|---|---|
| Disabled | `E001-late-collector-http-none-003` | `00000000-0000-0000-0001-000000000005` |
| Default | `E001-late-collector-http-default-001` | `00000000-0000-0000-0001-000000000002` |
| Instant | `E001-late-collector-http-instant-001` | `00000000-0000-0000-0001-000000000003` |

Attempts `none-001` and `none-002` are preserved but excluded. The first
violated the fixed startup timing; the second recorded the wrong experiment ID.
The accepted disabled run uses a new ID so no invalid evidence is overwritten.

## Measurements

- Unique generated and received sequences.
- Missing and duplicate sequences.
- Time from Collector readiness to first received batch.
- Whether a second app-side action was required.
- Persistence files remaining after the capture window.

## Stop rule

If app-side status shows generation failure or the Collector cannot reach ready
state, preserve the attempt under a new run ID and do not reinterpret it as a
delivery result.

## Post-observation replication

The first instant run delivered every sequence twice. Because this behavior was
not predicted, run a fresh-install replication before treating it as more than
an isolated observation:

| Condition | Evidence directory | Span run ID |
|---|---|---|
| Instant replication | `E001-late-collector-http-instant-002` | `00000000-0000-0000-0001-000000000006` |

This replication was added after inspecting `instant-001`; it is confirmatory,
not part of the original one-run comparison. It must use the unchanged script,
8-second outage, 30-second capture, and 100-span count.
