# E007 results: Waiting for flush completion changed recovery from 0 to 100

## Result

All four lifecycle-style flush conditions had a complete persistence file before
the abrupt stop and recovered 100/100 exactly once after relaunch. The comparable
E006 zero-offset, no-flush runs had no file and recovered 0/100.

| Persistence | Flush mode | App flush duration | File before stop | First-process HTTP | Received | Missing |
|---|---|---:|---|---|---:|---:|
| default | provider explicit | 37.27 ms | yes | none | 100 | 0 |
| instant | provider explicit | 74.04 ms | yes | none | 100 | 0 |
| default | durability barrier | 100.11 ms | yes | 1 failure | 100 | 0 |
| instant | durability barrier | 88.32 ms | yes | 1 failure | 100 | 0 |

Every run had an ordered generated-ledger, flush-start, flush-completed, and
burst-completed lifecycle sequence. The generated, run, and lifecycle evidence
digests matched before and after resume.

## Intervention against E006

E006's sharp zero-offset conditions killed the process after observing the
complete generated ledger but before any file existed:

| Persistence | Flush | Accepted repetitions | File after stop | Recovered |
|---|---|---:|---:|---:|
| default | disabled | 2 | 0 | 0/100 |
| instant | disabled | 1 | 0 | 0/100 |

E007 changed the stop trigger from generated-ledger observation to recorded
flush completion. For both presets, provider force-flush alone drained the
upstream batch queue quickly enough that the host found a complete file. After
`SIGKILL`, a new process delivered that file in one 27,818-byte request.

Within these registered runs, waiting for provider flush completion changed the
abrupt-restart result from total loss to exact recovery.

## What the durability barrier added

The extra top-level exporter flush did not improve receipt counts: provider-only
already recovered 100/100 for default and instant. It did change behavior while
the Collector was down.

For both barrier runs, the persistence worker immediately attempted the stored
file. Attempt 1 failed with connection refused before the flush-completed event;
the file remained. After relaunch, attempt 2 used the identical 27,818-byte body
and succeeded. The stateless exporter prevented amplification.

Measured within-preset duration differences were:

- default: barrier 100.11 ms versus provider-only 37.27 ms (+62.84 ms).
- instant: barrier 88.32 ms versus provider-only 74.04 ms (+14.28 ms).

These are single Simulator runs and include a loopback connection-refused path.
They are mechanism costs, not latency benchmarks.

## Why provider-only success is not a general guarantee

Pinned source shows that `BatchSpanProcessor.forceFlush` waits for its export
operation, while the default persistence export schedules its file append on a
private queue. It does not explicitly call the decorator's own flush. In the
registered run, that async append finished before the host observed completion
and checked the directory. The evidence establishes empirical sufficiency under
this timing, not a formal durability contract for every device and load.

An injected writer gate would be needed to prove whether the exporter-level
barrier is necessary when the default async append is deliberately delayed.

## Evidence locations

- [`default provider explicit`](../../evidence/raw/E007-default-explicit-001/manifest.md)
- [`instant provider explicit`](../../evidence/raw/E007-instant-explicit-001/manifest.md)
- [`default durability barrier`](../../evidence/raw/E007-default-barrier-001/manifest.md)
- [`instant durability barrier`](../../evidence/raw/E007-instant-barrier-001/manifest.md)

## Scoped conclusion

The E006 loss window was not inevitable. A lifecycle-style intervention that
waited for provider force-flush completion moved ended spans from the in-memory
batch window into a file and changed 0/100 recovery to 100/100 for both presets.
The stronger durability barrier also worked, but in this matrix it added a
failed network attempt and more measured blocking without increasing recovery.

This is not yet an iOS lifecycle integration. The app invoked flush after its
synthetic burst, and the host waited for a completion marker before killing it.
Real background callbacks, suspension deadlines, main-thread responsiveness,
and jetsam do not provide that same cooperative window.
