# E013 instant 240-KiB single span, attempt 001

- Outcome: Accepted boundary-inside control
- Date: 2026-08-02
- Plan commit: `6eb0975`
- Run ID: `00000000-0000-0000-0013-000000000003`
- Persistence: official instant
- Spans / max export batch: 1 / 1
- Payload attribute bytes: 245,760

The actual background event occurred 1.953165056 seconds after ledger commit,
before the 15-second schedule. Provider flush completed in 83.682625 ms and
made one 246,876-byte persistence file visible before direct `SIGKILL`.

Resume sent one 246,280-byte request and recovered the single expected span
exactly once. The result matches the default boundary-inside control despite
the preset's writer scheduling difference.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `1dd010874658bf1dc760f23ba0b2648774e2a5375d269614410234e8b9a870ee` |
| `background-boundary-state.tsv` | `be498918065cbf39e782a4d3eab0ed3d22baf552a7839afd9d5e0877cc9936bb` |
| `collector.log` | `4b58fcbd396c13d7bb12a12f70e5e075cfe2b35fedc585e9b3ff468a7dc4062d` |
| `evidence-digests.tsv` | `9151fdf8ff9326439984275ac983168fd51543dc9788a1910c66b84a82688bf0` |
| `first-launch.txt` | `cb8e7f96430de01d012f9d17148e747c29aafceafb6582f824e3b879bbe4c9b5` |
| `generated-before-relaunch.jsonl` | `1c25662c8599b328ac62077c29ff3ba0956e19e177738e2ed60c2c103bda2ce3` |
| `generated.jsonl` | `1c25662c8599b328ac62077c29ff3ba0956e19e177738e2ed60c2c103bda2ce3` |
| `host-timing.tsv` | `24ea3cc5d26200ecdc50b967f598b513b2c63b635a41005d72b268396f25179c` |
| `http-attempts.jsonl` | `fdee8cc9f90f39126fd91de717f434d949a435ef58b1f826200235d3f14801d8` |
| `lifecycle-events-before-relaunch.jsonl` | `60cad23e1f84aaae3a90fa1ceb7400901eaff0cea0c79f5088cc1fd4e27340c8` |
| `lifecycle-events.jsonl` | `60cad23e1f84aaae3a90fa1ceb7400901eaff0cea0c79f5088cc1fd4e27340c8` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `ebe53cb164f232623ffa1c4e2712ffa463780b624bf1d205d2e34e00a25f3ff1` |
| `received-otlp.jsonl` | `80eb5ed9d31a0420f0dc9392fc825c304f73aac7535674c771052048377594e6` |
| `reconciliation.json` | `b811cb79d568354e31080050ae8e6c840ad2de2ab283c8b0d28ce5351b1db4b8` |
| `resume-launch.txt` | `aed15428ff11793f0e9d01d3dd1199bfc71d63a7a2c21a322576188f4560f7c9` |
| `run-before-relaunch.json` | `94669a22311ccbf93644959b982cbb8cf88ace5abeee11f3fe476463c7e6ee6e` |
| `run.json` | `94669a22311ccbf93644959b982cbb8cf88ace5abeee11f3fe476463c7e6ee6e` |
