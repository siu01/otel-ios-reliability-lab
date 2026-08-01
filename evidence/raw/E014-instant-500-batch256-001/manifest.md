# E014 instant 500 spans with byte policy, attempt 001

- Outcome: Accepted exact-recovery intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000004`
- Persistence: official instant
- Processor batch / object budget: 256 / 262,144 bytes
- Payload attribute bytes per span: 0

The actual background event occurred 3.598601984 seconds after ledger commit,
before the 15-second schedule. The processor supplied 256 and 244 spans. The
policy emitted four accepted objects:

| Call | Sequences | Spans | Encoded bytes |
|---:|---|---:|---:|
| 1 | 1...243 | 243 | 262,123 |
| 1 | 244...256 | 13 | 14,031 |
| 2 | 257...498 | 242 | 261,114 |
| 2 | 499...500 | 2 | 2,163 |

All were at or below the 262,144-byte budget and cover 1...500 exactly once.
Provider flush completed in 4,500.461625 ms and made one 539,431-byte file
visible before direct `SIGKILL`. Resume sent one 138,591-byte request and
recovered 500/500 with no duplicates. E009 lost this same preset, total count,
processor batch, and payload without the byte policy.

The policy-event file remained byte-identical across relaunch. Like the default
run, the multi-second flush is accepted evidence of prototype cost rather than
an operational latency promise.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `b99c605a1e781bc45624c7473a313626fff5423442facda18486f3fbf8f89484` |
| `background-boundary-state.tsv` | `6510bfb9f23a875c2d78d486e50a0f35a8c253a2e21843bdc9be4d31763384f5` |
| `collector.log` | `fabef9627d7336343c78205053279b4d5f5209bcbba11a9831e084e67e740dec` |
| `evidence-digests.tsv` | `0169e9571ec45dbbf81ecc00e4c022256cef88f74940cca35b360288131e6197` |
| `first-launch.txt` | `0809b3e528291f8cae0655ad6f741283292c897acd1d9ddbf78b1342374b0b8b` |
| `generated-before-relaunch.jsonl` | `1ba9981eb98912fa46506541fc380240cbaa12967e040ea8c3d3dd500d3fa02e` |
| `generated.jsonl` | `1ba9981eb98912fa46506541fc380240cbaa12967e040ea8c3d3dd500d3fa02e` |
| `host-timing.tsv` | `fa6fad3eeca110de710ef7dc33eb676c873037c357a6207eaa8168711f9bd16a` |
| `http-attempts.jsonl` | `62e182d842ddc6e2a3def48396d4f999a14b07586c094c2815d18f80c7852bea` |
| `lifecycle-events-before-relaunch.jsonl` | `4c6520bc03d73b1c1986b8c80f336745200bb1f0e96f227af74ff9a5e410fd99` |
| `lifecycle-events.jsonl` | `4c6520bc03d73b1c1986b8c80f336745200bb1f0e96f227af74ff9a5e410fd99` |
| `object-policy-events-before-relaunch.jsonl` | `cdd3352b8b76bcc1c5dd7ca5e6d2418870e0aa72d54d5adf29508fdf61a7dc5a` |
| `object-policy-events.jsonl` | `cdd3352b8b76bcc1c5dd7ca5e6d2418870e0aa72d54d5adf29508fdf61a7dc5a` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `00aa4bd68dbdfcaeb704338ad2ad414492ccd186029812cdef60f46b9cd67ee4` |
| `received-otlp.jsonl` | `a9198bb087041bb7f995110d64ec18054f1485cfec65759bb7e3be309bb48e79` |
| `reconciliation.json` | `ee48f606bd386dea04ac97948d900cdb1f6cde8df47e0bc7753c704d47a5f905` |
| `resume-launch.txt` | `4e98923836bbb192d635f6fcc4a2998e7a8fa24914eebc2de58f29fef2d2bcf2` |
| `run-before-relaunch.json` | `42344e66069c86bd11380096b773aed6d9011d8b3495d0b7a5ac92cf62c22d57` |
| `run.json` | `42344e66069c86bd11380096b773aed6d9011d8b3495d0b7a5ac92cf62c22d57` |
