# E013 instant 300-KiB single span, attempt 001

- Outcome: Accepted oversize replication
- Date: 2026-08-02
- Plan commit: `6eb0975`
- Run ID: `00000000-0000-0000-0013-000000000005`
- Persistence: official instant
- Spans / max export batch: 1 / 1
- Payload attribute bytes: 307,200

The actual background event occurred 3.043308032 seconds after ledger commit,
before the 15-second schedule. Provider flush completed in 83.031959 ms, but no
persistence file became visible before direct `SIGKILL` or after resume.

Neither process made an HTTP attempt, and reconciliation recovered 0/1. The
300-KiB condition replicates the 256-KiB outcome away from the equality edge,
confirming an oversize region rather than a one-value anomaly.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `28dab32a3bb2c3c463a26c961789ac22be014cdd5012ca7c2ba76b6d3829a716` |
| `background-boundary-state.tsv` | `e03c7e9b7694dab94531fac3d89c5bf3d6ddf5b3e0fd3ecae618cff59c2658b5` |
| `collector.log` | `51304a99877545b142b612daa95e0c83216dbec73ebab09c7f8f70025d05e7e5` |
| `evidence-digests.tsv` | `70e44e8b27f04761522f4193b73c2d9d74d88a815cba1365fb75a721407a70e2` |
| `first-launch.txt` | `18d6e48e7f54ef6cff121a99ef450b4836d2db6a706d6380703f03e9b0b5915c` |
| `generated-before-relaunch.jsonl` | `3f813d62911aaa8875be36d53e403bc91057d9e4d315468c5e19fb86645fee5e` |
| `generated.jsonl` | `3f813d62911aaa8875be36d53e403bc91057d9e4d315468c5e19fb86645fee5e` |
| `host-timing.tsv` | `ada8b5b93d4514e1380561cd98b90bcf55a29b03c5f222d93182bd18259cd7ae` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `ea36b5644fd5f259b6c3eb2d5a7d9936683cd365d87e6f51aabc4d75bb8d6a66` |
| `lifecycle-events.jsonl` | `ea36b5644fd5f259b6c3eb2d5a7d9936683cd365d87e6f51aabc4d75bb8d6a66` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `f19db8cc0c1821d3eca0bbc2afdc99a3dbd6de7086faaabbd6158d773f13d42c` |
| `resume-launch.txt` | `68cf524bd06a01bb3a6613efc59fe58ec2ea399214c928af448065333ae51aa4` |
| `run-before-relaunch.json` | `44702a01945f620df7073e71039058002e3a464005d74f939e71c702ab32f862` |
| `run.json` | `44702a01945f620df7073e71039058002e3a464005d74f939e71c702ab32f862` |
