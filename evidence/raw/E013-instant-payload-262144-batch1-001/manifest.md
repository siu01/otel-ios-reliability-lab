# E013 instant 256-KiB single span, attempt 001

- Outcome: Accepted silent-oversize result
- Date: 2026-08-02
- Plan commit: `6eb0975`
- Run ID: `00000000-0000-0000-0013-000000000004`
- Persistence: official instant
- Spans / max export batch: 1 / 1
- Payload attribute bytes: 262,144

The actual background event occurred 2.017518080 seconds after ledger commit,
before the 15-second schedule. Provider flush completed in 51.860083 ms, but no
persistence file became visible before direct `SIGKILL` or after resume.

Neither process made an HTTP attempt, and reconciliation recovered 0/1. The
result matches the default preset and shows that synchronous writer scheduling
does not change the shared single-object limit.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `264b4f07124a1f021bfbfd462187301ccde1b68c3dad18b5ddb3eaea32eac073` |
| `background-boundary-state.tsv` | `e493f04b45d75bf019abec5ee83851d6a6e9c5bee03c12d5de30eb4a3b358b57` |
| `collector.log` | `851f82721e9ee7b0dcdd67e3a9a9f2568d3c5e8ba82c5f7050e10c3d51e5c6bf` |
| `evidence-digests.tsv` | `d61dd4da9498e151f23b104fdb3d3aeaff97be60464ff7142e7ee57d565564ee` |
| `first-launch.txt` | `e2f5646fdda40c791a15d84b3aa7b67ede2de2a2cc78b75fc0b3e598a0e4e122` |
| `generated-before-relaunch.jsonl` | `adc9db50ff728d3e8880cce767b4ef78b332efc266f8185b9dceaff7044c4758` |
| `generated.jsonl` | `adc9db50ff728d3e8880cce767b4ef78b332efc266f8185b9dceaff7044c4758` |
| `host-timing.tsv` | `a6f6f2fdf79ca78a9e4ea00d32cecdc125c9048def9cc381cd65ddd16f372dee` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `0c31abfb6fdab95730419e82ac0619eedc5ee36f8eaa94af8fb70ff330cf9ae0` |
| `lifecycle-events.jsonl` | `0c31abfb6fdab95730419e82ac0619eedc5ee36f8eaa94af8fb70ff330cf9ae0` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `1320aeee931902224d5e7d16854a6ed8b7425bd083d18cb3f8ac1631adb4b04c` |
| `resume-launch.txt` | `660f2700fbbb720b51f887a18a87b11b9329208059ab828b70cfa07676fdd6dc` |
| `run-before-relaunch.json` | `fe0fa279121807069854e54f860c6cc60db9d21e14e04ce0f36b9d10c0e36996` |
| `run.json` | `fe0fa279121807069854e54f860c6cc60db9d21e14e04ce0f36b9d10c0e36996` |
