# E009 instant 1,000-span background scale, attempt 002

- Outcome: Accepted partial-recovery scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000012`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Planned spans: 1,000
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 3.230750208 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush reported
completion after 220.378166 ms. No HTTP record existed in the first process.

At direct `SIGKILL`, one 250,307-byte persistence file existed. Resume sent one
64,482-byte OTLP request and recovered 232/1,000 with no duplicates. As in the
default run, the received set was the contiguous suffix 769...1,000; sequences
1...768 were missing.

Pinned source explains the exact partition. The lab's
`maxExportBatchSize=256` divides 1,000 into 256 + 256 + 256 + 232. Both official
presets limit one encoded persistence object to 256 KiB. The three 256-span
objects exceeded that byte limit and were silently dropped; the smaller final
232-span object fit and survived. Synchronous writing cannot recover an object
rejected before append.

## Reconciliation

- Unique generated: 1,000
- Unique received: 232 (sequences 769...1,000)
- Duplicate receipts: 0
- Missing receipts: 768 (sequences 1...768)
- Persistence files after termination: 1 (250,307 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful, 64,482-byte body

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `0ac2fa9891b3bb3526c0802d29e060182013cb609979adf45090e58e704d82a3` |
| `background-boundary-state.tsv` | `34187a2df4bc08d0c1060d05ba3f0136273ce79aadb433c538ec172d8025ec65` |
| `collector.log` | `7a0f168918cc530c55cba4f67e12fb03df9e47592f47fcddc7f4d04794a034cf` |
| `evidence-digests.tsv` | `dd003e1f062a658be37a058f29dec4166ce02f1d93bd4bd2a645f95630eb3f9c` |
| `first-launch.txt` | `2f4040a47b8ca58a754230f0ff835fe962927af6b044b224d6f2208be1563008` |
| `generated-before-relaunch.jsonl` | `c8438cb761cf0d5042c3ca5777c7ab38a5bf2e689a8b60c75f318944db1d5faa` |
| `generated.jsonl` | `c8438cb761cf0d5042c3ca5777c7ab38a5bf2e689a8b60c75f318944db1d5faa` |
| `host-timing.tsv` | `03a43cec5e2c00783914a4420416e06f875ac5d2513182d7b8b0e3eb44ee589f` |
| `http-attempts.jsonl` | `e261f96ecce60ca831dcce62b46caddc80c83e83d720aaea4829d23d2975f7f1` |
| `lifecycle-events-before-relaunch.jsonl` | `96c753c89d3e772fce259f8ec0f16aaa3453d56ec59f6360ae259af641f118f5` |
| `lifecycle-events.jsonl` | `96c753c89d3e772fce259f8ec0f16aaa3453d56ec59f6360ae259af641f118f5` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `04b3ecec49256f1d0d2fb9ce8bb50281d408bbede97d03e12b51b4252db9c5f1` |
| `received-otlp.jsonl` | `8a3644067ed0cebae9e49272ed3bcbec3dd1dadf9f07f24cc60c36b2a61c3387` |
| `reconciliation.json` | `aeec623e8ad8e958154f5e0946f3346454b88e77dcdad7c0fe1bd416ce757165` |
| `resume-launch.txt` | `932a8bf6516f92a58fe8aa12913642e241066d80fc0d4b5e577764b6e0c13e37` |
| `run-before-relaunch.json` | `b779b53da7b25ee5d4b4979ada10c60d08648936ded042ef667cb6223e3b49b7` |
| `run.json` | `b779b53da7b25ee5d4b4979ada10c60d08648936ded042ef667cb6223e3b49b7` |
