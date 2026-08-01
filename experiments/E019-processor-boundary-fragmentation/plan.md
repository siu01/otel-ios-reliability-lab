# E019 plan: Measure the upstream export-call packing limit

## Question

How many additional persistence objects are created when byte-aware
partitioning receives the same ordered telemetry through smaller upstream
`BatchSpanProcessor` export calls?

## Design

Generate 500 identical synthetic JSON elements with a 1,024-byte payload and a
262,144-byte object budget. Preserve order and total data, but divide input into
upstream calls of 500, 256, 100, and 50 elements. Apply guarded additive
partitioning independently to each call, exactly as an exporter wrapper must.

The probe will record call ordinal, input range, output range, exact encoded
bytes, total object count, and encoded framing bytes. It must also compare each
call with exact binary search before accepting a result.

## Hypotheses

- A single 500-element call will need three byte-bounded objects.
- Batch 256 will need four objects because unused capacity at sequence 256
  cannot be filled from the next call; this should reproduce E015's structural
  243 + 13 / 242 + 2 shape within synthetic-size drift.
- Batch 100 will need five objects and batch 50 will need ten, even though each
  object is far below the byte budget.
- All conditions cover sequences 1...500 exactly once and process the same
  payload multiset.
- Smaller upstream calls increase framing/object count but never create an
  oversized accepted object.

These hypotheses were registered before implementing or running the probe.

## Scope limit

This model counts storage objects passed to persistence, not persistence files
or OTLP requests. Prior runtime evidence showed multiple objects can append to
one file and flatten into one request. E019 does not claim those later layers
will have the same count. It also models one export stream without concurrent
processor calls.
