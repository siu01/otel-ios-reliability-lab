# E009 default 100-span background scale, attempt 002

- Outcome: Accepted scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000007`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 100
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 6.114910208 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush completed
in 111.959333 ms. No HTTP record existed in the first process, and one
107,791-byte persistence file was visible before direct `SIGKILL`.

After Collector startup and resume, one 27,818-byte request succeeded. All 100
logical spans reconciled exactly once, and the generated, run, and lifecycle
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
| `background-app-launch.txt` | `fcf9b92dc11e0a55bc49c6324b4d1d44014951eda6b249ee91149b2db85b10ed` |
| `background-boundary-state.tsv` | `0c2f8381c3d638fbe8f3827c3fd1779a8090e6048554412e3df4327d2d79a7d3` |
| `collector.log` | `993bb6425e6f964c328ca08f84115cb8e541a784e106eb0b9e91d49ebb88be07` |
| `evidence-digests.tsv` | `72c6a91392607b377130e55354b6db51606faabd7f89339a3329588779a48bd2` |
| `first-launch.txt` | `c5ebadee83f8bccaaa513fa09e0e777590bb51ab503b29e518e7627dae07c372` |
| `generated-before-relaunch.jsonl` | `b61efc56093a8a1c394d6db0aa1910c0173334ccb610bb4626a33ce24edb3f18` |
| `generated.jsonl` | `b61efc56093a8a1c394d6db0aa1910c0173334ccb610bb4626a33ce24edb3f18` |
| `host-timing.tsv` | `1024e43bf428a495c2462a7427ac5f32994be289131e395802816c1511adcb26` |
| `http-attempts.jsonl` | `9c3a5726231afdfecca01a7c943b55733c62c53134dbce10d8d44e9541abda09` |
| `lifecycle-events-before-relaunch.jsonl` | `29a4eced16ad2b5293ea7d0da63ead16f51da9465255d5cdc44b6a436d6c932c` |
| `lifecycle-events.jsonl` | `29a4eced16ad2b5293ea7d0da63ead16f51da9465255d5cdc44b6a436d6c932c` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `98214be7d11fb6e51c6d196d6adf2f04fa672df688a3004a92fdf8b4ae159b83` |
| `received-otlp.jsonl` | `921406fe4754416f528e871892f0691f2af3dd0c2b2b34c379f9130d3b614040` |
| `reconciliation.json` | `bffb19ed967c4f1ea6ddba69f8c5f441e74646519e1ede23f1eb0246b9b91077` |
| `resume-launch.txt` | `7745a06cc004552c6edffb8534d93368eaf07e1e09e5d2819c9db870a3dddd69` |
| `run-before-relaunch.json` | `4d6ef788a8d27ce465bcf9dbe2a491f1bd8ae24d81947c21d15fbc700522742b` |
| `run.json` | `4d6ef788a8d27ce465bcf9dbe2a491f1bd8ae24d81947c21d15fbc700522742b` |
