# E014 results: Byte-aware policy recovered batches and exposed one-span loss

## Result

The SDK-external policy recovered every registered splittable workload without
changing processor batch count. It also detected both irreducibly oversized
single spans before the official writer and recorded their identities and byte
reason. The prototype's repeated encoding made larger flushes take seconds.

| Persistence | Spans | Processor batch | Payload | Policy outcome | Flush | Received |
|---|---:|---:|---:|---|---:|---:|
| default | 100 | 100 | 1,536 B | 98 + 2 accepted | 2,072.66 ms | 100/100 |
| instant | 100 | 100 | 1,536 B | 98 + 2 accepted | 906.54 ms | 100/100 |
| default | 500 | 256 | 0 B | 243 + 13 + 242 + 2 accepted | 7,035.96 ms | 500/500 |
| instant | 500 | 256 | 0 B | 243 + 13 + 242 + 2 accepted | 4,500.46 ms | 500/500 |
| default | 1 | 1 | 256 KiB | 1 rejected oversize | 14.74 ms | 0/1 |
| instant | 1 | 1 | 256 KiB | 1 rejected oversize | 48.65 ms | 0/1 |

All actual background events preceded the 15-second processor schedule, no
first process reached HTTP, and policy evidence remained byte-identical across
relaunch. Every accepted or rejected generated sequence appeared in policy
evidence exactly once.

## The E011 payload loss became exact recovery

E011's native batch-100, 1,536-byte conditions lost 100/100 for both presets.
E014 kept that total count, processor batch, payload, lifecycle, exporter,
preset, stop, and relaunch procedure fixed. The byte policy measured the actual
storage encoding and divided each input as follows:

| Persistence | First object | Second object |
|---|---:|---:|
| default | 98 spans / 259,557 bytes | 2 spans / 5,299 bytes |
| instant | 98 spans / 259,580 bytes | 2 spans / 5,302 bytes |

All four objects were below the 262,144-byte budget. Each preset produced one
roughly 264.9-KB file, then one 183,618-byte request on resume, and 100/100 with
no duplicates.

This intervention did not rely on choosing 50 in advance. It found 98 as the
largest fitting prefix for each observed 100-span input and retained the two
remaining identities in a second object.

## The E009 batch-256 loss also became exact recovery

E009's native 500-span conditions lost 500/500. The processor's 256- and
244-span calls remained unchanged in E014. The policy converted each call into
two objects, near but not above the byte boundary:

| Persistence | Sequences | Spans | Encoded bytes |
|---|---|---:|---:|
| default | 1...243 | 243 | 262,068 |
| default | 244...256 | 13 | 14,032 |
| default | 257...498 | 242 | 261,075 |
| default | 499...500 | 2 | 2,159 |
| instant | 1...243 | 243 | 262,123 |
| instant | 244...256 | 13 | 14,031 |
| instant | 257...498 | 242 | 261,114 |
| instant | 499...500 | 2 | 2,163 |

Both presets produced one roughly 539-KB persistence file, one 138,591-byte
request after resume, and exact 500/500 delivery. Thus the same processor batch
256 that failed natively became usable when the unit conversion happened before
the writer.

## The single span was not recovered, but it was no longer silent

E013 proved that count tuning cannot split one span. E014 deliberately did not
claim otherwise. The policy encoded the default span as 263,257 bytes and the
instant span as 263,259 bytes, respectively 1,113 and 1,115 bytes over budget.
Each run wrote one `rejectedOversize` event with sequence 1 and its span ID
before returning exporter failure.

No persistence or HTTP file appeared, and both reconciliations remained 0/1.
The improvement is observability: E013 had only the absence of a persistence
file after a successful-looking provider flush; E014 names the rejected record,
measured size, and applicable budget in stable local evidence.

Provider `forceFlush` still has no result value in this pinned core API, so the
application-level flush lifecycle remains `flushCompleted`. A production
integration must promote rejection beyond a lab file—for example a metric,
bounded diagnostic log, callback, or health state visible to the owning team.

## Correctness was expensive in the prototype

The greedy partitioner is logically simple, but the wrapper obtains exact sizes
by JSON-encoding every progressively larger candidate. This repeated work is
quadratic in input count and visible in the measurements:

- 100 payload-heavy spans: 0.91–2.07 seconds;
- 500 ordinary spans: 4.50–7.04 seconds.

E010's fixed batch-100 intervention recovered 500 spans in 148–180 ms. E014 is
more robust to payload shape but currently far slower. It stayed within the
ten-second lab timeout and completed before the registered schedule boundary,
yet it is not suitable for a tight mobile background budget without optimizing
size calculation or partition search.

## Evidence locations

- [`default 100 payload-heavy spans`](../../evidence/raw/E014-default-payload-1536-batch100-001/manifest.md)
- [`instant 100 payload-heavy spans`](../../evidence/raw/E014-instant-payload-1536-batch100-001/manifest.md)
- [`default 500 spans`](../../evidence/raw/E014-default-500-batch256-001/manifest.md)
- [`instant 500 spans`](../../evidence/raw/E014-instant-500-batch256-001/manifest.md)
- [`default single oversize`](../../evidence/raw/E014-default-single-oversize-001/manifest.md)
- [`instant single oversize`](../../evidence/raw/E014-instant-single-oversize-001/manifest.md)

## Scoped conclusion

The policy turned both known multi-span total-loss cases into exact delivery and
made the indivisible case explicit. This demonstrates the required semantic
split: partition what can be partitioned, reject what cannot be represented
within the storage contract, and record both paths.

It does not yet demonstrate an operationally acceptable implementation. The
next intervention should preserve the exact JSON boundary while replacing
prefix-by-prefix encoding with a substantially cheaper search or incremental
accounting strategy, then rerun the matched 100- and 500-span conditions.
