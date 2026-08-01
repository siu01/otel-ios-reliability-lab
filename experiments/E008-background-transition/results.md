# E008 results: Real background flush changed recovery from 0 to 100

## Result

All four runs entered background through a real SwiftUI `scenePhase` change
before the registered five-second batch schedule. Without a lifecycle flush,
both persistence presets had no file and recovered 0/100. Calling provider
force-flush from the background handler created a complete file and changed
both presets to exact 100/100 recovery after abrupt restart.

| Persistence | Background action | Background after ledger | Flush duration | File before stop | Received | Missing |
|---|---|---:|---:|---:|---:|---:|
| default | no flush | 2.56 s | — | no | 0 | 100 |
| instant | no flush | 1.74 s | — | no | 0 | 100 |
| default | provider flush | 1.87 s | 45.32 ms | yes | 100 | 0 |
| instant | provider flush | 1.87 s | 51.39 ms | yes | 100 | 0 |

Every run recorded `backgroundObserved` after generated-ledger commit and burst
completion. Each intervention additionally recorded ordered flush-start and
flush-completed events before the host sent direct `SIGKILL`. Generated, run,
and lifecycle evidence remained byte-identical across resume.

## The five-second control matters

The app used the pinned `BatchSpanProcessor` default schedule delay of 5,000 ms
instead of the lab's earlier 250-ms delay. App timestamps placed all background
events 1.74–2.56 seconds after generated-ledger commit. Therefore the no-flush
controls reached the actual background callback while the 100 ended spans were
still upstream of both persistence presets.

Neither no-flush run created a persistence file or made an HTTP attempt before
or after relaunch. Both recovered zero spans. Instant's synchronous file writer
did not help because the batch processor had not invoked it.

## What the background intervention changed

The provider-flush runs differed only in their registered background action.
The default run completed flush in 45.323542 ms and had one 107,782-byte file;
the instant run completed in 51.393083 ms and had one 107,797-byte file. The
Collector was still unavailable, and neither first process attempted HTTP.

After direct `SIGKILL`, Collector startup, and app resume, each file produced
one successful 27,818-byte OTLP request. Both runs reconciled all 100 logical
spans exactly once.

Within this matrix, the actual SwiftUI background callback was early enough to
move the batch across the process-restart durability boundary. It changed the
same registered workload from complete loss to complete recovery for both
persistence presets.

## Comparison with E007

E007 triggered flush synthetically after the burst and measured 37.27 ms for
default and 74.04 ms for instant. E008 invoked the same provider operation from
an actual background handler and measured 45.32 ms and 51.39 ms respectively.
All four provider-only interventions recovered 100/100.

These single Simulator observations are mechanism evidence, not latency
benchmarks. The important new fact is that SwiftUI delivered the callback and
the registered intervention completed within it under this controlled load.

## Evidence locations

- [`default no flush`](../../evidence/raw/E008-default-background-disabled-001/manifest.md)
- [`instant no flush`](../../evidence/raw/E008-instant-background-disabled-001/manifest.md)
- [`default provider flush`](../../evidence/raw/E008-default-background-explicit-001/manifest.md)
- [`instant provider flush`](../../evidence/raw/E008-instant-background-explicit-001/manifest.md)

## Scoped conclusion

Persistence alone did not protect ended spans that were still queued in
`BatchSpanProcessor`: both real-background controls lost 100/100. A provider
force-flush launched by `scenePhase.background` crossed the observed durability
boundary in 45–52 ms and changed both abrupt-restart outcomes to 100/100 with no
duplicates.

This does not establish a production guarantee. Simulator background behavior
is not jetsam, callback delivery is cooperative, and only one 100-span run per
condition was measured. Real-device suspension budgets, main-thread impact,
larger batches, repeated transitions, and interrupted flushes remain open.
