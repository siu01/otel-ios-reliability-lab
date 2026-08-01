# E009 default 1,000-span background scale, attempt 002

- Outcome: Accepted partial-recovery scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000009`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 1,000
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 3.136150016 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush reported
completion after 289.889917 ms. No HTTP record existed in the first process.

At direct `SIGKILL`, one 250,297-byte persistence file existed. Resume sent one
64,482-byte OTLP request and recovered 232/1,000 with no duplicates. The received
set was the contiguous suffix 769...1,000; sequences 1...768 were missing. The
surviving file was therefore decodable and internally complete for those 232
spans rather than a partially decoded request.

Generated, run, and lifecycle evidence remained byte-identical across relaunch.
Pinned source and the matching instant result explain the partition: configured
256-span chunks met a preset-independent 256-KiB encoded-object limit. The first
three chunks, sequences 1...768, were rejected and their errors swallowed. The
smaller 232-span suffix fit and became the one recoverable file. Provider flush
completion therefore masked deterministic size loss rather than an incomplete
asynchronous append in this run.

## Reconciliation

- Unique generated: 1,000
- Unique received: 232 (sequences 769...1,000)
- Duplicate receipts: 0
- Missing receipts: 768 (sequences 1...768)
- Persistence files after termination: 1 (250,297 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful, 64,482-byte body

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `1fb7680d783b2092c122a373b05d7bda64b8288f13bb0e617da1a83b3353f702` |
| `background-boundary-state.tsv` | `51a80d88eacdc594295c64138e865fc7aaa7be20d73a9d4550166b0a172ebcbb` |
| `collector.log` | `b2bb82c77e2a33fd75164c5ae2b7f1ee5de52543e2e576a635bb7420e1e390d4` |
| `evidence-digests.tsv` | `472fcaeedeb45d41b231b4e4d14c29737abbbc3df59e7cf97636b081da5a0551` |
| `first-launch.txt` | `0ff5ef11d94ab01f4d7f44d3f182865392aca403a8e602cebb7d0cbff3e12ec0` |
| `generated-before-relaunch.jsonl` | `c65de55bd06a50bf6582c459e4b13b0d2fb05bd9a4344d3ce46dd3720568fd41` |
| `generated.jsonl` | `c65de55bd06a50bf6582c459e4b13b0d2fb05bd9a4344d3ce46dd3720568fd41` |
| `host-timing.tsv` | `8cb89b84e09938f6abd30c847125ecf0df0c432827f059671714c6745e778c97` |
| `http-attempts.jsonl` | `3287b6477af9b73a727ac345331466a06dc28b2155717f3a1dddacfde9a0c7ce` |
| `lifecycle-events-before-relaunch.jsonl` | `f79c8f3a49c00ba2227f478eb4ad98ff0f3ecbde266d742f50107dd98af94789` |
| `lifecycle-events.jsonl` | `f79c8f3a49c00ba2227f478eb4ad98ff0f3ecbde266d742f50107dd98af94789` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4617eb87cf8e9cc9d1e90340555ee2f801b43e02310499ff38895c8b34fa0337` |
| `received-otlp.jsonl` | `f85961b6af582d4f39c44750f953aaa47b2f76c4728953f5a4d184c76d8c4340` |
| `reconciliation.json` | `5291e2abb314d09b43a3e19a1bce986e77dd2966f85ca2c51ba705c527a39e06` |
| `resume-launch.txt` | `22e579784ac6d9381bf8c910689e156edbd87cf3155827a21001650ae1f0f82d` |
| `run-before-relaunch.json` | `981ef1cf7adb9613c40a3d8c5808c3072f2cd1cc0968360893b025b8d6d41021` |
| `run.json` | `981ef1cf7adb9613c40a3d8c5808c3072f2cd1cc0968360893b025b8d6d41021` |
