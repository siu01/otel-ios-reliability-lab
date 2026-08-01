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
| Disabled | `E001-late-collector-http-none-001` | `00000000-0000-0000-0001-000000000001` |
| Default | `E001-late-collector-http-default-001` | `00000000-0000-0000-0001-000000000002` |
| Instant | `E001-late-collector-http-instant-001` | `00000000-0000-0000-0001-000000000003` |

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

