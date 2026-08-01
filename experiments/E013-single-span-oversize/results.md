# E013 results: Batch 1 still silently lost one oversized span

## Result

One span with a 240-KiB string attribute fit and recovered exactly for both
persistence presets. Increasing the same attribute to 256 KiB changed both
presets to zero durable files and 0/1 recovery even with
`maxExportBatchSize=1`. A 300-KiB instant run repeated the loss.

| Persistence | Payload / span | Batch | Flush duration | File bytes | HTTP body | Received |
|---|---:|---:|---:|---:|---:|---:|
| default | 245,760 (240 KiB) | 1 | 113.02 ms | 246,874 | 246,280 | 1/1 |
| default | 262,144 (256 KiB) | 1 | 112.08 ms | 0 | — | 0/1 |
| instant | 245,760 (240 KiB) | 1 | 83.68 ms | 246,876 | 246,280 | 1/1 |
| instant | 262,144 (256 KiB) | 1 | 51.86 ms | 0 | — | 0/1 |
| instant | 307,200 (300 KiB) | 1 | 83.03 ms | 0 | — | 0/1 |

Every background event occurred 1.95–3.83 seconds after ledger commit, before
the 15-second processor schedule. No first process made an HTTP request. The
three loss runs also made no request after relaunch and retained stable empty
receipt evidence.

## The minimum count cannot enforce the byte limit

The 240-KiB payload produced a roughly 246.9-KB persistence file. Its encoded
object included about 1.1 KB beyond the attribute value. At a 256-KiB attribute,
the value alone equals the 262,144-byte object ceiling; span and JSON structure
necessarily push the object beyond it.

Unlike E012's two 50-span objects, this object cannot be split by lowering the
processor batch count. The processor already called the exporter with exactly
one `SpanData`. Therefore every fixed count, including one, admits at least one
payload that violates the persistence byte contract.

The 300-KiB result rules out a behavior unique to equality at 256 KiB. It lies
well inside the oversize region and produced the same completed flush, zero
file, zero HTTP attempt, and zero receipt.

## Presets and flush duration did not surface the error

Default and instant matched at both paired payloads. The successful default
control took 113.02 ms, while its failed comparator took 112.08 ms. Instant
failures took 51.86 and 83.03 ms, overlapping its 83.68-ms success. Return and
latency again failed to distinguish durability.

## Evidence locations

- [`default 240 KiB`](../../evidence/raw/E013-default-payload-245760-batch1-001/manifest.md)
- [`default 256 KiB`](../../evidence/raw/E013-default-payload-262144-batch1-001/manifest.md)
- [`instant 240 KiB`](../../evidence/raw/E013-instant-payload-245760-batch1-001/manifest.md)
- [`instant 256 KiB`](../../evidence/raw/E013-instant-payload-262144-batch1-001/manifest.md)
- [`instant 300 KiB`](../../evidence/raw/E013-instant-payload-307200-batch1-001/manifest.md)

## Scoped conclusion

Count-based tuning has reached its hard limit. Batch 1 can mitigate only
multi-span composition; it cannot make one oversized span durable. A production
intervention needs two distinct behaviors:

1. split multi-span exporter inputs by encoded byte budget; and
2. surface, reject, or deliberately reduce an individually oversized span.

The next experiment should implement that policy outside the pinned SDK and
record an explicit local outcome for the single-span case instead of allowing a
successful-looking flush to erase it silently.
