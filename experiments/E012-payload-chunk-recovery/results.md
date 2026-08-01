# E012 results: Halving the export chunk recovered payload-heavy spans

## Result

Lowering `maxExportBatchSize` from 100 to 50 restored exact 100/100 recovery
for every registered 1,536- and 2,048-byte payload condition. E011 had lost the
same total span count and payloads completely with batch 100.

| Persistence | Payload bytes / span | Batch | Flush duration | File bytes | HTTP body | Received | Duplicates |
|---|---:|---:|---:|---:|---:|---:|---:|
| default | 1,536 | 50 | 119.46 ms | 264,897 | 183,618 | 100 | 0 |
| default | 2,048 | 50 | 123.86 ms | 316,057 | 234,818 | 100 | 0 |
| instant | 1,536 | 50 | 82.22 ms | 264,891 | 183,618 | 100 | 0 |
| instant | 2,048 | 50 | 215.90 ms | 316,107 | 234,818 | 100 | 0 |

All background events occurred 3.24–6.12 seconds after generated-ledger commit,
well before the 15-second processor schedule. No first-process HTTP request was
observed. Each resume made one successful request and delivered every expected
span exactly once.

## The matched intervention isolated export-object size

The E011/E012 pair kept total spans, payload bytes per span, persistence preset,
lifecycle trigger, unavailable collector, abrupt stop, and resume procedure
fixed. The deliberate change was the export chunk count:

| Payload | Batch 100 | Batch 50 |
|---:|---:|---:|
| 1,536 bytes | 0/100 | 100/100 |
| 2,048 bytes | 0/100 | 100/100 |

This is consistent with two smaller encoded persistence objects replacing one
oversized object. It is not evidence that 50 is universally safe; the safe
count still depends on the encoded bytes of each span.

## One file larger than 256 KiB was expected

Every run reported one persistence file. The 1,536-byte runs produced roughly
264.9-KB files and the 2,048-byte runs roughly 316.1-KB files, both larger than
the 262,144-byte `maxObjectSize`. That does not contradict the boundary found in
E009/E011: two individually accepted 50-span objects were appended to one file.
The separate file limit is 4 MiB.

The resume path later flattened those two stored objects into one OTLP request.
Request body size depended on payload, not persistence preset: 183,618 bytes at
1,536 and 234,818 bytes at 2,048.

## Flush completion still needs a durability assertion

All four force-flush calls completed, including the slowest at 215.90 ms. E011
showed that failed writes can also complete in about 49 ms, so neither return nor
latency proves durability. The useful assertion is that a persistence object is
visible before process stop and its span identities reconcile after resume.

## Evidence locations

- [`default 1,536 bytes`](../../evidence/raw/E012-default-payload-1536-batch50-001/manifest.md)
- [`default 2,048 bytes`](../../evidence/raw/E012-default-payload-2048-batch50-001/manifest.md)
- [`instant 1,536 bytes`](../../evidence/raw/E012-instant-payload-1536-batch50-001/manifest.md)
- [`instant 2,048 bytes`](../../evidence/raw/E012-instant-payload-2048-batch50-001/manifest.md)

## Scoped conclusion

The intervention made an impossible-looking 0/100 delivery become 100/100 by
changing only object partitioning. This validates the per-object size diagnosis
and provides a practical emergency mitigation for a known payload distribution.

It is not yet a production contract. A single span can still exceed the object
ceiling even at batch 1, and future attributes can invalidate a count chosen
today. The next experiment should test that irreducible single-span case before
implementing a byte-aware exporter policy that surfaces or handles oversize
content explicitly.
