# E007 instant provider force-flush, attempt 001

- Outcome: Accepted exact-recovery preset comparison
- Date: 2026-08-01
- Barrier implementation commit: `c74c0e1`
- Host runner commit: `1b0ecfd`
- Plan commit: `b08e47e`
- Run ID: `00000000-0000-0000-0007-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Flush: existing provider force-flush only
- Exporter: lab stateless OTLP/HTTP
- Stop: direct `SIGKILL` after observing flush completion

## Flush and boundary observation

App lifecycle evidence recorded all four phases in order. The monotonic flush
duration was 74,041,167 ns (74.04 ms). One complete 107,763-byte persistence
file was visible before the signal and remained after termination.

The first process made no HTTP attempt. Resume made one successful 27,818-byte
request and recovered all 100 spans exactly once. Lifecycle, generated-ledger,
and run-metadata digests remained identical across resume.

Provider force-flush was sufficient for both registered presets in these two
runs. Instant's synchronous write did not make its one measured flush faster
than default's; this is a single-run duration observation, not a performance
ranking.

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
| `collector.log` | `63881c6fb443a59b6334b618aa7a6dcda615e0cecb65329d3d192b282eb9e949` |
| `evidence-digests.tsv` | `dc4750a3056a8495d9585d90fc83d22857f9e2651e851145697b1febad28e38c` |
| `first-launch.txt` | `6d8145ea4ce6ec4c5e03f41ac7f1282e532a4cf0586464f362ff0516d073ed41` |
| `flush-boundary-state.tsv` | `9f5c6df9cff679876a1056feb93f3225715f35b8457341f3b8e9a0b16e234041` |
| `generated-before-relaunch.jsonl` | `c2afd999e2da171d030de253c51b8635fdfb21330783c43fd75afb71b77d9dfd` |
| `generated.jsonl` | `c2afd999e2da171d030de253c51b8635fdfb21330783c43fd75afb71b77d9dfd` |
| `host-timing.tsv` | `868e54a04583f33e490c640a62ff342f502aba2e8a9d5c86fd8348b4fbcb4a4f` |
| `http-attempts.jsonl` | `84de5651238a437261a385bafd844f95c121f425ed77ca15ab6a2d622ca02169` |
| `lifecycle-events-before-relaunch.jsonl` | `bf2dff6674b9a6cab60775c453d54059ba5bbc7709173c632ddfc81c50a874c5` |
| `lifecycle-events.jsonl` | `bf2dff6674b9a6cab60775c453d54059ba5bbc7709173c632ddfc81c50a874c5` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `485b8c21ba7b83974df9f08cd69b6792df6a1de8887fc1423e23062a07f69507` |
| `received-otlp.jsonl` | `ff99da41064dcfbbaeaa3e18a7de2595c774e73788e6c43af748ea19bfebbad4` |
| `reconciliation.json` | `83af777ad2a67b77f2acf3d096c7e3480e7e963a75606315c938f1690bbc607c` |
| `resume-launch.txt` | `029f0a280c7bf2653a0602bc5c0b5491dab900ccc3e59d0a4cb6aaf236b3cb05` |
| `run-before-relaunch.json` | `0bada56fa4cdd956f07fbe4b1a9226cba7a29fe49fe6f70819e27fe000b24812` |
| `run.json` | `0bada56fa4cdd956f07fbe4b1a9226cba7a29fe49fe6f70819e27fe000b24812` |
