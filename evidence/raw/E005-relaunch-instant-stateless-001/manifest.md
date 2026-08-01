# E005 instant persistence process relaunch, attempt 001

- Outcome: Successful formal lifecycle run
- Date: 2026-08-01
- Resume implementation commit: `9c0b1a8`
- Stateless exporter commit: `5fcb537`
- Host runner commit: `d1e545c`
- Plan commit: `9d1a812`
- Run ID: `00000000-0000-0000-0005-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- HTTP client: instrumented wrapper over official `BaseHTTPClient`
- Planned spans: 100
- Capture after Collector readiness and resume launch: 30 seconds

## Lifecycle boundary

The first process generated the spans while the Collector was unavailable. The
host observed one persistence file of 107,770 bytes, copied the generated ledger
and metadata, and then terminated the app with `simctl terminate`. The Collector
was started only after termination. A second process configured the same
persistence directory with `--lab-resume` and generated no spans.

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
| `collector.log` | `ca8916920b85e8bc45ab1862da064a547e1e0ace4516b83c451dfefdd27e6c21` |
| `evidence-digests.tsv` | `27d27178967f4ef9ad3d594230a8f6b9c3fdeb1a9c8de9953730f2692379beba` |
| `first-launch.txt` | `c4d80ae409411c0a9818e9d89c05f6a53d2e07552b0d8725e1757caa13cf04ca` |
| `generated-before-relaunch.jsonl` | `c0c58f9e28521c93826e9c6bc963cc5835c4051aa88a9b8cc77f384228c2e0f8` |
| `generated.jsonl` | `c0c58f9e28521c93826e9c6bc963cc5835c4051aa88a9b8cc77f384228c2e0f8` |
| `host-timing.tsv` | `74e0189f3d71b8f552dfc87cb95bcbffda01f6918c94cfaacdfcb6ec1d00eb61` |
| `http-attempts.jsonl` | `af3c3a11720bbc24b351fa62af402e19cc8780bc9642a3ab521658fd5cbd3fe3` |
| `persistence-files-after.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-before-termination.tsv` | `264b423cd83a7cd616d4a19eac9c14d7e75db0dacb11376bc85682f0778d04b9` |
| `received-otlp.jsonl` | `aa8a0e575df297e1e967edad010c9209aa8985833206d51322cf5d895cd280fd` |
| `reconciliation.json` | `b3f1ff8d4db1f8a31261e2829336db62a5232d4fc7ed23100eaa3f365bdb1b0a` |
| `resume-launch.txt` | `27102c54d84c82bf543e93d186a5ad225609406478c1f7bc3f2d059c6b3cbc0a` |
| `run-before-relaunch.json` | `6f8ec1436dc5f32df8bb2bde5d96a96a6ee7652cf6741a2d11a30fc326a26fb8` |
| `run.json` | `6f8ec1436dc5f32df8bb2bde5d96a96a6ee7652cf6741a2d11a30fc326a26fb8` |

This run supports recovery across a controlled process termination for the
instant preset with one retry owner. It does not test partial writes or abrupt
OS-enforced termination.
