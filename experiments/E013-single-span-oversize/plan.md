# E013 plan: Test an irreducibly oversized single span

## Question

Can one span silently exceed the official persistence object's 256-KiB limit
even when `maxExportBatchSize=1`, proving that count-only tuning has a hard
limit?

## Rationale

E011 lost 100 payload-heavy spans and E012 recovered them by dividing the same
workload into two objects. A single span cannot be divided by
`BatchSpanProcessor`. E013 brackets the per-object boundary with exactly one
span and one export slot.

The existing automation guard will be extended from 65,536 to 524,288 payload
bytes after this plan is committed. This changes input reachability only; the
recorded descriptor, generated attribute, persistence implementation, exporter,
lifecycle path, and reconciliation logic remain unchanged.

## Hypotheses

- A 245,760-byte (240-KiB) payload will fit after encoding and recover 1/1 for
  both persistence presets.
- A 262,144-byte (256-KiB) payload will exceed the object ceiling once span and
  JSON structure are included, leaving no file and recovering 0/1 for both
  presets even though force-flush completes.
- A 307,200-byte (300-KiB) instant condition will repeat the zero-file result,
  ruling out a narrow equality-edge interpretation.
- No condition will make a first-process HTTP request, and accepted receipts
  will contain no duplicate or unexpected identity.

These hypotheses and IDs were registered before implementation or execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1, clean install per run.
- OpenTelemetry Swift persistence 2.5.0 and core 2.5.1.
- One span, `maxExportBatchSize=1`.
- Official persistence over the stateless lab OTLP/HTTP exporter.
- Actual `scenePhase.background` provider flush; 15,000-ms schedule.
- Collector unavailable through flush completion and direct `SIGKILL`.
- Same immutable run on resume; 30-second capture.

## Registered matrix

| Persistence | Payload bytes / span | Evidence directory | Span run ID |
|---|---:|---|---|
| default | 245,760 | `E013-default-payload-245760-batch1-001` | `00000000-0000-0000-0013-000000000001` |
| default | 262,144 | `E013-default-payload-262144-batch1-001` | `00000000-0000-0000-0013-000000000002` |
| instant | 245,760 | `E013-instant-payload-245760-batch1-001` | `00000000-0000-0000-0013-000000000003` |
| instant | 262,144 | `E013-instant-payload-262144-batch1-001` | `00000000-0000-0000-0013-000000000004` |
| instant | 307,200 | `E013-instant-payload-307200-batch1-001` | `00000000-0000-0000-0013-000000000005` |

## Measurements and acceptance

Record lifecycle timing, flush duration, file bytes and digest, HTTP body bytes,
reconciliation identities, and evidence stability. Preserve every outcome.

Exclude only for metadata mismatch, wrong ledger count, background at or beyond
15 seconds, first-process HTTP, invalid lifecycle sequence, evidence mutation,
or foreign-run receipts. Do not trim the payload or substitute multiple spans
inside E013.

## Scope limit

This experiment uses a deliberately extreme string to expose the indivisible
case. It does not claim that typical mobile spans are this large. The practical
point is that a count limit cannot represent an encoded-byte invariant, and an
oversized individual record needs an explicit product policy.
