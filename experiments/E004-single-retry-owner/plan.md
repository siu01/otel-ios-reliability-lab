# E004 plan: Give retry ownership to persistence alone

## Question

Can a stateless OTLP/HTTP exporter beneath the official persistence decorator
preserve complete outage recovery without amplifying duplicate spans?

## Intervention

Replace `OtlpHttpTraceExporter` with a lab exporter that creates the same OTLP
protobuf request from the supplied `SpanData`, delegates transport to the same
HTTP client, and returns success or failure without retaining failed spans.

The official `PersistenceSpanExporterDecorator` remains responsible for file
storage, retry timing, and deletion. This assigns retry state to one layer.

## Hypotheses

- Failed and successful attempts will all retain the one-batch body size rather
  than growing by one copy per failure.
- After Collector recovery, 100 unique spans will arrive exactly once.
- The persistence file will remain after failures and be deleted after success.

These hypotheses were written after E003 and before E004 execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- Official `instantDataDelivery` persistence preset.
- Explicit provider flush disabled.
- Instrumented wrapper over official `BaseHTTPClient`.
- 100 spans, OTLP/HTTP protobuf request, two-second timeout.
- 30-second capture after Collector readiness.

## Changed condition

- `exporterMode`: `statelessHTTP` instead of E003's `officialStateful`.

## Run registry

| Collector delay | Evidence directory | Span run ID |
|---:|---|---|
| 8 s | `E004-stateless-delay08-001` | `00000000-0000-0000-0004-000000000001` |
| 10 s | `E004-stateless-delay10-001` | `00000000-0000-0000-0004-000000000002` |

The eight-second run is the direct intervention against E003's 3x case. The
ten-second run checks that an additional outage interval does not reintroduce
body growth.

## Measurements and stop rule

Record request body bytes and outcomes, exact sequence and trace/span identity
multiplicity, generated and received counts, Collector timing, and post-window
persistence state. Exclude but preserve a run if its metadata does not record
`E004`, `statelessHTTP`, `instrumentedBase`, `officialInstant`, and disabled
flush, or if its attempt log is incomplete.

Passing E004 supports this lab implementation as a mechanism proof. It does not
by itself establish production readiness, full protocol parity, or lifecycle
durability.
