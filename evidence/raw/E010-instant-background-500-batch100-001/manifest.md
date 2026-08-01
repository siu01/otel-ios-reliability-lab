# E010 instant 500-span safe-chunk intervention, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-01
- Intervention plan commit: `26fc3b6`
- Run metadata commit: `407c099`
- App intervention commit: `2f79169`
- Runner commit: `78a5855`
- Run ID: `00000000-0000-0000-0010-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Planned spans: 500
- Maximum export batch: 100
- Flush: provider explicit from `scenePhase.background`
- Processor schedule delay: 15,000 ms

## Intervention result

The background event occurred 4.551699712 seconds after generated-ledger commit,
before the schedule boundary. Provider flush completed in 179.997625 ms. Five
100-span persistence objects fit and were appended into one 539,367-byte file
before direct `SIGKILL`; the first process recorded no HTTP attempt.

After resume, one 138,591-byte OTLP request succeeded and recovered all 500
sequences exactly once. This changed the direct E009 instant comparison from
0/500 at batch size 256 to 500/500 at batch size 100 without changing the
persistence preset or adding a post-flush wait.

## Reconciliation

- Unique generated: 500
- Unique received: 500
- Duplicate receipts: 0
- Missing receipts: 0
- Persistence files after termination: 1 (539,367 bytes)
- First-process HTTP records: 0
- Resume HTTP attempts: 1 successful

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `0f98177e13eb574c25a6fc1379d63be95af4b87f829fe014ab09cbbf10580400` |
| `background-boundary-state.tsv` | `b6121068f502fc9e96af7ce0a8f601d60b9a13f7f90652f419d0c26303e329e6` |
| `collector.log` | `a2411630593e207eca4d595198a7a4a08660741865c1da3a060e7aa23949efd7` |
| `evidence-digests.tsv` | `bf973662d90d8b532f6a357782ada01500a45eb7fdf94383a7cefa9c27e5944d` |
| `first-launch.txt` | `72bbcc1bc1c418ecaa2e696097704f5592a2fd4176b5934067e97ae3aa54063f` |
| `generated-before-relaunch.jsonl` | `5097891c1be07fa3d372de4a0114fc2c476e7fcb69f1c7bdad1c96f854eac818` |
| `generated.jsonl` | `5097891c1be07fa3d372de4a0114fc2c476e7fcb69f1c7bdad1c96f854eac818` |
| `host-timing.tsv` | `47a7fb0e28aa42082b57b54ac6efe5f18eccf52a30b3b642f36c665fdbcfabdb` |
| `http-attempts.jsonl` | `eb6467786c113cea24b95ffedbd7007cb2bc6ca4e87e9b048f3cfd290343a997` |
| `lifecycle-events-before-relaunch.jsonl` | `f49b2847c83f70d5e74be03f365d3d789fee170e8077513db4b589e637026861` |
| `lifecycle-events.jsonl` | `f49b2847c83f70d5e74be03f365d3d789fee170e8077513db4b589e637026861` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `47e9d380aaaed4bab5e2547ce88a9e7656dcf1747727c8e106d098b9e0c12455` |
| `received-otlp.jsonl` | `8c79b838510aeeada5f0d8415d10fcd92d24ac5b489aa6e3b855ada48ea63a43` |
| `reconciliation.json` | `d36095857240faa3fd505ee35594f23da80770877c5f82df0c026349d97f5d2e` |
| `resume-launch.txt` | `908ee6d5f79363edfd0a19f8835226c317889d45249e37f4c6c4d4dfcebc4465` |
| `run-before-relaunch.json` | `0336fc2c7475f90162b35ce9defe5536df518ea5708248bfa1157c8852973285` |
| `run.json` | `0336fc2c7475f90162b35ce9defe5536df518ea5708248bfa1157c8852973285` |
