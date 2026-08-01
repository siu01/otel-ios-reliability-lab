# E013 default 240-KiB single span, attempt 001

- Outcome: Accepted boundary-inside control
- Date: 2026-08-02
- Plan commit: `6eb0975`
- Run ID: `00000000-0000-0000-0013-000000000001`
- Persistence: official default
- Spans / max export batch: 1 / 1
- Payload attribute bytes: 245,760

The actual background event occurred 3.833817088 seconds after ledger commit,
before the 15-second schedule. Provider flush completed in 113.024041 ms and
made one 246,874-byte persistence file visible before direct `SIGKILL`.

Resume sent one 246,280-byte request and recovered the single expected span
exactly once. This is the registered boundary-inside control for the 256-KiB and
300-KiB single-span conditions.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `5dbd246733062e22dc923579bc893da7f839c8a80bd02453568f672f65645e86` |
| `background-boundary-state.tsv` | `797e2c375d4f336d50b0952d7cf024badca2e283959524c5e7a4e84647a293e9` |
| `collector.log` | `88c979049a3abbd1014506dfdf624e3a90bf02ca2cdd5b33f5e0aafd7efaef09` |
| `evidence-digests.tsv` | `107a3607d242dedff65fab561f7b4bee5bb840a1a5e3135776eddcb07f38036f` |
| `first-launch.txt` | `61d5bfc3715e98077d709cf75bbe86ebd57484e99edcb2892498858b5dc310a5` |
| `generated-before-relaunch.jsonl` | `dff06d17441a6b634275ffb19a686e2357c779792fea8474ac31a4e393ca128d` |
| `generated.jsonl` | `dff06d17441a6b634275ffb19a686e2357c779792fea8474ac31a4e393ca128d` |
| `host-timing.tsv` | `4bb7b9c2f1bad1c5f6f9268a1778aa277a62b6c559a6a9e6fb49a6c6ffd9a7a1` |
| `http-attempts.jsonl` | `76da68bfc72bd215b65a35e4df2d5e84fc0d4784e3fdd9eb8f87b8b53feffaa3` |
| `lifecycle-events-before-relaunch.jsonl` | `e695a2fe63bb0754b51f0970c33e0fbc967dc17bd72f5ba9e84909357e9c2195` |
| `lifecycle-events.jsonl` | `e695a2fe63bb0754b51f0970c33e0fbc967dc17bd72f5ba9e84909357e9c2195` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `791c8d9ad55cf9a2002573695bff7c15aaff4999f6a306a30a9cf1208a3b30a5` |
| `received-otlp.jsonl` | `4ed79d666c1dffbf4c480338c2c6c8c50df574dbd5ed2a1a16410f49089f2ab5` |
| `reconciliation.json` | `42bbbe210cd52bae52c2a6a3b4e12031763bdbc410f4306de9ff6e6690a0c116` |
| `resume-launch.txt` | `a16b909555a80524e3c78b43fded61c185d4fefbc71de494dccbcf00e75498ed` |
| `run-before-relaunch.json` | `66f8d12dd8be78c17d2fc5128c71be2a6ade4b5a63e3470e0c88faf98cbda32e` |
| `run.json` | `66f8d12dd8be78c17d2fc5128c71be2a6ade4b5a63e3470e0c88faf98cbda32e` |
