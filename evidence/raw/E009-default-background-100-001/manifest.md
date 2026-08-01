# E009 default 100-span background scale, attempt 001

- Outcome: Preserved but excluded lifecycle-timing calibration
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Parameterized runner commit: `6397265`
- Run ID: `00000000-0000-0000-0009-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 100
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 5,000 ms

## Exclusion reason

The app timestamp for `backgroundObserved` was 6.299076864 seconds after
generated-ledger commit. This exceeded the registered five-second processor
schedule. The host requested Mobile Safari 15 ms after observing the ledger,
but the Simulator did not deliver the background event until 6.16 seconds after
that request.

The provider flush then completed in only 2.766708 ms and a persistence file
was visible before stop. Those observations are compatible with scheduled
export having already drained the upstream batch. The run therefore cannot
measure the registered background intervention and is excluded from the scale
comparison under the preregistered rule.

The outcome is not deleted: after direct `SIGKILL`, resume sent one 27,818-byte
request and reconciled 100/100 with no duplicates. This is a valid delivery
observation but not evidence for background-flush cost.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1 (107,760 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `79ed27f2c6675870c784e5f8511304ada12c8f2353d377800c5596961edd0708` |
| `background-boundary-state.tsv` | `30cc04cd637d03065e3f44ced321c06090a11955dde0adc575f10a6f302efa18` |
| `collector.log` | `c68fedf4d0a5b1362fc5e484b7a9fec7b14667f3e1343caf057ee020fff362a8` |
| `evidence-digests.tsv` | `8adabea63ad6ff2801eba3d176acb7cd3033850293fb2e9bed56f429a6c2128b` |
| `first-launch.txt` | `65fd2b6d5290f390322d54c9e2825c7fd57c12fc6d4df9afd8a0374edcdf3afc` |
| `generated-before-relaunch.jsonl` | `79dfbea3c63d7a01547022654cc16f00204bd6672e04c3a16851d90d81e10187` |
| `generated.jsonl` | `79dfbea3c63d7a01547022654cc16f00204bd6672e04c3a16851d90d81e10187` |
| `host-timing.tsv` | `d5cd4830ac67f4764091d8ac17847341929f12dd086d2d6c3779cefbb579296b` |
| `http-attempts.jsonl` | `84cc64f739ae7af4af751fd6ee6836cb1c8c78395edd55a915b61e65fb44db72` |
| `lifecycle-events-before-relaunch.jsonl` | `41f87fe7871d2fddd36ffe3dab06d89ff6c05fe793cc8677baa9590c8184c82f` |
| `lifecycle-events.jsonl` | `41f87fe7871d2fddd36ffe3dab06d89ff6c05fe793cc8677baa9590c8184c82f` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `ff94ab085f5f34b2ee71a93d347eacbcf0f14350a2ab08278e223c09f9489d6c` |
| `received-otlp.jsonl` | `5691cf930fda7b38efaa33657d10183528d39b5f7db37cf94a01d9edb78bb222` |
| `reconciliation.json` | `7f02d3b58ab5ff5578d45f01586a5c951d5651a2840043a6bd3e7616815a7b50` |
| `resume-launch.txt` | `ea1cddba0365f56ad78fa0f027d04c6fcea90643c2ff22a02c5fac47cebc2667` |
| `run-before-relaunch.json` | `55fe6bd607f97f93f3579701e01cfbc0abd27d005f0c18b79cbe1cbff0512eed` |
| `run.json` | `55fe6bd607f97f93f3579701e01cfbc0abd27d005f0c18b79cbe1cbff0512eed` |
