# Source note: two retry owners can amplify one persisted span batch

Date: 2026-08-01

## Pinned source inspected

- `opentelemetry-swift` 2.5.0, revision
  `9a6d6a8aed22c415bb1673206e337824635f818b`.
- `opentelemetry-swift-core` 2.5.1, revision
  `06f8a460a66f813758d22f09025d85df45450a63`.
- Upstream: <https://github.com/open-telemetry/opentelemetry-swift>.

The statements below describe the pinned source, not all versions of the SDK.

## Two layers retain the same failed logical batch

`PersistenceExporterDecorator.export` encodes the incoming span array to a
file. `DataExportWorker` reads that file, calls the decorated exporter, and only
deletes the file when the decorated export says it does not need a retry.

The decorated exporter in this lab is `OtlpHttpTraceExporter`. Its `export`
method also owns an in-memory `pendingSpans` array:

1. It appends the newly supplied spans to `pendingSpans`.
2. It moves the entire pending array into the outgoing request and clears it.
3. If the HTTP completion reports failure, it appends the complete outgoing
   array back to `pendingSpans`.

The persistence layer interprets that same failure by retaining the file. On
the next persistence attempt, the same file batch is supplied again while the
HTTP exporter may already hold its prior copy in `pendingSpans`.

## Provisional amplification model

For a single 100-span file:

- First failed HTTP attempt: HTTP pending contains 100; file still contains 100.
- Next attempt: the exporter combines pending 100 plus file 100 and can send 200.
- If that also fails, HTTP pending becomes 200 while the file remains 100.
- The following attempt can send 300.

This model predicts one additional copy for each completed failure before the
first successful persistence attempt. It matches the observations so far:

| Run | Pre-recovery behavior | Exact multiplicity |
|---|---|---:|
| E001 default, explicit flush | Slow preset avoided an eligible retry while down | 1x |
| E001 instant, explicit flush, attempt 001 | Fast retry plus explicit flush | 2x |
| E001 instant, explicit flush, attempt 002 | Fresh-install replication | 2x |
| E002 instant, no explicit flush | Fast scheduled retry only | 3x |

The table is correlation, not yet a direct count of HTTP attempts. In
particular, `OtlpHttpTraceExporter` returns failure if its semaphore wait times
out, while `BaseHTTPClient.send` does not expose a task-cancellation handle. A
request-completion race is therefore an additional mechanism to test.

## Next falsification step

Instrument the HTTP client boundary without changing request behavior. Record
each request start, body size, timeout, completion time, and result. Then vary
the Collector outage duration before accepting the amplification model. The
model is falsified if received multiplicity does not correspond to the request
body sizes accepted by the Collector or if no failed attempt precedes the
amplified success.
