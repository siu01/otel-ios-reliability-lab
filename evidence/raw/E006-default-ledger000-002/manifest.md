# E006 default zero-offset sharp stop, attempt 002

- Outcome: Accepted zero-recovery replication
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: first observation of the complete 100-record ledger plus 0 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 44121

## Boundary observation

The host first observed the complete ledger at 13:27:28.994Z and requested the
signal at 13:27:29.008Z, 14 milliseconds later. The post-signal timestamp was
13:27:29.015Z.

No persistence file was visible before the request and none existed after the
process stopped. Resume produced no HTTP attempt and no receipt. The generated
ledger and run metadata remained byte-identical across resume.

This independently replicates the replacement attempt 003 result: all 100
logical spans had been emitted and recorded by the app, yet none crossed into a
recoverable persistence file before the abrupt stop.

## Reconciliation

- Unique generated: 100
- Unique received: 0
- Total received records: 0
- Duplicate receipts: 0
- Missing receipts: 100 (sequences 1 through 100)
- HTTP attempts across resume: 0
- Persistence files after termination: 0
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `boundary-state.tsv` | `840858f420daf4bf8f5ff26a32bd61822a6b016dbaf96b0044048ec352b8389b` |
| `collector.log` | `f811a1435b16bfcc85fa9b99c3b14b33e6afd95f46b1b829cf2dc10e33997999` |
| `evidence-digests.tsv` | `99dd789edf8be37f783392c39745003f3944fe56deb73fe8dde054e3ed4c8366` |
| `first-launch.txt` | `298bda27b72376f3cb13827987636b86d541256f80f3beb278f2792ff8adbe96` |
| `generated-before-relaunch.jsonl` | `9fa4d38dd9feab32de0407f83b316f18d2c51949ab2903127bb561c71bf9c4f8` |
| `generated.jsonl` | `9fa4d38dd9feab32de0407f83b316f18d2c51949ab2903127bb561c71bf9c4f8` |
| `host-timing.tsv` | `5a062a4c3e2d2cb6704d035793a6bccc2dd9544233702372c3b2140620322bd5` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `3130f42c585f2682e96d9ecca9b9832b68caca4e293ffe60800233415977cabd` |
| `resume-launch.txt` | `717b9901b3d412a20e4972b96592bb88e9369717045d0de0b4028c5497600b90` |
| `run-before-relaunch.json` | `4a6e0668f2590f1f37c28787d7d124b7f403f02f5ec5c95df692a7f4d86a1419` |
| `run.json` | `4a6e0668f2590f1f37c28787d7d124b7f403f02f5ec5c95df692a7f4d86a1419` |
