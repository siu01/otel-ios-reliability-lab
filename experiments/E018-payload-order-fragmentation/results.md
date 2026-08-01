# E018 results: The same payload multiset produced 10 or 15 objects

## Status

The deterministic model and synthetic exact-JSON comparison are complete. The
four preregistered Simulator runs remain pending, so this result does not yet
claim a persistence file count, delivery result, or main-queue duration.

## Pre-runtime result

The three mixed patterns each contained exactly ten 143,360-byte payloads and
ten 102,400-byte payloads: 2,457,600 payload bytes in the same sequence count.
Only order changed.

| Pattern | Payload order | Accepted objects | Encoded bytes across objects |
|---|---|---:|---:|
| Alternating | P,S,P,S,… | 10 | 2,458,191 |
| Primary first | P×10,S×10 | 15 | 2,458,201 |
| Secondary first | S×10,P×10 | 15 | 2,458,201 |

Alternation paired one primary and one secondary element into each object at
about 245,818–245,820 bytes. Primary-first ordering left nine primary elements
alone, paired the boundary primary with one secondary, then paired four
secondary groups and left the final secondary alone. Secondary-first ordering
made five secondary pairs followed by ten individual primary objects.

Thus grouping increased object count by 50% without adding a span or payload
byte. The encoded-byte total differed by only ten bytes, exactly the additional
array framing/trailing commas. This is fragmentation from stable input order,
not more telemetry.

Both exact binary search and guarded additive sizing produced identical chunk
boundaries and byte counts for all four generated patterns. Every accepted
object was below 262,144 bytes.

## Commands

```sh
scripts/run-payload-order-cost.sh 20 143360 102400 262144 \
  alternatingPrimarySecondary
scripts/run-payload-order-cost.sh 20 143360 102400 262144 \
  groupedPrimaryFirst
scripts/run-payload-order-cost.sh 20 143360 102400 262144 \
  groupedSecondaryFirst
scripts/run-payload-order-cost.sh 20 143360 102400 262144 constant
```

The checked summary is `pre-runtime-summary.json`, SHA-256
`0e22f0884725c0e010bd3a88c25e647cd1335f30ffd3d01964b116d61426ab25`.

## Hypothesis audit

| Preregistered statement | Result |
|---|---|
| Mixed patterns preserve ten primary and ten secondary elements | Passed, 3/3 |
| Binary and additive decisions match | Passed, 4/4 generated patterns |
| Alternating uses 10 objects | Passed |
| Either grouped mixed order uses more objects | Passed, both used 15 |
| Every accepted object stays within budget | Passed |
| “All four patterns” have the same primary/secondary count | Invalid as written: constant intentionally uses primary for all 20 |

The last plan sentence conflated the three two-size patterns with the constant
control. It is retained as a preregistration error rather than retroactively
edited into a passing claim. The same-multiset conclusion uses only alternating
and the two grouped patterns.

## Trial record

The first payload-pattern compile repeated an earlier Swift mistake: a switch
following preconditions did not implicitly return its branch values. Adding
explicit returns exposed a second test-only error where a local variable named
`sizes` shadowed the helper method. Renaming it to `observedSizes` fixed the
suite. No cost probe ran before all 39 tests across 11 suites passed.

## Interpretation and runtime gap

The policy is ordered maximal-prefix partitioning, so it cannot move a later
small span backward to fill unused space beside an earlier large span. A true
bin-packing optimizer could reduce objects but would reorder telemetry, require
more state, and still be bounded by each processor export call.

Runtime must now determine whether the actual `SpanData` encoding preserves the
10-versus-15 shape, whether multiple objects append to the same persistence
file, and whether recovery remains exact. Until those runs exist, this is a
representation-level fragmentation proof, not an SDK delivery claim.
