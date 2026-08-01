# E014 plan: Enforce the persistence object budget before the SDK writer

## Question

Can an SDK-external exporter policy recover splittable oversized batches and
turn an irreducibly oversized single span from silent loss into an explicit,
checksummed local rejection?

## Intervention design

Add an opt-in `encodedByteBudget` exporter above the official persistence
decorator:

1. encode candidate `[SpanData]` arrays with the same `JSONEncoder` shape and
   comma suffix used by pinned persistence 2.5.0;
2. greedily partition candidates so each forwarded object is at most 262,144
   bytes;
3. forward accepted chunks to the unchanged official persistence exporter;
4. do not forward a single span whose encoded object exceeds the budget;
5. append accepted/rejected decisions, byte counts, call ordinals, and sequence
   identities to `object-policy-events.jsonl` before returning; and
6. return exporter failure when any single span is rejected or encoding fails.

The policy is opt-in and recorded in immutable run metadata. Historical runs
decode as `sdkNative` with a 262,144-byte reference budget. The partitioner will
be isolated in ReliabilityCore and tested independently before Simulator runs.

## Hypotheses

- The E011 100-span, 1,536-byte loss will recover 100/100 for both presets with
  processor batch 100 because the policy forwards multiple budget-safe objects.
- The E009 500-span, zero-payload loss will recover 500/500 for both presets
  while leaving the processor batch at 256.
- Every accepted policy event will report encoded bytes at or below 262,144,
  and its recorded sequences will cover the generated ledger exactly once.
- A 256-KiB single-span input at batch 1 will remain 0/1, but both presets will
  record one `rejectedOversize` event with encoded bytes above budget and no
  persistence or HTTP attempt. This is accepted only as silence removal, not
  delivery recovery.

These hypotheses and IDs were registered before implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1 remain unmodified.
- Official persistence over the stateless lab OTLP/HTTP exporter.
- Actual `scenePhase.background` provider flush; 15,000-ms schedule.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Same immutable run on resume; 30-second capture.
- Encoded object byte budget: 262,144.

## Registered matrix

| Persistence | Spans | Processor batch | Payload / span | Evidence directory | Span run ID |
|---|---:|---:|---:|---|---|
| default | 100 | 100 | 1,536 | `E014-default-payload-1536-batch100-001` | `00000000-0000-0000-0014-000000000001` |
| instant | 100 | 100 | 1,536 | `E014-instant-payload-1536-batch100-001` | `00000000-0000-0000-0014-000000000002` |
| default | 500 | 256 | 0 | `E014-default-500-batch256-001` | `00000000-0000-0000-0014-000000000003` |
| instant | 500 | 256 | 0 | `E014-instant-500-batch256-001` | `00000000-0000-0000-0014-000000000004` |
| default | 1 | 1 | 262,144 | `E014-default-single-oversize-001` | `00000000-0000-0000-0014-000000000005` |
| instant | 1 | 1 | 262,144 | `E014-instant-single-oversize-001` | `00000000-0000-0000-0014-000000000006` |

## Measurements and acceptance

Record lifecycle timing, flush duration, persistence files, HTTP attempts,
reconciliation identities, object-policy events, and pre/post-relaunch digests.
For accepted chunks, independently require `encodedBytes <= byteBudget`. For a
single rejection, require one generated sequence, one rejected sequence, no
accepted chunk, no persistence file, no HTTP attempt, and 0/1 receipts.

Exclude only for metadata mismatch, wrong ledger count, background at or beyond
15 seconds, first-process HTTP, invalid lifecycle sequence, evidence mutation,
foreign-run receipts, missing policy events, or policy-event identity mismatch.

## Scope limit

This policy deliberately mirrors the pinned SDK's current JSON storage shape.
It is not a stable API contract across dependency upgrades. An implementation
intended for reuse must pin or negotiate the storage encoder, budget below the
hard limit for headroom, make local rejection observable outside lab storage,
and define whether product teams drop, truncate, hash, or reroute oversize data.
