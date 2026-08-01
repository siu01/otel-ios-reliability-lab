# E019 results: Upstream calls impose a hard packing boundary

## Outcome

The model confirmed that a byte-aware exporter cannot combine spans across
separate upstream export calls. With the same 500 ordered elements and
512,000 payload bytes, processor batches of 100 and 50 forced five and ten
objects even though every object used far less than the 262,144-byte budget.

One preregistered detail failed: batch 256 produced three synthetic objects,
not four. The second call's 244 elements fit in one 257,178-byte object in this
representation. Actual E015 `SpanData` was slightly larger and split the same
second call into 242 + 2. The mismatch usefully demonstrates why a synthetic
shape cannot stand in for the SDK encoder near a byte boundary.

## Results

| Processor batch | Export calls | Object element counts | Objects | Encoded bytes across objects |
|---:|---:|---|---:|---:|
| 500 | 1 | 248 + 248 + 4 | 3 | 526,898 |
| 256 | 2 | 248 + 8 / 244 | 3 | 526,898 |
| 100 | 5 | 100 × 5 | 5 | 526,902 |
| 50 | 10 | 50 × 10 | 10 | 526,912 |

Slash separates upstream export calls. Binary search and guarded additive
sizing produced identical decisions in every call. Every condition covered all
500 sequences exactly once and every accepted object stayed within budget.

Command template:

```sh
scripts/run-processor-boundary-cost.sh 500 1024 262144 \
  <500-or-256-or-100-or-50>
```

The checked summary is `pre-runtime-summary.json`, SHA-256
`f3d53c4ebdf378b16e69bad925a4b450bdd5f79c55b5c0f1dafd8871059bc598`.

## Hypothesis audit

| Preregistered hypothesis | Result |
|---|---|
| Batch 500 needs three objects | Passed: 248 + 248 + 4 |
| Batch 256 needs four objects | Failed: 248 + 8 / 244 fit in three |
| Batch 100 needs five objects | Passed |
| Batch 50 needs ten objects | Passed |
| Same ordered coverage and payload multiset | Passed |
| No accepted object exceeds budget | Passed |

## Interpretation

There are two independent partitioners in the path:

1. `BatchSpanProcessor` decides which spans appear in one exporter call.
2. The byte policy can only subdivide that call; it cannot borrow capacity from
   an earlier or later call.

This explains why a small fixed processor batch remains a valid emergency
mitigation yet can create many underfilled storage objects. A byte-aware policy
does not undo an upstream count boundary. Conversely, making the processor
batch large gives the byte policy more packing freedom but increases the amount
of queued work and the cost of a synchronous flush.

Object count still is not file or request count. E010 showed five or ten
storage objects appended to one persistence file and later flattened into one
OTLP request. E019 isolates the wrapper boundary only.

## Scope

This exact JSON model is deterministic but synthetic. The failed batch-256
prediction shows it must not be used to choose a production threshold near the
limit. Runtime decisions must measure the actual pinned `SpanData`
representation and revalidate when the SDK changes.
