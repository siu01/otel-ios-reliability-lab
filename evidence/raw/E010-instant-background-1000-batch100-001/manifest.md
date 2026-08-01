# E010 instant 1,000-span safe-chunk intervention, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-01
- Intervention plan commit: `26fc3b6`
- Run metadata commit: `407c099`
- App intervention commit: `2f79169`
- Runner commit: `78a5855`
- Run ID: `00000000-0000-0000-0010-000000000004`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Planned spans: 1,000
- Maximum export batch: 100
- Flush: provider explicit from `scenePhase.background`
- Processor schedule delay: 15,000 ms

## Intervention result

The background event occurred 2.932535296 seconds after generated-ledger commit,
before the schedule boundary. Provider flush completed in 80.466333 ms. Ten
100-span persistence objects fit and were appended into one 1,078,999-byte file
before direct `SIGKILL`; the first process recorded no HTTP attempt.

After resume, one 277,091-byte OTLP request succeeded and recovered all 1,000
sequences exactly once. This changed the direct E009 instant comparison from
232/1,000 at batch size 256 to 1,000/1,000 at batch size 100 without changing
the persistence preset or adding a post-flush wait.

## Reconciliation

- Unique generated: 1,000
- Unique received: 1,000
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1 (1,078,999 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `0f7b329e6f64d2ba2a899c65465b345f8c5503349a0d9221716457b05de8d9ec` |
| `background-boundary-state.tsv` | `de0b4c00a54ccf019483e1975a8864b779e3056fc2c5eef86527b7acb49802ae` |
| `collector.log` | `d50b894eb6e671e0fd8652bcdb58d86f438571b9d86540c56b5b1e30841eab16` |
| `evidence-digests.tsv` | `8158cf6894c8b183296105c4a364d5f0419d5c4d65f190aaf48156eead6d2c43` |
| `first-launch.txt` | `fa74d9fd3817371426458b46ee33ddb0c41cc9679267e5e3705a151e6f3b535f` |
| `generated-before-relaunch.jsonl` | `1a77f2ffe880730b898cba9c5937a1b7645a0ef6afa91adefd8c744244fba86a` |
| `generated.jsonl` | `1a77f2ffe880730b898cba9c5937a1b7645a0ef6afa91adefd8c744244fba86a` |
| `host-timing.tsv` | `9f1f36bb29d60e96d7ec19ecaab45a2a3004798f750793d7feb92cc9855a72ba` |
| `http-attempts.jsonl` | `84e625abcb2a0f15fcf344fbc94104935331c4c6c299a62c8db5bcee93233305` |
| `lifecycle-events-before-relaunch.jsonl` | `661f6bb3a37d9c765f0dff42069d000ef28de741de805a6a1a9049b9669c4b7d` |
| `lifecycle-events.jsonl` | `661f6bb3a37d9c765f0dff42069d000ef28de741de805a6a1a9049b9669c4b7d` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `55d17cd94fc1e0ced4bca4b7caa55a2717c7481e851ab8ccd000e710567bcc3e` |
| `received-otlp.jsonl` | `ec855850fa5d3228ddd995995755993f27b315b5abc4d11fee27a0ec35be8dcc` |
| `reconciliation.json` | `6eb468c3422b6dab1c431b4b74c9f3784ffd1c0c6629adf81d02fd5ecf563c07` |
| `resume-launch.txt` | `c860e9e84c9b8c7063dac9883d46a53a0be0ffdf485a5322782df5f791b3c357` |
| `run-before-relaunch.json` | `94eedb8cbfffd09c6d357068b8c09156cc43423112ecb82956b1dea1d44a149b` |
| `run.json` | `94eedb8cbfffd09c6d357068b8c09156cc43423112ecb82956b1dea1d44a149b` |
