# E001 results: recovery, loss, and duplicate delivery diverged by preset

## Accepted comparison

The app generated 100 spans with the Collector unavailable, remained alive,
started the Collector eight seconds after app launch returned, and then waited
30 seconds without another app-side action.

| Persistence | Generated | Unique received | Total received | Missing | Duplicates |
|---|---:|---:|---:|---:|---:|
| Disabled | 100 | 0 | 0 | 100 | 0 |
| Official default | 100 | 100 | 100 | 0 | 0 |
| Official instant | 100 | 100 | 200 | 0 | 100 |
| Official instant, fresh replication | 100 | 100 | 200 | 0 | 100 |

## Interpretation

The non-persistent exporter did not automatically recover within the fixed
window. The official default persistence preset recovered all spans exactly
once. The instant preset also recovered every logical span, but every sequence
was delivered twice in both fresh-install runs.

The difference between default and instant was not merely delivery latency. The
default worker's longer file-age and export delays avoided an HTTP attempt while
the Collector was down in this timing window. The instant worker attempted
earlier and entered a failure/retry path.

E001 established the unexpected behavior but did not isolate it. E002 showed
that explicit force flush was not required. E003 then recorded request bodies
growing after each failed attempt, supporting dual retry ownership as the
mechanism.

## Invalid attempts retained

- `none-001`: the manual host procedure missed the fixed eight-second startup
  timing, so it was excluded before Collector startup.
- `none-002`: the timing completed, but the app recorded experiment `E000`
  because the launch path still hard-coded its ID. It was excluded and led to a
  validated `--lab-experiment-id` argument.

Neither invalid attempt was overwritten or reinterpreted. Their ledgers,
timings, screenshots where applicable, and exclusion reasons remain in raw
evidence.
