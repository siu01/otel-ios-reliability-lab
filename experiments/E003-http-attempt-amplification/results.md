# E003 results: persistence retry amplified the HTTP exporter's pending batch

## Result

All four runs supported the pre-run model. For the tested composition, every
completed HTTP failure added one more copy of the original 100-span file to the
next request. The first successful request delivered all accumulated copies.

| Collector delay | Completed failures | Successful body bytes | Total received | Exact multiplicity |
|---:|---:|---:|---:|---:|
| 4 s | 0 | 27,818 | 100 | 1x |
| 6 s | 1 | 55,418 | 200 | 2x |
| 8 s | 2 | 83,018 | 300 | 3x |
| 10 s | 2 | 83,018 | 300 | 3x |

Within this matrix:

```text
delivered multiplicity = completed HTTP failures + 1
successful body bytes  = 27,818 + 27,600 × completed HTTP failures
```

The ten-second result matters: it remained 3x because backoff allowed only two
failed attempts before recovery. Wall-clock outage length was not itself the
direct multiplier.

## Direct lifecycle evidence

The eight-second run recorded this sequence at the HTTP client boundary:

1. 27,818-byte request completed with connection-refused failure.
2. 55,418-byte request completed with connection-refused failure.
3. 83,018-byte request completed successfully.

The Collector then captured 300 records. All 100 sequence IDs appeared exactly
three times. The three copies also shared the same trace ID and span ID for each
logical span, confirming replay of encoded `SpanData`, not new span generation.

The six-second run showed one 27,818-byte failure followed by one 55,418-byte
success and exactly 200 receipts. The four-second negative control had no failed
attempt, one 27,818-byte success, and exactly 100 receipts.

## Mechanism supported by pinned source

The persistence decorator retains its file when the decorated exporter reports
failure. Independently, `OtlpHttpTraceExporter` restores its complete failed
outgoing array to `pendingSpans`. On the next persistence retry, the exporter
appends the same file batch to that pending array before sending.

This is retry ownership at two adjacent layers. Each layer behaves consistently
with its own at-least-once responsibility, but composing them retains two copies
of one logical batch after a failure.

E003 also narrowed an alternative explanation. All recorded failures completed
within milliseconds with `NSURLErrorDomain -1004` connection refusal. These runs
did not require an earlier URLSession task to survive the exporter's two-second
semaphore timeout.

## Practical interpretation

- Persistence changed outage recovery from 0% delivery to complete delivery.
- The instant preset exposed failed retries before Collector recovery.
- With the stateful OTLP/HTTP exporter underneath it, those retries amplified
  delivery to 2x or 3x instead of exactly once.
- Stable trace and span IDs make downstream deduplication technically possible,
  but that shifts state, retention, and cost to the receiver.

Candidate mitigations require separate experiments: assign retry ownership to a
single layer, use a stateless decorated exporter when filesystem persistence owns
retry, or deduplicate by signal identity at ingestion. None is claimed validated
by E003.

## Scope and limitations

- One iOS Simulator runtime and loopback failure mode.
- One SDK/persistence version pair and one Collector version.
- One 100-span logical file and OTLP/HTTP JSON transport.
- One run at each duration, although the uninstrumented 8-second 3x result was
  independently observed in E002.
- HTTP instrumentation wrapped the official client but added local JSONL writes;
  the unchanged 3x E002/E003 result argues against the wrapper creating the
  amplification.

See each evidence directory for raw requests, receipts, timing, reconciliation,
empty post-run queues, and SHA-256 manifests.
