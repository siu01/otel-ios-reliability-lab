# E018 plan: Hold payload multiset fixed and change only order

## Question

Can two runs containing the same count of the same large and small spans create
different persistence-object counts solely because ordered maximal-prefix
partitioning cannot reorder telemetry?

## Design

Add immutable payload-pattern metadata with two configured payload sizes:

- `constant`: every sequence uses the primary size;
- `alternatingPrimarySecondary`: odd/even sequences alternate;
- `groupedPrimaryFirst`: the first half uses primary, then secondary; and
- `groupedSecondaryFirst`: the first half uses secondary, then primary.

Historical runs decode as constant with secondary size zero. The generated
ledger still identifies every sequence; payload size is a deterministic
function of run metadata and sequence and will be unit tested.

The pre-runtime proof uses 20 synthetic JSON elements: ten with a 143,360-byte
payload and ten with a 102,400-byte payload under a 262,144-byte object budget.
Alternation should pair one primary and one secondary per object. Grouping
should strand primary elements and pack secondary elements separately. No
strategy may reorder elements to improve packing.

## Pre-runtime hypotheses

- All four patterns produce the registered primary/secondary count and preserve
  sequence order.
- Binary and guarded additive strategies produce identical decisions for every
  pattern.
- Alternating order uses 10 accepted objects, while either grouped order uses
  more objects for the same 2,457,600 payload bytes.
- Every accepted object's exact full encoding remains within 262,144 bytes.

These hypotheses were registered before model implementation or cost-probe
execution.

## Deferred Simulator matrix

Runtime conditions will use 20 spans, processor batch 20, primary payload
143,360, secondary payload 102,400, encoded-byte policy, and the additive
strategy. Default and Instant will each run alternating and primary-first
ordering, with the main-queue probe enabled.

| Persistence | Pattern | Evidence directory | Span run ID |
|---|---|---|---|
| default | alternating | `E018-default-alternating-001` | `00000000-0000-0000-0018-000000000001` |
| default | primary first | `E018-default-primary-first-001` | `00000000-0000-0000-0018-000000000002` |
| instant | alternating | `E018-instant-alternating-001` | `00000000-0000-0000-0018-000000000003` |
| instant | primary first | `E018-instant-primary-first-001` | `00000000-0000-0000-0018-000000000004` |

Runtime acceptance requires deterministic per-sequence payload identity, exact
policy coverage, no accepted object over budget, and 20/20 unique recovery.
Object count is the tested outcome; queue delay is descriptive.

## Scope limit

This is ordered next-fit partitioning inside each processor batch, not a general
bin-packing optimizer. Reordering spans might reduce objects but would change
temporal order and still could not cross `BatchSpanProcessor` export-call
boundaries. Synthetic payload bytes are not yet actual `SpanData` encoded sizes.
