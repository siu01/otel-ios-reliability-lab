# E012 instant 2,048-byte payload with batch 50, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-02
- Plan commit: `e60c6bb`
- Run ID: `00000000-0000-0000-0012-000000000004`
- Persistence: official instant
- Spans / max export batch: 100 / 50
- Payload attribute bytes per span: 2,048

The background event occurred 6.118925056 seconds after ledger commit. Provider
flush completed in 215.901667 ms. Two encoded objects fit individually and were
appended to one 316,107-byte file, again exceeding the distinct 256-KiB
per-object ceiling only after both objects were accepted.

Resume sent one 234,818-byte request and recovered 100/100 with no duplicates.
This directly recovers the E011 instant 2,048-byte, batch-100 outcome of 0/100
without changing span count, payload, persistence preset, or lifecycle timing.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `6fb003cb0ff5fdc026fb2fcc64440cb2cf87460a3d2d4791e6f0a2ec174395ba` |
| `background-boundary-state.tsv` | `4e5bb0d56d55387578a6a0febbe0403753e187794b0379eec30a55e3b06c4151` |
| `collector.log` | `63cfb9e162832006030296c9d5ec4ad18fef93a25d47f481af45e9e9714e2da4` |
| `evidence-digests.tsv` | `ee788182137b56208281b60b6a358adfc0fd252b3b93d09fc2e2cbdd8a73a241` |
| `first-launch.txt` | `7d81b82c2a538b610547b6f07ef8c5c56fdfd10156de936249b5f15a2b63d3fa` |
| `generated-before-relaunch.jsonl` | `1acffc0befbfa76195f35602c7d97aabd392e5b80d285d9b7764d113734efb9d` |
| `generated.jsonl` | `1acffc0befbfa76195f35602c7d97aabd392e5b80d285d9b7764d113734efb9d` |
| `host-timing.tsv` | `b93ea476267302c8072d0b40ea80896675cf738b08c748ab53c35a6a400015f9` |
| `http-attempts.jsonl` | `054cc50b3359638ceaaaf63d2bad69ea3c197f5d4d2c60543d0e7604b4b6b394` |
| `lifecycle-events-before-relaunch.jsonl` | `5fa5cad5374a1be666e417232c42c60f375a641159c0b69313149f04c659f531` |
| `lifecycle-events.jsonl` | `5fa5cad5374a1be666e417232c42c60f375a641159c0b69313149f04c659f531` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `3e2daa079bcf8c335335efe9e865e3253881e9eede2a1b61122d0ffde4d4d7dc` |
| `received-otlp.jsonl` | `b03d1bce092f31d26f544bf839d14cdd40c0bba5f1955c6012ebafe3825105f0` |
| `reconciliation.json` | `2241d8fe555ab5050cd43b85126bf8507afddead972d7dbf25b40027a65ed720` |
| `resume-launch.txt` | `d13f26fb4ac4e1ac5557ea91e15741dac67b3893ded504822ef6efbba5d6156f` |
| `run-before-relaunch.json` | `428ee5f5cf511c2db786b8dffaae4c02352992e0fe4dbbd91e3dcc9e86029a9d` |
| `run.json` | `428ee5f5cf511c2db786b8dffaae4c02352992e0fe4dbbd91e3dcc9e86029a9d` |
