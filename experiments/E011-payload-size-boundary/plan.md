# E011 plan: Move the byte boundary with larger span attributes

## Question

Is E010's `maxExportBatchSize=100` still safe when each span carries a larger
string attribute, or can payload growth reproduce silent persistence loss
without changing span count?

## New recorded dimension

Add `payloadAttributeBytes` to immutable run metadata and automation. Historical
evidence decodes as zero. When positive, the app adds one ASCII string attribute
named `lab.payload` with exactly that many characters to every probe span.

E011 keeps one 100-span export object and varies its payload bytes. This isolates
the persistence byte limit from count-based chunk partitioning.

## Hypotheses

Based on E009 file sizes and the pinned 256-KiB object limit:

- 0- and 1,024-byte attributes will fit and recover 100/100.
- 1,536- and 2,048-byte attributes will cross the encoded-object limit, create
  no file, and recover 0/100 even though provider flush completes.
- Default and instant will match at the registered 1,024- and 1,536-byte points
  because both presets share `maxObjectSize`.
- Increasing payload will increase flush duration and persisted bytes only while
  the object still fits; rejected objects may complete faster and must not be
  interpreted as better performance.

These thresholds are payload-specific predictions, not SDK constants. The
matrix and IDs were registered before dimension implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- 100 spans in one `maxExportBatchSize=100` export chunk.
- Official persistence decorator over stateless lab OTLP/HTTP exporter.
- Provider force-flush from actual `scenePhase.background`.
- Processor schedule delay 15,000 ms; background must precede it.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Collector startup and resume use immutable evidence and a 30-second capture.

## Registered matrix

| Persistence | Payload bytes per span | Evidence directory | Span run ID |
|---|---:|---|---|
| instant | 0 | `E011-instant-payload-0-001` | `00000000-0000-0000-0011-000000000001` |
| instant | 1,024 | `E011-instant-payload-1024-001` | `00000000-0000-0000-0011-000000000002` |
| instant | 1,536 | `E011-instant-payload-1536-001` | `00000000-0000-0000-0011-000000000003` |
| instant | 2,048 | `E011-instant-payload-2048-001` | `00000000-0000-0000-0011-000000000004` |
| default | 1,024 | `E011-default-payload-1024-001` | `00000000-0000-0000-0011-000000000005` |
| default | 1,536 | `E011-default-payload-1536-001` | `00000000-0000-0000-0011-000000000006` |

## Measurements

- Run-recorded payload bytes and maximum export batch size.
- Ledger-to-background interval and provider flush duration.
- File existence, bytes, and SHA-256 after termination.
- HTTP body bytes and result after resume.
- Exact generated, received, duplicate, missing, and unexpected identities.
- Evidence digest stability across relaunch.

## Acceptance and stop rules

Preserve every run. Exclude a condition if metadata differs from registered
payload bytes or batch size, generated count is not 100, background reaches the
15-second boundary, first-process HTTP occurs, lifecycle ordering is invalid,
resume changes evidence, or another run reaches the Collector.

Do not reduce attribute length, batch size, or add a durability barrier after a
loss. Any boundary surprise remains part of E011; a corrective configuration is
a separately registered intervention.

## Scope limit

ASCII length is a controlled proxy for encoded payload growth. Real attributes
may use different keys, UTF-8 widths, counts, events, links, and resource data.
E011 identifies a mechanism boundary for this exact shape, not a universal
maximum attribute length.
