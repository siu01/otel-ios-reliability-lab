# E005 default persistence process relaunch, attempt 001

- Outcome: Successful formal lifecycle comparison run
- Date: 2026-08-01
- Resume implementation commit: `9c0b1a8`
- Stateless exporter commit: `5fcb537`
- Host runner commit: `d1e545c`
- Plan commit: `9d1a812`
- Run ID: `00000000-0000-0000-0005-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Capture after Collector readiness and resume launch: 30 seconds

## Lifecycle boundary

The first process generated the spans while the Collector was unavailable. The
host waited through the default preset's asynchronous write, observed one
persistence file of 107,756 bytes, copied the generated ledger and metadata,
and terminated the app with `simctl terminate`. The Collector was started only
after termination. A second process configured the same persistence directory
with `--lab-resume` and generated no spans.

The before and after SHA-256 digests for both `generated.jsonl` and `run.json`
match exactly. This verifies that the resume launch neither regenerated spans
nor rewrote run metadata.

## HTTP attempt lifecycle

| Attempt | Process | Body bytes | Completion |
|---:|---|---:|---|
| 1 | resumed | 27,818 | success |

No HTTP attempt was recorded by the first process before termination. The
resumed process delivered the persisted file in one successful request.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Trace/span ID pair multiplicity: 100 pairs at exactly 1x
- Collector batches: 64 and 36 spans
- Persistence files immediately before termination: 1
- Persistence files after the capture window: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `43ffa9ca7e7957544fe460180d2607eb7c5a6058ae888c207d8759354c8b6b76` |
| `evidence-digests.tsv` | `896600e1197ed243defd036b5bf7f4076fe3225d575d61dbe047f07db151fb3f` |
| `first-launch.txt` | `4d7e24df9e739b738fa6dbba7185970d595faece805d87ea7e38bd170ffc53ba` |
| `generated-before-relaunch.jsonl` | `8b356260ada51ac386398f4fe117b12399e787f60901ea568361159bf8f893de` |
| `generated.jsonl` | `8b356260ada51ac386398f4fe117b12399e787f60901ea568361159bf8f893de` |
| `host-timing.tsv` | `df98f7cc89e76ca54181d07784db9c591e638bf023d7b03da04d167d2330cb6d` |
| `http-attempts.jsonl` | `1ba8b885b8d76a382e05a8a9b701f3bd0d8edf72d5f1b3bcee53b0f2338741e7` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-before-termination.tsv` | `9259d9708e9aa22d9c7da1eacdaa4fdab729eadad7834b2cc48403510aa1963d` |
| `received-otlp.jsonl` | `397ebb0d7719c7645097b0895ce91dd109f3f0c7f15b6d742d6fd113357560ea` |
| `reconciliation.json` | `3336074ad170ffd451d53dfcb6a0b63e48a12838ee1377e4b3540d3abeb23179` |
| `resume-launch.txt` | `ff727a055d079c1a47974d3a498cc70fe530c3937693ac6440132656e9680bba` |
| `run-before-relaunch.json` | `66c36a7fdb3f1321704d810739a190cc81cd2bcdc5c2ae0c527e7b011f65ead5` |
| `run.json` | `66c36a7fdb3f1321704d810739a190cc81cd2bcdc5c2ae0c527e7b011f65ead5` |

Together with the instant run, this shows that both official write presets can
recover a verified persisted batch across controlled termination when retry
state is owned by persistence alone. It does not test termination during the
asynchronous write itself.
