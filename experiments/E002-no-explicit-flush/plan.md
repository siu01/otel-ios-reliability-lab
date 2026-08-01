# E002 plan: Remove explicit force flush from instant persistence

## Question

Does the exact 2x delivery observed in both E001 instant runs still occur when
the app does not call `TracerProvider.forceFlush()` after generating the burst?

## Motivation

E001 instant attempts 001 and 002 each generated 100 unique sequences and the
Collector received every sequence exactly twice. The official persistence
decorator has both a scheduled export worker and a `flush()` path that reads all
remaining files. This experiment changes only the explicit flush dimension.

## Hypotheses

- If explicit flush overlaps with outage retries, disabling it will retain full
  eventual delivery but remove the second copy.
- If duplicates remain, the cause is more likely within scheduled retry or the
  underlying OTLP/HTTP request lifecycle.

These hypotheses were written after E001 and before E002 execution.

## Fixed conditions

- iPhone 17 Simulator, iOS 26.4.1.
- OpenTelemetry Swift core 2.5.1 and persistence exporter 2.5.0.
- `otelcol` 0.157.0 with OTLP/HTTP JSON and 64-span Collector batches.
- Official `instantDataDelivery` persistence preset.
- Clean app install before the run.
- Generate 100 spans while the Collector is unavailable.
- Start the Collector 8 seconds after app launch returns.
- Keep the app alive and take no further app-side action.
- Capture for 30 seconds after Collector readiness.

## Changed condition

- `flushMode`: `disabled` instead of the E001 value `explicit`.

## Run registry

| Condition | Evidence directory | Span run ID |
|---|---|---|
| Instant, no explicit flush | `E002-instant-no-flush-http-001` | `00000000-0000-0000-0002-000000000001` |

## Measurements and stop rule

Record generated, unique received, total received, duplicate and missing counts,
Collector batch timestamps, and persistence files remaining after the window.
Preserve but exclude the attempt if its run metadata does not say `E002` and
`flushMode: disabled`, or if the Collector misses the fixed timing procedure.
