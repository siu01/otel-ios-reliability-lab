# E007 default provider force-flush, attempt 001

- Outcome: Accepted exact-recovery intervention run
- Date: 2026-08-01
- Barrier implementation commit: `c74c0e1`
- Host runner commit: `1b0ecfd`
- Plan commit: `b08e47e`
- Run ID: `00000000-0000-0000-0007-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Flush: existing provider force-flush only
- Exporter: lab stateless OTLP/HTTP
- Stop: direct `SIGKILL` after observing flush completion

## Flush and boundary observation

App lifecycle evidence recorded generated-ledger commit, flush start, flush
completion, and burst completion in order. The monotonic flush duration was
37,273,375 ns (37.27 ms).

At the host's post-completion check, one 107,797-byte persistence file was
already visible. The first process was then killed and had made no HTTP attempt.
Resume made one successful 27,818-byte request and recovered all 100 spans
exactly once. Lifecycle, generated-ledger, and run-metadata digests remained
identical across resume.

This condition shows that provider force-flush alone was sufficient under this
default-preset Simulator timing. It does not show that the added exporter-level
durability barrier is required.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `edf5e59ec604142e387942da26dc28e56281ed083bf4b43dbe255917ad3112ed` |
| `evidence-digests.tsv` | `9b44048009b14b8557ce5464e241f705f756d0cf46fe7d6b372017c80d8ac4e3` |
| `first-launch.txt` | `bb303b76fe3052665bef16f973baeba5d0e337ba42e4f1b2be9fe8019b08ae18` |
| `flush-boundary-state.tsv` | `f5fc80d6bc78dcb1daa327365f363f0b8e671acbfcc545b6f019d1a4c372a900` |
| `generated-before-relaunch.jsonl` | `6e62c17d7043739101896f137ade27ce75339da469be3d3b5fe15e8ddf0f3eda` |
| `generated.jsonl` | `6e62c17d7043739101896f137ade27ce75339da469be3d3b5fe15e8ddf0f3eda` |
| `host-timing.tsv` | `26b2c97d6dfd7e82bed4e505fc4e44d36cdff4ad02f487ecb28f78f3b42c66d8` |
| `http-attempts.jsonl` | `c6e2e2a1437fbe032a64bac67e0b88d399e6d6d5422250b48114c8424799ecbd` |
| `lifecycle-events-before-relaunch.jsonl` | `13bec2a70f61a0bf0713cf55f1ffe7dbee92f7af2ed558fe8b8c63d949394af8` |
| `lifecycle-events.jsonl` | `13bec2a70f61a0bf0713cf55f1ffe7dbee92f7af2ed558fe8b8c63d949394af8` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `e35eff2d710efe7d13aeaf71fcbaf04bd84a7b39783452c4f3cc7a0817f8eb45` |
| `received-otlp.jsonl` | `a7dd7c199412dac5a9b2f76b87763407e49633a821e3222e2d854d6a312e04e9` |
| `reconciliation.json` | `b97dd94916249d4402e58c5f569b3f905ce6a78a211f77a88c6dbc0244f20c7a` |
| `resume-launch.txt` | `2fa4205f87d5799fceb9f5bc26d174b11c762e65ed97eb28928a73c7f1a179be` |
| `run-before-relaunch.json` | `d35f9c0fd62b741850a84b25db90a57f68e90b2d5e66896d06f81ba61a3722c4` |
| `run.json` | `d35f9c0fd62b741850a84b25db90a57f68e90b2d5e66896d06f81ba61a3722c4` |
