# E010 default 1,000-span safe-chunk intervention, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-01
- Intervention plan commit: `26fc3b6`
- Run metadata commit: `407c099`
- App intervention commit: `2f79169`
- Runner commit: `78a5855`
- Run ID: `00000000-0000-0000-0010-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 1,000
- Maximum export batch: 100
- Flush: provider explicit from `scenePhase.background`
- Processor schedule delay: 15,000 ms

## Intervention result

The background event occurred 5.109652992 seconds after generated-ledger commit,
before the schedule boundary. Provider flush completed in 169.193500 ms. Ten
100-span persistence objects fit and were appended into one 1,078,677-byte file
before direct `SIGKILL`; the first process recorded no HTTP attempt.

After resume, one 277,091-byte OTLP request succeeded and recovered all 1,000
sequences exactly once. This changed the direct E009 default comparison from
232/1,000 at batch size 256 to 1,000/1,000 at batch size 100 without changing
the persistence preset or adding a post-flush wait.

## Reconciliation

- Unique generated: 1,000
- Unique received: 1,000
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1 (1,078,677 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `ccc49246796ae0d22e31a02c6027c896a1d1a77150e448ec67b75a503ca39663` |
| `background-boundary-state.tsv` | `ac5b926756b7ab3c187c862088af43b583ff6bd69b5ef8be07d89c55c05a1df3` |
| `collector.log` | `0ef7d84167ee51e910be507dd8cb4943e25ea20797b28f60d2a4479a6f56c526` |
| `evidence-digests.tsv` | `9d4451c6b1a8a9158654e323d821d2a79fb23e82358d1f53f7054315fabe68c2` |
| `first-launch.txt` | `11a5353e1b97f7a0a530b8f1fe31cc376c782a65ca400746c1eec3fb297d281a` |
| `generated-before-relaunch.jsonl` | `2520e344d0755fd3ea1bbaa618f3ef97c7578f22cd3d815cf96d3e4cf125fed4` |
| `generated.jsonl` | `2520e344d0755fd3ea1bbaa618f3ef97c7578f22cd3d815cf96d3e4cf125fed4` |
| `host-timing.tsv` | `65845f5a72a946eed852bc6fc8a8271db170c57030a7315c2f1609ec5b555c91` |
| `http-attempts.jsonl` | `b158a5fee1c1588a74a887d0a8b1daedc8e8944adf9b738e2981528826bd7096` |
| `lifecycle-events-before-relaunch.jsonl` | `64490bca77553841d2c10aad95373fb4eb015045bfd0c476ff609c7cf2cdac9d` |
| `lifecycle-events.jsonl` | `64490bca77553841d2c10aad95373fb4eb015045bfd0c476ff609c7cf2cdac9d` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `f539bb172c92e3e7a1af2fc4b318dfe3dea7bd499aff559d33e1fc0c8d784f9e` |
| `received-otlp.jsonl` | `858189a149e12fc3accb524b588ac6941f199af90bf22b27e1feb3777c9d7a4a` |
| `reconciliation.json` | `2a5cea4feef1596eb6db503a58a1cd7b4fe232eba60a6ea450c6c0771f5ba8ba` |
| `resume-launch.txt` | `0ede33a41345d58c8ee91dc9da53846dc9de2f28c05b07b4dee21b25ca9bc5de` |
| `run-before-relaunch.json` | `e5936a5f4fbf365ba1865417735ab3c50541450b517af007cbd98def897226f8` |
| `run.json` | `e5936a5f4fbf365ba1865417735ab3c50541450b517af007cbd98def897226f8` |
