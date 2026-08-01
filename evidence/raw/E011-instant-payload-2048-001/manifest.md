# E011 instant 2,048-byte payload, attempt 001

- Outcome: Accepted oversized-object loss
- Date: 2026-08-02
- Plan commit: `330beb3`
- Payload metadata commit: `7097952`
- App payload commit: `24c5218`
- Runner commit: `bba1c24`
- Run ID: `00000000-0000-0000-0011-000000000004`
- Persistence: official instant
- Spans / max export batch: 100 / 100
- Payload attribute bytes per span: 2,048

The background event occurred 1.841693952 seconds after ledger commit. Provider
flush reported completion in 49.361041 ms, but no persistence file existed
before or after direct `SIGKILL`. Resume made no HTTP attempt and recovered
0/100 with every sequence missing and no duplicates. Evidence digests remained
stable. This repeats the 1,536-byte oversized-object outcome farther beyond the
boundary.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `dfd5f5288f20efd37c78f8b4e094a40b64db761a632aba526a030e6453264062` |
| `background-boundary-state.tsv` | `4429eeffee40022f1b680ad3d94b4dc56b89b7c53bd64bbec4dbf50b7d17465b` |
| `collector.log` | `d85619015dfcaa365ed4c642f278f211f62eebc98279e7593f83591d3e569aa8` |
| `evidence-digests.tsv` | `4db0d323fa61e9a81df8e7e96809c4b13edf223c8e39601c26f549c2b1f61277` |
| `first-launch.txt` | `6ee373f04772343cfe7b20db09e6c1133f478f379d2954c6747215ba604b7904` |
| `generated-before-relaunch.jsonl` | `3149a3a3da9d2560c0e316867f5e56ed71427144c70f632477f4f013b1ec0d1a` |
| `generated.jsonl` | `3149a3a3da9d2560c0e316867f5e56ed71427144c70f632477f4f013b1ec0d1a` |
| `host-timing.tsv` | `7916913e6243133d3ebe8677196aa49e54f05e328c88f5bf5755437819add627` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `2aa50fb3f6fef2b50263c4e952b1d7f58a2c26b44ff0012cfa30d81812d1511e` |
| `lifecycle-events.jsonl` | `2aa50fb3f6fef2b50263c4e952b1d7f58a2c26b44ff0012cfa30d81812d1511e` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `7d4d46bbfba81251f09150996d625c06a99f8ac729f026d19e3c7c946891fba6` |
| `resume-launch.txt` | `7ea79a0330be3ef0d8d9272441c212977ce9ce6f9afd88c5eb0f2b68e6542d19` |
| `run-before-relaunch.json` | `6a26d23f486db86e05602db80d7c043f5898a865b023c700521e05fe527e6d49` |
| `run.json` | `6a26d23f486db86e05602db80d7c043f5898a865b023c700521e05fe527e6d49` |
