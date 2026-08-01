# E009 instant 100-span background scale, attempt 002

- Outcome: Accepted scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000010`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Planned spans: 100
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 3.214728192 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush completed
in 208.346750 ms. No HTTP record existed in the first process, and one
107,785-byte persistence file was visible before direct `SIGKILL`.

After Collector startup and resume, one 27,818-byte request succeeded. All 100
logical spans reconciled exactly once, and generated, run, and lifecycle
evidence remained byte-identical across relaunch.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `9564091ee2591ddb4f03cdb20064ef7d5fc1ce8f8ea7138235564a75928b44d4` |
| `background-boundary-state.tsv` | `a07588699947f4c5ba3d3e24e433281c0ab10471c8b0eb8afe8bc6ee55f6b14d` |
| `collector.log` | `3b8b44ebe1f9f91e1ae2cf71de6d3b9593b48bb3e605acd4a8016586091d159f` |
| `evidence-digests.tsv` | `c7e7ec086f0679634fe1d9988fd7e7c16b4d9e006967268d7f2d81fb033851da` |
| `first-launch.txt` | `aab23e2fbfee9e23a8671c60c98fe707a64acf1e5dc53acbcc6149913948093b` |
| `generated-before-relaunch.jsonl` | `7669b805a20d0072ecf8dda7f51ec989ba9b6ab5648b8a8843ed569bf9c7a8fd` |
| `generated.jsonl` | `7669b805a20d0072ecf8dda7f51ec989ba9b6ab5648b8a8843ed569bf9c7a8fd` |
| `host-timing.tsv` | `9b2516664fecc44f3bd96a0cff0e8ed329a350add1f246f4b05e24f5c209b0d5` |
| `http-attempts.jsonl` | `f2a1409e7469489a7f1608546323edf457600439640fd0a5f73a30330628c7d8` |
| `lifecycle-events-before-relaunch.jsonl` | `147b155421bb6feff27d7ad3b27427b7de391e55093383fa6855e9610c46a668` |
| `lifecycle-events.jsonl` | `147b155421bb6feff27d7ad3b27427b7de391e55093383fa6855e9610c46a668` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `ae0caeaac836df6d1d36b3d4d8f8b15e9ea1f5141745e121c3cf15ec8a355601` |
| `received-otlp.jsonl` | `731bc1453ae7ec232464fbb6427f1acfafe43a80a85dda241df54aa26c42d15f` |
| `reconciliation.json` | `482ca5a9238f77022def4ec618fb6526848160b33e006c78f67c1b41869daeaf` |
| `resume-launch.txt` | `85c0e6d5ef346ed3d148be99f0451981454c67b511ad44c19950006fd179a6d6` |
| `run-before-relaunch.json` | `b15236fa7f7b9a874037fc0b4131120fe758fe48481dd40d91474726cae48a63` |
| `run.json` | `b15236fa7f7b9a874037fc0b4131120fe758fe48481dd40d91474726cae48a63` |
