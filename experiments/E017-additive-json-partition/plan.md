# E017 plan: Partition from one encode per JSON element

## Question

Can the byte policy preserve the exact persistence-object boundaries and
delivery semantics while avoiding repeated encodes of large candidate arrays?

## Intervention design

E015 binary search reduced encoder calls, but each call may serialize a large
prefix again. The pinned persistence representation is a JSON array followed by
one comma. For elements with independently encoded JSON values, its size is
additive:

```text
object bytes = sum(element JSON bytes) + (element count - 1 commas)
             + 2 array brackets + 1 trailing comma
```

E017 will add `incrementalJSONElementEncoding` as an explicit recorded strategy.
It encodes every element once, builds maximal prefixes by integer addition, and
then full-encodes each accepted chunk or rejection once as a correctness guard.
If the estimate and actual object size disagree, partitioning fails closed
instead of forwarding an unverified object.

The generic API must require an element encoder for this strategy. Historical
runs keep their recorded strategy. Linear and binary behavior must remain
unchanged.

## Pre-runtime hypotheses

- Incremental decisions and exact byte counts will match linear/binary for
  uniform, heterogeneous, boundary-equal, and individually oversized JSON
  elements.
- Deterministic randomized cases will find no estimate/actual mismatch.
- An intentionally non-additive collection encoder will fail closed with a
  typed mismatch instead of producing a partition.
- For a 500-element synthetic persistence-shaped workload, incremental encoding
  will serialize fewer total input bytes than binary search, even if it makes
  more small encoder calls.

These hypotheses were registered before implementation or test execution.

## Deferred Simulator matrix

The runtime matrix is registered now but must not be claimed complete until the
Simulator runner is available again.

| Persistence | Spans | Processor batch | Payload / span | Evidence directory | Span run ID |
|---|---:|---:|---:|---|---|
| default | 100 | 100 | 1,536 | `E017-default-payload-1536-batch100-001` | `00000000-0000-0000-0017-000000000001` |
| instant | 100 | 100 | 1,536 | `E017-instant-payload-1536-batch100-001` | `00000000-0000-0000-0017-000000000002` |
| default | 500 | 256 | 0 | `E017-default-500-batch256-001` | `00000000-0000-0000-0017-000000000003` |
| instant | 500 | 256 | 0 | `E017-instant-500-batch256-001` | `00000000-0000-0000-0017-000000000004` |

Runtime acceptance requires the same sequence partitions as E015 within
run-specific encoded-size drift, every accepted object at or below 262,144
bytes, exact delivery, and a main-queue probe. Duration is measured but not
given a threshold until the pre-runtime cost model is known.

## Scope limit

The additive rule applies to this exact uncompressed JSON-array representation.
It is not valid for formats whose size depends on cross-element compression,
shared dictionaries, framing, or collection-level transformations. The exact
full-encode guard detects disagreement for committed chunks but does not remove
the SDK-version coupling established in E014.
