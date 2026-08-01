# E011 results: The safe span count failed when attributes grew

## Result

With span count and `maxExportBatchSize` fixed at 100, increasing one string
attribute from 1,024 to 1,536 bytes changed both persistence presets from exact
100/100 recovery to 0/100. Provider force-flush still reported completion and
finished in roughly the same time.

| Persistence | Payload bytes / span | Flush duration | File bytes | Received | Missing |
|---|---:|---:|---:|---:|---:|
| instant | 0 | 55.78 ms | 107,789 | 100 | 0 |
| instant | 1,024 | 48.17 ms | 213,715 | 100 | 0 |
| instant | 1,536 | 48.88 ms | 0 | 0 | 100 |
| instant | 2,048 | 49.36 ms | 0 | 0 | 100 |
| default | 1,024 | 51.93 ms | 213,688 | 100 | 0 |
| default | 1,536 | 49.04 ms | 0 | 0 | 100 |

All background events occurred 1.84–2.00 seconds after generated-ledger commit,
well before the 15-second schedule. Loss runs made no HTTP attempt in either
process and had no persistence file after stop or resume. Evidence remained
byte-identical across relaunch.

## Same count, different encoded bytes

E010 established that 100 ordinary spans fit. E011 kept that exact count and
changed only `lab.payload` length. The instant zero-payload object occupied
107,789 bytes. Adding 1,024 ASCII bytes to each of 100 spans increased the file
to 213,715 bytes, still below the 262,144-byte ceiling.

The observed increase was 105,926 bytes for 102,400 attribute-value bytes,
including repeated JSON key/type structure. Extending the same shape by another
512 bytes per span would project roughly 264,915 bytes, just beyond the ceiling.
The registered 1,536-byte conditions created no file for either preset, matching
that boundary prediction. This projection is explanatory, not a replacement for
the actual zero-file evidence.

At 2,048 bytes, instant repeated the total-loss outcome. The 1,024 and 1,536
matched points also produced identical receipt boundaries for default and
instant, confirming again that synchronous write mode does not change the shared
object-size policy.

## Flush latency was a false safety signal

Successful flushes measured 48.17–55.78 ms; rejected flushes measured
48.88–49.36 ms. Therefore duration alone could not distinguish durable success
from silent loss. In this matrix, the failed path was neither a timeout nor an
exporter error visible to the caller.

## Evidence locations

- [`instant 0 bytes`](../../evidence/raw/E011-instant-payload-0-001/manifest.md)
- [`instant 1,024 bytes`](../../evidence/raw/E011-instant-payload-1024-001/manifest.md)
- [`instant 1,536 bytes`](../../evidence/raw/E011-instant-payload-1536-001/manifest.md)
- [`instant 2,048 bytes`](../../evidence/raw/E011-instant-payload-2048-001/manifest.md)
- [`default 1,024 bytes`](../../evidence/raw/E011-default-payload-1024-001/manifest.md)
- [`default 1,536 bytes`](../../evidence/raw/E011-default-payload-1536-001/manifest.md)

## Scoped conclusion

`maxExportBatchSize=100` was not universally safe. One payload-shape change
moved the same count from a 213-KB durable object to silent total loss. A count
limit can avoid a known instance of a byte collision, as E010 showed, but it
cannot enforce a byte contract when encoded span size varies.

The next corrective experiment should split the 1,536- and 2,048-byte workloads
into smaller count chunks without changing total spans or attributes. Exact
recovery would provide a second matched intervention while reinforcing that a
production solution must ultimately be byte-aware and surface oversize errors.
