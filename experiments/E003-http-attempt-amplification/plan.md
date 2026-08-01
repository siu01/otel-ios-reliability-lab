# E003 plan: Observe HTTP retry amplification directly

## Question

Do HTTP request lifecycle events show the official OTLP/HTTP exporter's in-memory
pending spans combining with the persistence worker's retry of the same file?

## Pre-run model

The pinned `OtlpHttpTraceExporter` re-adds a failed outgoing array to its own
`pendingSpans`. The persistence decorator also retains the file after that
failure. The next call can therefore combine the HTTP pending copy with the same
file copy.

For one 100-span file, the model predicts outgoing logical counts of 100, then
200 after one completed failure, then 300 after two completed failures. The
Collector should receive the body from the first successful attempt.

This model was derived after E001 and E002 and before any E003 run.

## Instrumentation boundary

`InstrumentedHTTPClient` wraps the official `BaseHTTPClient` without changing
the request or result. It records a start and completion event with attempt ID,
Unix-nanosecond timestamp, HTTP body bytes, request timeout, and outcome. The run
metadata must say `httpClientMode: instrumentedBase`.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean app install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- Official `instantDataDelivery` persistence preset.
- Explicit provider flush disabled.
- 100 generated spans, OTLP/HTTP JSON, two-second exporter timeout.
- No Collector during the specified initial delay.
- 30-second capture after Collector readiness.
- No app-side action after generation.

## Run registry

Run the eight-second case first to compare against E002, followed by shorter and
longer outages without changing code.

| Collector delay | Evidence directory | Span run ID |
|---:|---|---|
| 8 s | `E003-http-attempts-delay08-001` | `00000000-0000-0000-0003-000000000001` |
| 4 s | `E003-http-attempts-delay04-001` | `00000000-0000-0000-0003-000000000002` |
| 6 s | `E003-http-attempts-delay06-001` | `00000000-0000-0000-0003-000000000003` |
| 10 s | `E003-http-attempts-delay10-001` | `00000000-0000-0000-0003-000000000004` |

## Measurements

- Ordered attempt starts and completions relative to Collector readiness.
- Request body bytes and outcomes by attempt ID.
- Generated, unique received, total received, missing, and duplicate sequences.
- Exact per-sequence multiplicity and Collector batch times.
- Persistence files remaining after the window.

## Stop rule

Preserve but exclude a run if `http-attempts.jsonl` is missing, a started attempt
has no explainable lifecycle state when the app is terminated, metadata differs
from this plan, or the host timing violates the selected delay.
