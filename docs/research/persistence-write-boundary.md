# Persistence write-boundary model for E006

## Pinned source path

The app uses `BatchSpanProcessor` from `opentelemetry-swift-core` 2.5.1 with a
0.25-second schedule delay. Ending a span adds it to the processor's in-memory
queue. A worker later converts queued spans to `SpanData` and calls the exporter
in batches; this means `span.end()` is not itself a durable boundary.

The pinned `opentelemetry-swift` 2.5.0 persistence path then has two write modes:

- `instantDataDelivery` calls `OrchestratedFileWriter.writeSync`. Its private
  serial queue synchronously creates or reuses a file and appends the encoded
  batch, requesting a file synchronization at the end.
- `default` / `lowRuntimeImpact` calls `OrchestratedFileWriter.write`. That
  schedules the same append asynchronously on the private serial queue and
  returns before the queued block is guaranteed to run.

The persistence export method returns success after scheduling that write. The
default path therefore has an explicit interval in which `BatchSpanProcessor`
has handed off the batch but the file append may still exist only as a closure
owned by the current process.

## App-side ordering

The lab currently emits all 100 spans and then atomically writes the independent
`generated.jsonl` ledger. It does not force-flush in E006. Observing the complete
ledger proves that the app's emission loop finished, but it does not prove that
the batch worker exported the spans or that persistence reached a file.

This distinction is useful: E006 triggers termination from the first host
observation of the 100-record ledger, then varies a short additional delay. It
records whether a persistence file existed immediately before the termination
request and what remained after the process actually terminated.

## What the experiment can and cannot locate

The host cannot observe the exact instruction at which `simctl terminate`
stops the process. Command dispatch and Simulator scheduling add uncontrolled
latency. E006 therefore measures an end-to-end vulnerable interval from
completed app emission to an observable file; it cannot assign a failed run
specifically to the batch queue, JSON encoding, async dispatch, file creation,
append, or filesystem synchronization.

Results must be reported as empirical host-trigger offsets, not as nanosecond
guarantees of the SDK implementation. Repetition can expose scheduling
variability but cannot turn this mechanism into a precise crash-injection hook.

## Source locations at the pinned revisions

- `opentelemetry-swift-core/Sources/OpenTelemetrySdk/Trace/SpanProcessors/BatchSpanProcessor.swift`
- `opentelemetry-swift/Sources/Exporters/Persistence/PersistenceExporterDecorator.swift`
- `opentelemetry-swift/Sources/Exporters/Persistence/Storage/FileWriter.swift`
- `opentelemetry-swift/Sources/Exporters/Persistence/Storage/File.swift`
- `opentelemetry-swift/Sources/Exporters/Persistence/PersistencePerformancePreset.swift`
