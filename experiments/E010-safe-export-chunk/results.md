# E010 results: Smaller chunks changed 0/232 into exact recovery

## Result

Changing only `maxExportBatchSize` from 256 to 100 restored complete recovery
for both official persistence presets at 500 and 1,000 spans. All four real
background flushes created one durable file, survived direct `SIGKILL`, and
delivered every sequence exactly once after relaunch.

| Persistence | Planned | Batch size | Flush duration | File bytes | Received | Missing |
|---|---:|---:|---:|---:|---:|---:|
| default | 500 | 100 | 147.76 ms | 539,314 | 500 | 0 |
| default | 1,000 | 100 | 169.19 ms | 1,078,677 | 1,000 | 0 |
| instant | 500 | 100 | 180.00 ms | 539,367 | 500 | 0 |
| instant | 1,000 | 100 | 80.47 ms | 1,078,999 | 1,000 | 0 |

Every background event occurred 2.93–6.50 seconds after generated-ledger commit,
before the registered 15-second schedule. No first process entered the HTTP
path, and evidence remained byte-identical across each resume.

## Direct E009 intervention comparison

E009 used the same payload, lifecycle action, stateless exporter, schedule
window, abrupt stop, and presets. Its only relevant configuration difference
was `maxExportBatchSize=256`.

| Persistence | Planned | E009 batch 256 | E010 batch 100 | Change |
|---|---:|---:|---:|---:|
| default | 500 | 0/500 | 500/500 | +500 |
| default | 1,000 | 232/1,000 | 1,000/1,000 | +768 |
| instant | 500 | 0/500 | 500/500 | +500 |
| instant | 1,000 | 232/1,000 | 1,000/1,000 | +768 |

At batch size 100, the 500-span workload generated five persistence objects and
the 1,000-span workload generated ten. Each object fit beneath the pinned
256-KiB object limit. The orchestrator appended the objects into one file per
run, so smaller export chunks did not require five or ten transport requests.

After resume, each 500-span file produced one 138,591-byte OTLP request; each
1,000-span file produced one 277,091-byte request. Every request succeeded and
the persistence file disappeared after delivery.

## What this confirms

The matched intervention supports the E009 mechanism. If lifecycle timing,
write preset, or Collector behavior were the primary cause, changing a count
limit alone would not be expected to restore the exact missing identities for
all four runs. Keeping encoded objects beneath persistence's byte ceiling
changed the outcomes exactly where the source analysis predicted.

The default preset also completed all queued asynchronous appends before the
host's immediate post-event file check in these runs. This is an empirical
observation, not a general provider-flush durability guarantee; E010 did not add
an exporter barrier or extra wait.

## Evidence locations

- [`default 500`](../../evidence/raw/E010-default-background-500-batch100-001/manifest.md)
- [`default 1,000`](../../evidence/raw/E010-default-background-1000-batch100-001/manifest.md)
- [`instant 500`](../../evidence/raw/E010-instant-background-500-batch100-001/manifest.md)
- [`instant 1,000`](../../evidence/raw/E010-instant-background-1000-batch100-001/manifest.md)

## Scoped conclusion

For this payload, reducing count-based export chunks from 256 to 100 changed
silent total and partial loss into exact background-restart recovery without
modifying the SDK. It is the smallest tested configuration intervention for the
observed 256-KiB object boundary.

The number 100 is not universally safe. A single span or 100 unusually large
spans can still exceed the byte ceiling, and the upstream SDK still hides that
writer error. A production fix needs byte-aware splitting or surfaced failure;
E010 establishes that smaller chunks can avoid this instance of the collision.
