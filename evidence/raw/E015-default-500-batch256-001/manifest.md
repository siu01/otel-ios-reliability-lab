# E015 default 500-span binary search, attempt 001

- Outcome: Accepted exact and faster intervention
- Date: 2026-08-02
- Plan commit: `2bcbbc5`
- Run ID: `00000000-0000-0000-0015-000000000003`
- Persistence: official default
- Processor batch / object budget: 256 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 0

The actual background event occurred 1.866311936 seconds after ledger commit,
before the 15-second schedule. Binary search preserved the four-object E014
shape and exact sequence coverage:

| Call | Sequences | Spans | Encoded bytes |
|---:|---|---:|---:|
| 1 | 1...243 | 243 | 262,101 |
| 1 | 244...256 | 13 | 14,031 |
| 2 | 257...498 | 242 | 261,122 |
| 2 | 499...500 | 2 | 2,161 |

Provider flush completed in 520.240708 ms and made one 539,415-byte file
visible before direct `SIGKILL`. Resume sent one 138,591-byte request and
recovered 500/500 with no duplicates. Compared with the matched E014 default
linear run at 7,035.960208 ms, flush duration decreased by 92.6% and satisfied
the preregistered two-second bound.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `acc8633650450765c92a0b5ad235bd64e155b54e1552a9e696d5154e2d4cb4e4` |
| `background-boundary-state.tsv` | `ae395616faf4dbab2d1c54a23ea126165083146e6efb41bc5b97a509daa20c10` |
| `collector.log` | `117fcb5152b977802c2ab7afba7b9a781a4af7b82b0d7c04b86515e597ac8e26` |
| `evidence-digests.tsv` | `e2fa1c677581ceebdea9f5d8ef628c8e3a4db07c5a787c822d08c5705d3d60c9` |
| `first-launch.txt` | `54c72fb545d8a1cdb8ea1ad1bdd5c2f32cf6b3f45ff4eb8425f6c05e6dc9f7c0` |
| `generated-before-relaunch.jsonl` | `d4460657743a310238078753a0515fd38e92d77a0fd51e3057b4fbfeda587190` |
| `generated.jsonl` | `d4460657743a310238078753a0515fd38e92d77a0fd51e3057b4fbfeda587190` |
| `host-timing.tsv` | `69446b2bc38eb8e15796795d417a7b09ee5c336c51d175fadea2d7f550cd66db` |
| `http-attempts.jsonl` | `c61f6a1995ad69fdf7bcf9dc131ce5a8c4e498c93eb2f547a3d7b12501052bad` |
| `lifecycle-events-before-relaunch.jsonl` | `477ae9accebc773448de1c7fc6f2068d87be43a76ca004f93eb4c0dd1f12d06d` |
| `lifecycle-events.jsonl` | `477ae9accebc773448de1c7fc6f2068d87be43a76ca004f93eb4c0dd1f12d06d` |
| `object-policy-events-before-relaunch.jsonl` | `8c20042aeb7b08cbc9d6c4ad67b7baf199bd4ec64182e29880708e9b055f577f` |
| `object-policy-events.jsonl` | `8c20042aeb7b08cbc9d6c4ad67b7baf199bd4ec64182e29880708e9b055f577f` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `0f4e333e4a4e220612b79b2526bb19f37553842949e81c7937e0824a06552bcc` |
| `received-otlp.jsonl` | `017203cd6f1a6b3df60dc2eb67a8c8e29ea8d40851c8b07cb047b3225754f8c4` |
| `reconciliation.json` | `e90e93935938d9ccbfb0a7d8e4e798ce2e7430a78628b555fe2752cb460b02a2` |
| `resume-launch.txt` | `eac71075dbcf1ac04acb0c6888de9304febfebd589fb28856c5d9f830409d787` |
| `run-before-relaunch.json` | `5b8b416e3394f9c959536b606bdbf254aa0ca45bcc3c6bc4f311b01640ef8b7d` |
| `run.json` | `5b8b416e3394f9c959536b606bdbf254aa0ca45bcc3c6bc4f311b01640ef8b7d` |
