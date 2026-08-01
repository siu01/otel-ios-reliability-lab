# E010 default 500-span safe-chunk intervention, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-01
- Intervention plan commit: `26fc3b6`
- Run metadata commit: `407c099`
- App intervention commit: `2f79169`
- Runner commit: `78a5855`
- Run ID: `00000000-0000-0000-0010-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 500
- Maximum export batch: 100
- Flush: provider explicit from `scenePhase.background`
- Processor schedule delay: 15,000 ms

## Intervention result

The background event occurred 6.495515648 seconds after generated-ledger commit,
before the schedule boundary. Provider flush completed in 147.756708 ms. Five
100-span persistence objects fit and were appended into one 539,314-byte file
before direct `SIGKILL`; the first process recorded no HTTP attempt.

After resume, one 138,591-byte OTLP request succeeded and recovered all 500
sequences exactly once. This changed the direct E009 default comparison from
0/500 at batch size 256 to 500/500 at batch size 100 without changing the
persistence preset or adding a post-flush wait.

## Reconciliation

- Unique generated: 500
- Unique received: 500
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1 (539,314 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `fa719389e9f1f59004d030d4968e73de22edb1b940e71ff6a19e5779b6a209e6` |
| `background-boundary-state.tsv` | `993daeb0c7c86d62f02fc4cff30a7a6f003b06992821af0e682d09c3e256f86a` |
| `collector.log` | `2b16a3fd6c20e1811ff1d32ed6638349318b214ff7d0ab9cf7157a6786f77ef9` |
| `evidence-digests.tsv` | `694813d0f938920a9771d438cc6537ca78861b4a7ec404d3889ebef2ed3a7607` |
| `first-launch.txt` | `5e889a7ebe09ba1a4fa9286278b74ee0f88f99875cdb15989215cc70130ea12e` |
| `generated-before-relaunch.jsonl` | `b136f5de8b8c699a9f627986905abfdb6b7a1dab230fb1a7e005334e927803c9` |
| `generated.jsonl` | `b136f5de8b8c699a9f627986905abfdb6b7a1dab230fb1a7e005334e927803c9` |
| `host-timing.tsv` | `6611a62c7830ca9a31fb2e7dd8f20c88270fc05bd6df4d35e80e022c75343f97` |
| `http-attempts.jsonl` | `9b764d4362183dbf8de6fee61fb05c06be0cf9e5b96e2b4329a4f21c548886e7` |
| `lifecycle-events-before-relaunch.jsonl` | `3abf12ff3afe348640c5742f3a6bf301951502f77b8e85b9c5c7b1b837c6a55c` |
| `lifecycle-events.jsonl` | `3abf12ff3afe348640c5742f3a6bf301951502f77b8e85b9c5c7b1b837c6a55c` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `8496d16a8b4d840a04def0392db4803267f99722e21bc841824f816add68daa7` |
| `received-otlp.jsonl` | `76288d48f0e20365279ea9e12750186bd7a972a685cf31f14250603f143ceff0` |
| `reconciliation.json` | `beda4b9c662ccb46648ac7449c919fd5d1c50508b011264990d1fa20ff3e343b` |
| `resume-launch.txt` | `d722c3a1c21d46337219a32b3191d80030541e56acf4fd2f6a113ed68b5942fb` |
| `run-before-relaunch.json` | `ca99c5a5202d373c52983906ccce66c1e338c7619f32763144c0b59374c1d73b` |
| `run.json` | `ca99c5a5202d373c52983906ccce66c1e338c7619f32763144c0b59374c1d73b` |
