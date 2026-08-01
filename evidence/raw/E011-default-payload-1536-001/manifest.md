# E011 default 1,536-byte payload, attempt 001

- Outcome: Accepted oversized-object preset comparison
- Date: 2026-08-02
- Plan commit: `330beb3`
- Payload metadata commit: `7097952`
- App payload commit: `24c5218`
- Runner commit: `bba1c24`
- Run ID: `00000000-0000-0000-0011-000000000006`
- Persistence: official default
- Spans / max export batch: 100 / 100
- Payload attribute bytes per span: 1,536

The background event occurred 1.918135040 seconds after ledger commit. Provider
flush reported completion in 49.039000 ms, but no persistence file existed
before or after direct `SIGKILL`. Resume made no HTTP attempt and recovered
0/100 with every sequence missing and no duplicates. Evidence digests remained
stable. This matches the instant 1,536-byte loss and confirms the shared byte
boundary across presets.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `77de248c67867af68c99ca00ea94fb14c58d56b6d09d93c018bacf51d251856e` |
| `background-boundary-state.tsv` | `6f688868042127a5b1524bb4b5a1dceab99c5c52e692617726508006a4bb40cc` |
| `collector.log` | `88c58b7bbebde45cf3e17848eb5f57b63d311f0738764744ddcc0ab34029504b` |
| `evidence-digests.tsv` | `13b9a312ee158decad056d540b6b22a825ac5d113faddd49ae5a691a79daba9d` |
| `first-launch.txt` | `31d4665a374cec5f61e081af4948c882090baef9566fed0a0aa04c05ae8396fa` |
| `generated-before-relaunch.jsonl` | `1b92e8aa028ba72f7356d99537405ea7ecea0a87226e2c266b0f768cdcaf49c6` |
| `generated.jsonl` | `1b92e8aa028ba72f7356d99537405ea7ecea0a87226e2c266b0f768cdcaf49c6` |
| `host-timing.tsv` | `b84db666cb1ac47ba7f53cd0e666bcba0c2f4a6c41a2603ce5857fea176f3937` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `b325852f895ac6c4c92ab8e4da7364caf022eaf9df6ef7d935d9ce8e627115e6` |
| `lifecycle-events.jsonl` | `b325852f895ac6c4c92ab8e4da7364caf022eaf9df6ef7d935d9ce8e627115e6` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `a94a6fd53b909b3073b70c5dbb6bceb8bb3d5515f2d1438ffef3de5e82fd1d75` |
| `resume-launch.txt` | `5250005c9b379033848adeb1e5405cdac85655fb8a12d3f3e71330483dee0d61` |
| `run-before-relaunch.json` | `652ed2025ec487b34f383fe3338fb438180f6672a30bf09e2d8a43f70de796cb` |
| `run.json` | `652ed2025ec487b34f383fe3338fb438180f6672a30bf09e2d8a43f70de796cb` |
