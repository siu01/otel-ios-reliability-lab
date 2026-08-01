# E008 instant background transition without flush, attempt 001

- Outcome: Accepted total-loss preset control
- Date: 2026-08-01
- Background implementation commits: `dd022d6`, `1dc0edd`
- Host runner commit: `a49fa57`
- Plan commit: `353a963`
- Run ID: `00000000-0000-0000-0008-000000000002`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Flush: disabled; trigger recorded as background
- Batch schedule delay: 5,000 ms
- Background initiator: Mobile Safari launch
- Stop: direct `SIGKILL` after observing `scenePhase.background`

## Lifecycle observation

The generated ledger was observed at 14:07:21.948Z. Mobile Safari launch
returned at 14:07:22.328Z, and the host observed the app's background event at
14:07:23.666Z. The app timestamps place `backgroundObserved` about 1.74 seconds
after generated-ledger commit, before the five-second processor schedule.

The lifecycle sequence contains generated-ledger commit, burst completion, and
background observation with no flush. No persistence file existed before or
after termination. Resume made no HTTP attempt and recovered zero spans.
Generated, run, and lifecycle evidence stayed byte-identical.

This matches the default no-flush control. Instant's synchronous writer cannot
protect spans while they remain upstream of the persistence exporter.

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
| `background-app-launch.txt` | `5749a79689eb59dee3e0951c90e12b64c85e124d8d163a4efe8495207cc41a66` |
| `background-boundary-state.tsv` | `e280578f75125b16aa6c79a112a3946dfe01fd730ae78c5192a96ad139525c73` |
| `collector.log` | `a0a0c71c1b22e609aad46b3c480d480420e8173222a1aef4394cc2736fa7e239` |
| `evidence-digests.tsv` | `b313ab788ddc6fb983225fc0efcd9e40e59c065317f3e8e8c5df75656fd59100` |
| `first-launch.txt` | `021d8b0f779509d9430e4aed7bcfb165078b17db0e9f295335f53eeba875873b` |
| `generated-before-relaunch.jsonl` | `ba088e770afd46139c287ee215fefd3573015a38d59b9fbbfc564a960e876633` |
| `generated.jsonl` | `ba088e770afd46139c287ee215fefd3573015a38d59b9fbbfc564a960e876633` |
| `host-timing.tsv` | `616cbdd0d9b94afee3ff4670566b90806672abd28dfe14e9dc47acda5ec1845a` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `98ee94106b568b2edc441f256e9ca02af184a27d6b3db4bb1036b2f2e2e7783a` |
| `lifecycle-events.jsonl` | `98ee94106b568b2edc441f256e9ca02af184a27d6b3db4bb1036b2f2e2e7783a` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `e9a6693a777bc28df853f0e391da105bfc7c4c86dcfffd932c1505279d9fcfc3` |
| `resume-launch.txt` | `ba6397c6a4885217d2d15982ca1e34e508206598f29d27d2f6ea69c0a5472acc` |
| `run-before-relaunch.json` | `7f6a190a3e1d088a979cbf9e8b857f4699f6b0f084c65f1879e8509c53fccd8b` |
| `run.json` | `7f6a190a3e1d088a979cbf9e8b857f4699f6b0f084c65f1879e8509c53fccd8b` |
