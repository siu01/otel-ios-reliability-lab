# E016 results: Provider duration understated main-queue delay

## Outcome

All four preregistered runs produced exactly one scheduled/executed probe pair,
crossed the background boundary before the 15-second processor schedule, made
no first-process HTTP request, and recovered 500/500 sequences with no
duplicates after relaunch.

The responsiveness hypotheses did not all survive. Every queued closure waited
at least as long as the synchronous provider call, as expected. However,
provider duration accounted for only 24.6% to 76.2% of the measured queue delay.
The remaining delay was 224.1 to 303.1 ms in every condition, not below the
preregistered 100-ms bound. The Instant binary run also missed the full
sub-second queue-delay bound even though its provider call itself was below one
second.

## Measurements

| Persistence | Object policy | Batch | Provider flush | Main-queue delay | Beyond flush | Delivery |
|---|---|---:|---:|---:|---:|---:|
| Default | SDK native | 100 | 72.964 ms | 297.104 ms | 224.139 ms | 500/500 |
| Instant | SDK native | 100 | 129.497 ms | 374.177 ms | 244.680 ms | 500/500 |
| Default | Binary byte budget | 256 | 476.153 ms | 702.835 ms | 226.683 ms | 500/500 |
| Instant | Binary byte budget | 256 | 968.004 ms | 1,271.137 ms | 303.134 ms | 500/500 |

The table is reproducible from committed evidence with:

```sh
scripts/summarize-main-queue-probes.sh \
  evidence/raw/E016-default-native-batch100-001 \
  evidence/raw/E016-instant-native-batch100-001 \
  evidence/raw/E016-default-binary-batch256-001 \
  evidence/raw/E016-instant-binary-batch256-001
```

## Hypothesis audit

| Preregistered hypothesis | Result |
|---|---|
| Exactly one scheduled/executed probe per run | Passed, 4/4 |
| Probe delay at least provider flush duration | Passed, 4/4 |
| Probe delay minus flush below 100 ms | Failed, 0/4 |
| Exact 500/500 delivery with no duplicates | Passed, 4/4 |
| Binary policy queue delay below one second | Mixed: Default passed, Instant failed |

No failed duration hypothesis was used as an exclusion criterion.

## Policy comparison

Binary byte-aware partitioning retained E015's four accepted chunks in both
presets: 243 + 13 + 242 + 2. Every encoded object stayed at or below 262,144
bytes, and all 500 identities were covered exactly once.

Compared with each SDK-native batch-100 condition, the byte-aware computation
increased measured queue delay by 136.6% for Default and 239.7% for Instant.
This is not an equivalent policy comparison: native batch 100 is an
already-tuned fixed-count mitigation, while binary batch 256 discovers exact
safe byte boundaries. The comparison quantifies the responsiveness price of
that stronger guarantee for this workload; it does not prove the persistence
preset caused the difference.

## Interpretation

`forceFlush` timing alone was not a sufficient UI-queue metric. The probe was
already enqueued before the synchronous call, yet it did not run until an
additional 224 to 303 ms had passed. That residual includes the
`flushCompleted` evidence write, the rest of the SwiftUI lifecycle callback,
and Simulator/OS scheduling after backgrounding. E016 cannot attribute those
components individually, but they are precisely the work a caller would miss
by timing only `forceFlush`.

The Instant binary run is the clearest counterexample: a 968-ms provider call
looked sub-second, while the queued work resumed after 1.271 seconds. A
production design should therefore avoid doing byte partitioning and blocking
flush work synchronously on the main actor merely because provider timing fits
a nominal lifecycle budget.

## Evidence integrity

- Every run recorded the registered `mainQueueProbeEnabled: true` dimension.
- Lifecycle order was `flushStarted` → `mainQueueProbeScheduled` →
  `flushCompleted` → `mainQueueProbeExecuted`.
- Each run had one persistence file before direct `SIGKILL` and zero
  first-process HTTP attempts.
- Generated ledger, run metadata, lifecycle events, and policy events were
  byte-identical before and after relaunch.
- Resume produced one successful 138,591-byte OTLP request in every condition.

## Limit

The app was already moving to the background, so E016 measures delayed
main-queue work, not visible dropped frames or touch latency. It is one run per
condition on Simulator and does not measure real-device suspension or energy.
The next intervention should move preparation/flush work off the main actor and
repeat this probe while separately preserving the durability boundary.
