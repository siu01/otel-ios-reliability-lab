# E009 pinned-source note: count-sized batches crossed a byte-sized limit

## Pinned revisions

- `opentelemetry-swift` 2.5.0, revision
  `9a6d6a8aed22c415bb1673206e337824635f818b`.
- `opentelemetry-swift-core` 2.5.1, revision
  `06f8a460a66f813758d22f09025d85df45450a63`.
- Lab configuration at E009: `maxExportBatchSize=256`.

This note records the source mechanism inspected after the registered 500-span
run recovered zero. It was not used to predict that outcome in advance.

## Chunking happens by span count

`BatchSpanProcessor.exportAction` in
`Sources/OpenTelemetrySdk/Trace/SpanProcessors/BatchSpanProcessor.swift` strides
the pending list by `maxExportBatchSize`. For the lab value of 256:

- 500 spans become chunks of 256 and 244.
- 1,000 spans become chunks of 256, 256, 256, and 232.

Each chunk is converted to `[SpanData]` and passed independently to the span
exporter. Failed chunks are not put back into the processor queue by this code.

## Persistence limits each encoded chunk by bytes

`PersistenceExporterDecorator.export(values:)` in
`Sources/Exporters/Persistence/PersistenceExporterDecorator.swift` JSON-encodes
the entire `[SpanData]` chunk as one object and appends an array separator.

Both official performance presets use `maxObjectSize = 256 * 1_024` bytes in
`PersistencePerformancePreset.swift`. `instantDataDelivery` inherits the same
limit from `default`; synchronous writing changes queue timing, not object size.

`FilesOrchestrator.getWritableFile(writeSize:)` throws when one encoded object
is larger than `maxObjectSize`. `OrchestratedFileWriter.synchronizedWrite`
catches every error with an empty `catch {}`. Because `write` and `writeSync`
return no status, the outer `PersistenceSpanExporterDecorator.export` returns
`.success` after scheduling or performing that write even when no file was
created.

The combined observable semantics are therefore:

1. The processor removes a count-sized chunk from memory.
2. Persistence tries to encode and append one byte-sized object.
3. An oversized object is rejected inside the writer.
4. The rejection is not surfaced to the processor.
5. Provider force-flush can complete with those spans neither queued nor stored.

## Why the E009 suffix is diagnostic

Both 1,000-span runs recovered exactly sequences 769...1,000. The first three
256-span chunks account for sequences 1...768; the last chunk contains 232.
The surviving persistence files were 250,297 and 250,307 bytes, just below the
262,144-byte object limit, and each decoded into the same contiguous 232-span
suffix after relaunch.

Both 500-span runs produced no file and recovered 0/500. This is consistent with
both their 256- and 244-span encoded objects crossing the same byte limit. The
exact encoded size of a chunk depends on attributes and is not a universal
span-count threshold.

The identical 0/500 and 232/1,000 results for default and instant rule out
synchronous-versus-asynchronous write timing as the primary explanation for
this matrix. The preset-independent object-size policy explains all four scale
failures with the configured 256-span chunking.

## Design implication

`maxExportBatchSize` is an item-count control while `maxObjectSize` is a byte
control. A safe relationship cannot be chosen from span count alone because
encoded span size varies. For this lab payload, lowering the processor batch
size below the observed byte boundary is a testable intervention. Production
code would also need error visibility or byte-aware splitting so oversize loss
cannot masquerade as exporter success.
