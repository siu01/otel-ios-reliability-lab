# E012 default 2,048-byte payload with batch 50, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-02
- Plan commit: `e60c6bb`
- Run ID: `00000000-0000-0000-0012-000000000002`
- Persistence: official default
- Spans / max export batch: 100 / 50
- Payload attribute bytes per span: 2,048

The background event occurred 5.759824128 seconds after ledger commit. Provider
flush completed in 123.855625 ms. Two encoded objects fit individually and were
appended to one 316,057-byte file, again demonstrating that total file size may
exceed the separate 256-KiB per-object ceiling.

Resume sent one 234,818-byte request and recovered 100/100 with no duplicates.
This supplies a default-preset intervention comparator for the E011 instant
2,048-byte 0/100 outcome.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `787c7f215812963e3ab886a62589006173f84faeecbc6eb94cd61857b5ca3547` |
| `background-boundary-state.tsv` | `6e9882a0371001b03bcd06fecbeaea061147ef2ac991ab13f29f5c7cb4ff4750` |
| `collector.log` | `5b4444adaeab5c63a9537750d88c3ef2748aec44d92df8dc540fe6965f78a503` |
| `evidence-digests.tsv` | `97782086baba92e01af0f39f9047cd4dfe8d986375045df60a0f05b3f7063a67` |
| `first-launch.txt` | `a175d561d820b7530472189cd9d2d442fc33c4a6db1d5a6c74e2ed3a48c8f496` |
| `generated-before-relaunch.jsonl` | `4a19b36474588a6797d6c3e4f6482da22f6968b86850e0945428683f2bc5499c` |
| `generated.jsonl` | `4a19b36474588a6797d6c3e4f6482da22f6968b86850e0945428683f2bc5499c` |
| `host-timing.tsv` | `2ad63fcb67026cc45c06c97c224bdd6bf03965e8b1470e38bda5b53e4002d973` |
| `http-attempts.jsonl` | `d441bfdc46225b6a40cac323da349707202ee4aaa0b8f5ed5a015544e45e94bc` |
| `lifecycle-events-before-relaunch.jsonl` | `70a3c9198d46f06b688322cc9d464249e0b1ab1d05c38ff64eee048c320e232f` |
| `lifecycle-events.jsonl` | `70a3c9198d46f06b688322cc9d464249e0b1ab1d05c38ff64eee048c320e232f` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `101921eeea591657eaf5fe595b060c907a5a5ca0e93934151da79f917adf8c4a` |
| `received-otlp.jsonl` | `e043ef232118465d326e525f082b109915e6c2b8175af08801d52bbf32ec0120` |
| `reconciliation.json` | `7b08583b692541a063dd7991d37a88fe84e401f31f4e1acba96a51239501c59e` |
| `resume-launch.txt` | `0f727408dcf7c3cf1705de7dc6abcd016869757e30d32bec3877e1e54875e037` |
| `run-before-relaunch.json` | `e128681755a8c52b114b9b71d0dae79588a87cabdbf83f87b0ca1a1abad1c2f4` |
| `run.json` | `e128681755a8c52b114b9b71d0dae79588a87cabdbf83f87b0ca1a1abad1c2f4` |
