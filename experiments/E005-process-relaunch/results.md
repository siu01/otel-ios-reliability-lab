# E005 results: Persisted spans survived process relaunch

## Result

Both registered persistence presets recovered all 100 spans after a controlled
process termination. The Collector was unavailable for the entire first process
and was started only after that process had terminated. The resumed process did
not regenerate spans.

| Persistence | File before termination | HTTP attempts | Received total | Unique | Duplicates | Missing | File after |
|---|---:|---:|---:|---:|---:|---:|---:|
| official instant | 1 (107,770 B) | 1 success | 100 | 100 | 0 | 0 | 0 |
| official default | 1 (107,756 B) | 1 success | 100 | 100 | 0 | 0 | 0 |

Each successful request was 27,818 bytes. The Collector decoded it into batches
of 64 and 36 spans. Every generated trace/span identity appeared exactly once.

## Evidence that resume did not regenerate

The runner copied `generated.jsonl` and `run.json` immediately before process
termination, then copied them again after the resume capture. Both SHA-256
digests matched within each run:

| Persistence | Generated ledger digest | Run metadata digest |
|---|---|---|
| instant | `c0c58f9e…c2e0f8` | `6f8ec143…cbc0a` |
| default | `8b356260…f893de` | `66c36a7f…65ead5` |

Both generated ledgers contained exactly 100 records before and after relaunch.
No transport attempt occurred in either first process. Each resumed process
made one successful request, so the recovered receipts cannot be attributed to
an in-flight first-process request.

## Interpretation

Once a complete file was observable, the official persistence decorator could
discover and deliver it from a newly launched process for both the synchronous
instant preset and the asynchronous default preset. Combined with E004, this
shows a workable single-retry-owner path that provides both exact recovery and
controlled-process lifecycle durability in the lab.

The result deliberately does not answer the harder write-boundary question.
The host waited for a complete persistence file before termination. A process
killed during the default preset's asynchronous write might yield no file, a
temporary file, or a corrupt file; E005 contains no evidence for those cases.

## Evidence locations

- [`E005-relaunch-instant-stateless-001`](../../evidence/raw/E005-relaunch-instant-stateless-001/manifest.md)
- [`E005-relaunch-default-stateless-001`](../../evidence/raw/E005-relaunch-default-stateless-001/manifest.md)

## Follow-up questions

1. What happens when termination is scheduled at fixed offsets around the
   asynchronous write rather than after file observation?
2. Does the official stateful exporter restore the same file exactly after a
   clean relaunch, or can pre-termination failures still amplify it?
3. How does recovery behave after Simulator reboot, app upgrade, corrupt file,
   or deliberate storage-pressure eviction?
