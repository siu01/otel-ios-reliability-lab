# E015 plan: Replace quadratic prefix encoding with exact binary search

## Question

Can the byte-aware policy preserve E014's exact object boundary and delivery
while materially reducing background flush time?

## Intervention design

E014 encoded every progressively larger prefix, which required one encoder call
per input span and took 4.50–7.04 seconds for 500 spans. E015 will add a recorded
partition strategy and replace that search with a monotonic binary search for
the largest fitting prefix:

1. encode one element to detect an indivisible oversize record;
2. binary-search the remaining prefix length using the same exact persistence
   JSON shape and comma suffix;
3. forward the largest fitting prefix and repeat from the next element; and
4. retain all E014 policy events and byte/identity validation.

Historical and E014 runs decode as `linearPrefixEncoding`. E015 records
`binarySearchEncoding`. Unit tests will require identical decisions and bound
encoder invocations for a 500-element synthetic input before Simulator runs.

## Hypotheses

- Accepted sequence partitions will remain semantically identical to E014:
  approximately 98 + 2 for payload-heavy 100-span inputs and
  243 + 13 + 242 + 2 for 500 ordinary spans, allowing small encoded-size drift
  from run-specific IDs and timestamps.
- All four conditions will recover every span exactly once.
- Each accepted object's measured bytes will remain at or below 262,144.
- 500-span flush duration will improve by at least 50% versus the matched E014
  preset and remain below 2 seconds.
- 100-span flush duration will remain below 500 ms.

These hypotheses and IDs were registered before implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1 remain unmodified.
- Official persistence over the stateless lab OTLP/HTTP exporter.
- Encoded byte budget 262,144; same exact JSON size function as E014.
- Actual `scenePhase.background` provider flush; 15,000-ms schedule.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Same immutable run on resume; 30-second capture.

## Registered matrix

| Persistence | Spans | Processor batch | Payload / span | Evidence directory | Span run ID |
|---|---:|---:|---:|---|---|
| default | 100 | 100 | 1,536 | `E015-default-payload-1536-batch100-001` | `00000000-0000-0000-0015-000000000001` |
| instant | 100 | 100 | 1,536 | `E015-instant-payload-1536-batch100-001` | `00000000-0000-0000-0015-000000000002` |
| default | 500 | 256 | 0 | `E015-default-500-batch256-001` | `00000000-0000-0000-0015-000000000003` |
| instant | 500 | 256 | 0 | `E015-instant-500-batch256-001` | `00000000-0000-0000-0015-000000000004` |

## Measurements and acceptance

Record lifecycle timing, flush duration, persistence files, HTTP attempts,
reconciliation identities, policy decisions, and pre/post-relaunch digests.
Compare each duration only to the same preset/workload in E014. Preserve a run
that misses the registered speed threshold; delivery correctness and cost are
separate outcomes.

Exclude only for metadata mismatch, wrong ledger count, background at or beyond
15 seconds, first-process HTTP, invalid lifecycle sequence, evidence mutation,
foreign-run receipts, missing policy events, or policy identity/byte mismatch.

## Scope limit

Binary search assumes that appending a `SpanData` cannot reduce this JSON
encoding's byte length. That holds for an array with additive elements and
separators, but the assumption must be revisited if the persistence encoding
changes. Exact repeated encoding is still more expensive than incremental size
accounting and remains coupled to the pinned SDK representation.
