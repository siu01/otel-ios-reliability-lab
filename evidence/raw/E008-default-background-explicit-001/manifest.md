# E008 default background transition with provider flush, attempt 001

- Outcome: Accepted complete-recovery lifecycle intervention
- Date: 2026-08-01
- Background implementation commits: `dd022d6`, `1dc0edd`
- Host runner commit: `a49fa57`
- Plan commit: `353a963`
- Run ID: `00000000-0000-0000-0008-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 5,000 ms
- Background initiator: Mobile Safari launch
- Stop: direct `SIGKILL` after observing flush completion

## Lifecycle observation

The generated ledger was observed at 14:10:12.353Z. Mobile Safari launch
returned at 14:10:12.887Z, and the host observed the app's background event at
14:10:14.171Z. App timestamps place `backgroundObserved` about 1.87 seconds
after generated-ledger commit, before the five-second processor schedule.

The provider flush completed in 45.323542 milliseconds. A 107,782-byte
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
| `background-app-launch.txt` | `8cd699189e993df33ab1db69b207a5155c1a853d7ce295837fdba08270c70ba0` |
| `background-boundary-state.tsv` | `9cfa37e4d1bfea98035b2d31c49d0558d801b2452db4807931279024ef12429f` |
| `collector.log` | `8bb70b6190e995ac7295d48801df566c9882d167e74cfa31a2f07e8a90ce50cd` |
| `evidence-digests.tsv` | `9d094e9bf2c59205ed78a45ca13fce6731070bc8724418d18dc90b18a461a27c` |
| `first-launch.txt` | `c1341af1887bc9128d0395ea0d013f3272c25b54f786fac82755a1c5b2e081c6` |
| `generated-before-relaunch.jsonl` | `18bc9d8130ddddbff24a8bea4eca6cc00d307b431f8e3d577052cbc53e7c93e1` |
| `generated.jsonl` | `18bc9d8130ddddbff24a8bea4eca6cc00d307b431f8e3d577052cbc53e7c93e1` |
| `host-timing.tsv` | `c28768723c507b418f66a154386d08d34cf95483510735f459f8fdce4145c4b3` |
| `http-attempts.jsonl` | `003bc5f66a74f3e2433f3da5d8f1609bd26e4c4b106f3096c19d8da303cfe02d` |
| `lifecycle-events-before-relaunch.jsonl` | `71e75d16f05e1cf5cc7c46c219bbfeef2f9530344d6629d24033ae231b57829c` |
| `lifecycle-events.jsonl` | `71e75d16f05e1cf5cc7c46c219bbfeef2f9530344d6629d24033ae231b57829c` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `d55906c6743bec16272b5c487143fc2fec2a86d64c7b2b35ce3c59f90ccd8af6` |
| `received-otlp.jsonl` | `bfc2220e9f3980a763c3fca3116ed8abea286810913bfa7c7a795dbba157e0b8` |
| `reconciliation.json` | `016aafdadde78bcc153f4ebcd9f481eca4a8fcb44e93a89ae6b8bfcebe5415c4` |
| `resume-launch.txt` | `5e122cae5dd09f2da5b64d7b551fd941e27ea59ae48384db499852f02f34e29b` |
| `run-before-relaunch.json` | `7ee19ecc345bb19b0a8abb4d1942811746be95e611d89fa7a1464399e5af566d` |
| `run.json` | `7ee19ecc345bb19b0a8abb4d1942811746be95e611d89fa7a1464399e5af566d` |
