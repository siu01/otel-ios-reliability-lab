# E008 instant background transition with provider flush, attempt 001

- Outcome: Accepted complete-recovery lifecycle intervention
- Date: 2026-08-01
- Background implementation commits: `dd022d6`, `1dc0edd`
- Host runner commit: `a49fa57`
- Plan commit: `353a963`
- Run ID: `00000000-0000-0000-0008-000000000004`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 5,000 ms
- Background initiator: Mobile Safari launch
- Stop: direct `SIGKILL` after observing flush completion

## Lifecycle observation

The generated ledger was observed at 14:12:10.529Z. Mobile Safari launch
returned at 14:12:11.025Z, and the host observed the app's background event at
14:12:12.375Z. App timestamps place `backgroundObserved` about 1.87 seconds
after generated-ledger commit, before the five-second processor schedule.

The provider flush completed in 51.393083 milliseconds. A 107,797-byte
persistence file was already visible before termination was requested, and the
first process made no HTTP request. After resume with the Collector available,
one 27,818-byte OTLP request succeeded and all 100 spans were reconciled.
Generated, run, and lifecycle evidence stayed byte-identical across resume.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1
- First-process HTTP attempts: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `df7ef724f1a4cf5a7ed7f26fc86ca25fef34e61687f19a9721c948eb575536fb` |
| `background-boundary-state.tsv` | `9cca6218e92fb9701f9e7450b32706d57782e26b1c9fabbb629287eee4e48677` |
| `collector.log` | `86e83521b9d2cb653e92a65d2a021ed4add5ca894437ba33c49d2a945003622e` |
| `evidence-digests.tsv` | `9d4ee73bf6c836d1d561ff6a8166a76e097c9bc33ffe1d82dcc6b3be6d3a4777` |
| `first-launch.txt` | `8d08c4400fd1c8dc85efa4893597c7d5b3c5eff66ed524ef09c72a2cc3b704d8` |
| `generated-before-relaunch.jsonl` | `49f7a5019dca4cdce6503216ffb49c4dbe3e2c69840716dd985f62b48269242a` |
| `generated.jsonl` | `49f7a5019dca4cdce6503216ffb49c4dbe3e2c69840716dd985f62b48269242a` |
| `host-timing.tsv` | `54587360f198599a7af0b8b4eefa11f90f403748d4649f431370e1344ed637f0` |
| `http-attempts.jsonl` | `637512bc5992a432bf529b9fe613be3ac77da73554c5b5a9eb846a8627733b2a` |
| `lifecycle-events-before-relaunch.jsonl` | `0e73eae786f74a9826cd58d245db97bd300e365db3ab35f0ff28e762fa4a2b78` |
| `lifecycle-events.jsonl` | `0e73eae786f74a9826cd58d245db97bd300e365db3ab35f0ff28e762fa4a2b78` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `ab040c391134d09ee251d2cf35c6495f955c6429d1a948feb02d27592838447b` |
| `received-otlp.jsonl` | `8ba5a48feaf785996ea0d2b22ef6fba3fc7b658185cec8e2e2f92f524488aafc` |
| `reconciliation.json` | `777ae3b974bee4b6b927bd234c7f76aec113cad62f13993237d16db3ecc49049` |
| `resume-launch.txt` | `b919bbe9fa53da779dc68cca1010b1e8eb431472615b163e69375b143b62cf6b` |
| `run-before-relaunch.json` | `11c96ee274752a8b5f9132058c4dae2e23638b39e057b01131a0c83e39030a1b` |
| `run.json` | `11c96ee274752a8b5f9132058c4dae2e23638b39e057b01131a0c83e39030a1b` |
