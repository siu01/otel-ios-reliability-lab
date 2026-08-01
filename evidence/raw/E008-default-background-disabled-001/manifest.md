# E008 default background transition without flush, attempt 001

- Outcome: Accepted total-loss lifecycle control
- Date: 2026-08-01
- Background implementation commits: `dd022d6`, `1dc0edd`
- Host runner commit: `a49fa57`
- Plan commit: `353a963`
- Run ID: `00000000-0000-0000-0008-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Flush: disabled; trigger recorded as background
- Batch schedule delay: 5,000 ms
- Background initiator: Mobile Safari launch
- Stop: direct `SIGKILL` after observing `scenePhase.background`

## Lifecycle observation

The generated ledger was observed at 14:05:25.459Z. Mobile Safari launch was
requested six milliseconds later and returned at 14:05:25.867Z. The app wrote
`backgroundObserved` at Unix nanoseconds 1785593127970524928; the host observed
it at 14:05:27.997Z and requested the signal 94 milliseconds later.

The app lifecycle file contains generated-ledger commit, burst completion, and
background observation in order, with no flush events. The background event was
about 2.56 seconds after generated-ledger commit, still before the registered
five-second processor schedule.

No persistence file existed before or after termination. Resume made no HTTP
attempt and recovered zero spans. Generated, run, and lifecycle evidence stayed
byte-identical across resume.

## Reconciliation

- Unique generated: 100
- Unique received: 0
- Duplicate receipts: 0
- Missing receipts: 100
- Persistence files after termination and resume: 0
- HTTP attempts: 0

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `da3945b92542367caabbb3d1b933386923fca05660b55b855445215ba717931e` |
| `background-boundary-state.tsv` | `cf20e3310cb0e95a2e15f215406808b05473cf41c80ba030a2a2a730acccdc04` |
| `collector.log` | `b24a9629e203ae97a88e8648e7d962ee34ce3e2ec6aab31a4eb6422ea2f668f6` |
| `evidence-digests.tsv` | `7498ff4cc0a7087c9660bea2498210b45b54873bd7ae019a52607e0056bf2d00` |
| `first-launch.txt` | `07c81dcc9217c4282e843002f5b244095a299a3ee1ea9d3b4c5472936de68e77` |
| `generated-before-relaunch.jsonl` | `119ca341566d8d7381442aa8ebd41e605db869e1fa0166818958863c0b92f4bc` |
| `generated.jsonl` | `119ca341566d8d7381442aa8ebd41e605db869e1fa0166818958863c0b92f4bc` |
| `host-timing.tsv` | `48c19f513f4a939108210e0f5faa748cba643fe1df8f88608370a0ef6cc24123` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `0aa2b3d31951576753c50d90d9c242d9526ec9e7f6d5cd587ee26a4810c4d9d9` |
| `lifecycle-events.jsonl` | `0aa2b3d31951576753c50d90d9c242d9526ec9e7f6d5cd587ee26a4810c4d9d9` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `21365459809e1a8ff40aacd008ab039cf12e9f34a39b47e6a0efc7e69e290159` |
| `resume-launch.txt` | `2e1ba2671517cd4e3b7f1240d0a2a0b901be43b8104f1e954a1d6ea31adbf812` |
| `run-before-relaunch.json` | `2904d565d523ee5a0d076ebe52482f4ffe1955565c70059ceda51e3068638747` |
| `run.json` | `2904d565d523ee5a0d076ebe52482f4ffe1955565c70059ceda51e3068638747` |
