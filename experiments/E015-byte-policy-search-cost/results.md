# E015 results: Exact binary search cut byte-policy flush time by 85–93%

## Result

Binary search preserved E014's accepted object partitions and exact delivery in
all four conditions. Matched flush durations decreased by 85.1–92.6%, and every
preregistered time threshold passed.

| Persistence | Workload | E014 linear | E015 binary | Reduction | Received |
|---|---|---:|---:|---:|---:|
| default | 100 × 1,536 B | 2,072.66 ms | 158.24 ms | 92.4% | 100/100 |
| instant | 100 × 1,536 B | 906.54 ms | 135.32 ms | 85.1% | 100/100 |
| default | 500 × 0 B | 7,035.96 ms | 520.24 ms | 92.6% | 500/500 |
| instant | 500 × 0 B | 4,500.46 ms | 540.42 ms | 88.0% | 500/500 |

The two 500-span runs remained below the registered two-second bound; the two
100-span runs remained below 500 ms. No first process reached HTTP, every
receipt identity was unique and expected, and policy files remained stable
across relaunch.

## Decisions stayed byte-identical in meaning

Run-specific IDs and timestamps caused small encoded-size differences, but the
maximal fitting prefixes did not change:

- payload-heavy processor call: 98 + 2 spans;
- first 500-span processor call: 243 + 13 spans; and
- second 500-span processor call: 242 + 2 spans.

The largest accepted objects were 259,592–259,614 bytes for the payload-heavy
runs and 262,092–262,101 bytes for the first ordinary prefix. Every object was
at or below 262,144 bytes, and policy sequences covered each generated ledger
exactly once.

Both 100-span runs produced one roughly 264.9-KB file and one 183,618-byte
request. Both 500-span runs produced one roughly 539.4-KB file and one
138,591-byte request. Search strategy changed neither persistence composition
nor the observed transport request count.

## Why the speedup occurred

The linear prototype encoded every progressively larger prefix. The new
strategy first tests one element, then binary-searches the largest fitting end
index under the monotonic JSON-array size assumption. It repeats only after
committing a chunk or rejecting one indivisible element.

A synthetic 500-element unit test requires the binary implementation to make
fewer than 30 encoder calls while producing the same maximal-prefix decisions
as the linear strategy. The Simulator results show that algorithmic change in
the actual background flush path, not only in an isolated microbenchmark.

## Comparison with fixed count

E010's fixed batch-100 solution recovered 500 spans in 147.76–180.00 ms, still
faster than E015's 520–540 ms. The difference buys a stronger invariant: E015
measures the current encoded bytes instead of assuming a safe count for the
current payload shape.

That tradeoff is now quantitative rather than rhetorical. A product can choose
a conservative count with low cost for a constrained schema, or pay additional
encoding cost for a boundary that adapts to heterogeneous span sizes.

## Evidence locations

- [`default 100 payload-heavy spans`](../../evidence/raw/E015-default-payload-1536-batch100-001/manifest.md)
- [`instant 100 payload-heavy spans`](../../evidence/raw/E015-instant-payload-1536-batch100-001/manifest.md)
- [`default 500 spans`](../../evidence/raw/E015-default-500-batch256-001/manifest.md)
- [`instant 500 spans`](../../evidence/raw/E015-instant-500-batch256-001/manifest.md)

## Scoped conclusion

The slow E014 result was an implementation property, not the unavoidable price
of byte-aware partitioning. Exact binary search retained the recovery semantics
and brought 500-span flushes below one second in both single Simulator runs.

This remains coupled to the pinned JSON storage representation and assumes
monotonic encoded size. It also repeats some encodes and has not measured energy,
main-thread responsiveness, or heterogeneous attribute distributions. Those are
separate production-readiness questions, not reasons to discard the verified
correctness and speed intervention.
