# E009 results: Provider flush silently lost oversized persistence objects

## Result

Scaling from 100 to 500 spans broke the E008 intervention for both official
presets. Provider force-flush reported completion in every accepted run, yet the
500-span conditions created no file and recovered 0/500. The 1,000-span
conditions created one file containing only the final 232 spans and recovered
232/1,000.

| Persistence | Planned | Flush duration | File bytes after stop | Received | Missing | Surviving sequences |
|---|---:|---:|---:|---:|---:|---|
| default | 100 | 111.96 ms | 107,791 | 100 | 0 | 1...100 |
| default | 500 | 167.32 ms | 0 | 0 | 500 | none |
| default | 1,000 | 289.89 ms | 250,297 | 232 | 768 | 769...1,000 |
| instant | 100 | 208.35 ms | 107,785 | 100 | 0 | 1...100 |
| instant | 500 | 196.76 ms | 0 | 0 | 500 | none |
| instant | 1,000 | 220.38 ms | 250,307 | 232 | 768 | 769...1,000 |

Every accepted background event occurred 3.14–6.11 seconds after generated
ledger commit, before the amended 15-second schedule. No first process entered
the HTTP path. Generated, run, and lifecycle evidence remained byte-identical
across each relaunch.

## The registered hypotheses failed usefully

The prediction that all six runs would create a file and recover exactly was
false in four of six conditions. The duration-growth prediction was also not
supported: oversized chunks fail before a successful append, so those timings
do not represent a monotonic write-cost curve.

All provider calls did finish below the registered one-second bound. That fact
is not reassuring by itself. A fast flush that silently discards an oversized
object is worse than a visible timeout because the caller receives no durable
failure signal.

## Count-sized chunks met a byte-sized ceiling

The lab configured `BatchSpanProcessor.maxExportBatchSize=256`. Pinned core
source divides a force-flushed list into chunks of at most 256 spans. Pinned
persistence source then JSON-encodes each entire chunk as one object.

Both official presets cap one object at 256 KiB. When an object exceeds that
limit, `FilesOrchestrator` throws, but `OrchestratedFileWriter` catches the error
without surfacing it. The outer persistence span exporter consequently returns
success and the batch processor does not requeue the chunk.

That composition predicts the observed identities:

- 100 = one 100-span chunk, which fit and recovered.
- 500 = 256 + 244; neither encoded chunk fit, so no file existed.
- 1,000 = 256 + 256 + 256 + 232; the first 768 spans disappeared and the final
  232-span chunk fit in a roughly 250-KB persistence file.

Both 1,000-span runs sent one 64,482-byte OTLP request after resume and delivered
exactly sequences 769...1,000. Both 500-span runs made no HTTP attempt in either
process. Identical boundaries across default and instant show that synchronous
write timing did not remove the shared object-size policy.

The detailed source trace is recorded in
[`docs/source-inspection/e009-object-size-boundary.md`](../../docs/source-inspection/e009-object-size-boundary.md).

## Excluded calibration

The original default 100-span attempt used the preregistered five-second
schedule, but Simulator lifecycle delivery took 6.30 seconds after ledger
commit. Its 2.77-ms flush occurred after the schedule boundary, so it was
preserved and excluded before the window was amended to 15 seconds. The runner
now records and enforces the app-timestamp boundary.

## Evidence locations

- [`excluded default 100 / 5-second window`](../../evidence/raw/E009-default-background-100-001/manifest.md)
- [`default 100`](../../evidence/raw/E009-default-background-100-002/manifest.md)
- [`default 500`](../../evidence/raw/E009-default-background-500-002/manifest.md)
- [`default 1,000`](../../evidence/raw/E009-default-background-1000-002/manifest.md)
- [`instant 100`](../../evidence/raw/E009-instant-background-100-002/manifest.md)
- [`instant 500`](../../evidence/raw/E009-instant-background-500-002/manifest.md)
- [`instant 1,000`](../../evidence/raw/E009-instant-background-1000-002/manifest.md)

## Scoped conclusion

`forceFlush` completion was not evidence that every pending span became durable.
With a count-based batch large enough to cross persistence's encoded-byte limit,
both presets silently lost complete chunks while reporting success. The result
was deterministic total loss at 500 and deterministic suffix-only recovery at
1,000 for this payload and configuration.

The threshold is not universally 244 or 256 spans; attributes change encoded
size. The general hazard is composing an item-count batch limit with an internal
byte limit whose rejection is not returned to the caller. The next intervention
should lower export chunk size and test whether the same 500/1,000 workloads can
move from 0/232 to exact recovery.
