# E006 results: Persistence did not protect the upstream batch window

## Result

Abruptly stopping the process shortly after the app had emitted and recorded all
100 logical spans produced complete loss for both persistence presets. Waiting
300 milliseconds produced a complete file and exact recovery for both. No run
partially recovered the batch.

| Persistence | Registered wait | Observed ledger → signal request | File before request | File after stop | Received | Missing |
|---|---:|---:|---|---:|---:|---:|
| default | 0 ms | 55 ms | no | 0 | 0 | 100 |
| default | 0 ms | 14 ms | no | 0 | 0 | 100 |
| default | 50 ms | 73 ms | no | 0 | 0 | 100 |
| default | 150 ms | 181 ms | no | 0 | 0 | 100 |
| default | 300 ms | 331 ms | yes | 1 | 100 | 0 |
| instant | 0 ms | 19 ms | no | 0 | 0 | 100 |
| instant | 300 ms | 328 ms | yes | 1 | 100 | 0 |

All successful recovery runs made one 27,818-byte HTTP request after resume,
received each trace/span identity at exactly 1x, and deleted the persistence
file. All loss runs made zero HTTP requests after resume. The generated ledger
and run metadata digests matched before and after resume in every condition.

## What changed at 300 milliseconds

At effective host-observed intervals of 181 milliseconds or less, no file was
present before or after `SIGKILL`. At 328 and 331 milliseconds, a complete file
was already visible before the signal request. That file was sufficient for the
new process to recover all 100 spans.

This brackets the transition in this Simulator setup but does not establish a
universal 182–327 ms SDK durability guarantee. The host first observes an
independent ledger after it is atomically written, polling and timestamp probes
add latency, and process scheduling varies. The 0.25-second configured
`BatchSpanProcessor` delay is consistent with the observed step but internal
queue state was not directly instrumented.

## Preset comparison

Instant's synchronous write did not help at zero offset. Both presets share the
same upstream `BatchSpanProcessor`; the synchronous/async distinction begins
only after that processor calls the persistence exporter. Therefore
`span.end()` plus a persistence decorator is not equivalent to an immediately
durable span.

At 300 milliseconds, both presets already had a complete file and both recovered
exactly. E006 did not land a stop specifically after default's exporter returned
but before its asynchronous append completed, so it does not quantify that
narrower default-only interval.

## Failed stop mechanism retained as evidence

The first registered default zero-offset run used `simctl terminate`. No file
was visible before its termination request, but the command took about 471
milliseconds to return. A complete file appeared during that interval and later
recovered 100/100.

That run was preserved as a protocol calibration and excluded from the sharp
comparison. The remaining matrix used direct `SIGKILL`, and a compiled UTC probe
reduced timestamp overhead. The reversal from 100/100 under slow controlled
termination to 0/100 under abrupt stop is itself evidence that the stop
mechanism materially changes the conclusion.

## Evidence locations

- [`default 0 ms calibration`](../../evidence/raw/E006-default-ledger000-001/manifest.md)
- [`default 0 ms sharp attempt 002`](../../evidence/raw/E006-default-ledger000-002/manifest.md)
- [`default 0 ms sharp replacement`](../../evidence/raw/E006-default-ledger000-003/manifest.md)
- [`default 50 ms`](../../evidence/raw/E006-default-ledger050-001/manifest.md)
- [`default 150 ms`](../../evidence/raw/E006-default-ledger150-001/manifest.md)
- [`default 300 ms`](../../evidence/raw/E006-default-ledger300-001/manifest.md)
- [`instant 0 ms`](../../evidence/raw/E006-instant-ledger000-001/manifest.md)
- [`instant 300 ms`](../../evidence/raw/E006-instant-ledger300-001/manifest.md)

## Scoped conclusion

Persistence successfully recovered complete files across relaunch in E005 and
the 300-ms E006 controls. It could not recover spans killed before a file
existed, even though the app had completed all 100 `span.end()` calls and its
independent generation ledger. The durability boundary is the persistence file,
not the application API call.

## Follow-up questions

1. Can a lifecycle-aware flush close the vulnerable interval without blocking
   the main thread excessively?
2. How do `SimpleSpanProcessor`, a shorter batch delay, and immediate direct-to-
   persistence handoff compare on loss and runtime cost?
3. Can an injected writer gate isolate the default-only asynchronous append
   interval without relying on host process timing?
