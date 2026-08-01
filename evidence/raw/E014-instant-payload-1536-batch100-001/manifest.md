# E014 instant 1,536-byte payload byte policy, attempt 001

- Outcome: Accepted exact-recovery intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000002`
- Persistence: official instant
- Processor batch / object budget: 100 / 262,144 bytes
- Payload attribute bytes per span: 1,536

The actual background event occurred 6.047010816 seconds after ledger commit,
before the 15-second schedule. The policy split one 100-span processor input
into an accepted 98-span, 259,580-byte object and an accepted 2-span,
5,302-byte object. Their recorded sequences cover 1...100 exactly once.

Provider flush completed in 906.540916 ms and made one 264,882-byte file visible
before direct `SIGKILL`. Resume sent one 183,618-byte request and recovered
100/100 with no duplicates. E011 lost this same preset, total count, batch
count, and payload at the native writer boundary.

The policy-event file remained byte-identical across relaunch. This run was
faster than the default intervention but still much slower than fixed-count
partitioning, so latency is not generalized from either single observation.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `351bf21543129dbe81a11835e33c0631033d9e42b3138693733db9a11c559fec` |
| `background-boundary-state.tsv` | `5ef26d6acfe0b3615ebf82566acada6184dc010001bc43a58ef88efe1f2e2ecc` |
| `collector.log` | `e3fb5182337179da7d0b0a09296b66d6f88978085edc87bdc4591f3002e89893` |
| `evidence-digests.tsv` | `86f4d29c328ec5e37e1eae304677a7400f600a34b94351625e0095ffc6f721b3` |
| `first-launch.txt` | `f18c597de1508f7fbcd0be9b0d18b013c6faf53fdb26bf692adedd0105e9fd9f` |
| `generated-before-relaunch.jsonl` | `3bd04296320bade9b791e4b77caa006c0d1f5e2d0d0bf69d8a8dd54ae8d4d542` |
| `generated.jsonl` | `3bd04296320bade9b791e4b77caa006c0d1f5e2d0d0bf69d8a8dd54ae8d4d542` |
| `host-timing.tsv` | `6e6087046d021a01284e1bcbc0c0f2ba9c889433d493d1f242d6012e064bc7e8` |
| `http-attempts.jsonl` | `6928ea1baca5f546472800e133e5f807ec49d272c7231e4798cca31c97c96bab` |
| `lifecycle-events-before-relaunch.jsonl` | `e3f9f9ef91e0dc392bde86dedaa33d6563af0cc0ce48aa7751bda0d221819aa6` |
| `lifecycle-events.jsonl` | `e3f9f9ef91e0dc392bde86dedaa33d6563af0cc0ce48aa7751bda0d221819aa6` |
| `object-policy-events-before-relaunch.jsonl` | `49e4cc267362f6fb49bb85469c2418c538b84c78e1871195f1f5bab01f194cf9` |
| `object-policy-events.jsonl` | `49e4cc267362f6fb49bb85469c2418c538b84c78e1871195f1f5bab01f194cf9` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `b5771ea536f6ce3efca0ea2ca42835ea2de853b58f868bcb03e846e05929e011` |
| `received-otlp.jsonl` | `880402921237c1aa99e2cc352d9d61c68f1bf4a31f63be4156d85b3f78a205b0` |
| `reconciliation.json` | `a27d7e4a5311489dcfc315440254aad1cf2cdaa2a96173a255160ecd876a3599` |
| `resume-launch.txt` | `b0da6a649136f68a51ff593e4b8123617d047ca1c7066c02652404b477f9f429` |
| `run-before-relaunch.json` | `ce9dbfd2455e937bbb4aaeb00018f30f7b7b4b2bceb05ad94850ee71d7db5461` |
| `run.json` | `ce9dbfd2455e937bbb4aaeb00018f30f7b7b4b2bceb05ad94850ee71d7db5461` |
