# E014 default 500 spans with byte policy, attempt 001

- Outcome: Accepted exact-recovery intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000003`
- Persistence: official default
- Processor batch / object budget: 256 / 262,144 bytes
- Payload attribute bytes per span: 0

The actual background event occurred 5.021613824 seconds after ledger commit,
before the 15-second schedule. The processor supplied 256 and 244 spans. The
policy emitted four accepted objects:

| Call | Sequences | Spans | Encoded bytes |
|---:|---|---:|---:|
| 1 | 1...243 | 243 | 262,068 |
| 1 | 244...256 | 13 | 14,032 |
| 2 | 257...498 | 242 | 261,075 |
| 2 | 499...500 | 2 | 2,159 |

All were at or below the 262,144-byte budget and cover 1...500 exactly once.
Provider flush completed in 7,035.960208 ms and made one 539,334-byte file
visible before direct `SIGKILL`. Resume sent one 138,591-byte request and
recovered 500/500 with no duplicates. E009 lost this same preset, total count,
processor batch, and payload without the byte policy.

The policy-event file remained byte-identical across relaunch. The seven-second
flush is accepted and makes optimization or precomputed size accounting a
requirement before treating this prototype as a production implementation.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `dbe873817661e71da3fd706bee643bd3cbb939bc6c31682ebad096572b3ce4df` |
| `background-boundary-state.tsv` | `165edfe478d36e23de0c7d345d210d69aba86f6dd0b3b61a54421c604e036c64` |
| `collector.log` | `d421b8fee7ccdbfc327c3ecf94b14ae1ba9df0d6655aa7749432e2a3211a5097` |
| `evidence-digests.tsv` | `8de4c902c20432d37541cfd3ce022973f23120a0f05d20e14420b7ba93924ab1` |
| `first-launch.txt` | `4c1285218e7f2ee5655f0191e00e62004866305e0dcc57929f0d1ad8b99e531d` |
| `generated-before-relaunch.jsonl` | `28756fdf3713e0506fa116ec43c6557d61889aa14060cf5af33e4edac64a9d26` |
| `generated.jsonl` | `28756fdf3713e0506fa116ec43c6557d61889aa14060cf5af33e4edac64a9d26` |
| `host-timing.tsv` | `7b5670e372e9a8866cda713951049a40fc77d7e13402822b53e1aaaf38bd9594` |
| `http-attempts.jsonl` | `c32f545f98170148623e8293ae04595a8d147e457b05eb6b18f11923e3e68297` |
| `lifecycle-events-before-relaunch.jsonl` | `6ad6713827d1fb99a36b85400a60a81528f0fc1aceaba7dca82003ae97de4b1a` |
| `lifecycle-events.jsonl` | `6ad6713827d1fb99a36b85400a60a81528f0fc1aceaba7dca82003ae97de4b1a` |
| `object-policy-events-before-relaunch.jsonl` | `dc5aa545e0d3f8019da95b8f200b164b490d840a02621ce1c0e9d9c0a7eefa4a` |
| `object-policy-events.jsonl` | `dc5aa545e0d3f8019da95b8f200b164b490d840a02621ce1c0e9d9c0a7eefa4a` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `b72aaed0322cf6186796d55961fbae14b31ef0ad66710d42e58da479b062672d` |
| `received-otlp.jsonl` | `cc2e96ad731813e7fe7f6c0518bcaf7fe1fa074b91e9f94d1a5b4b9690548705` |
| `reconciliation.json` | `807cea58f4512f0e985584eaa4a71f6629b259aa0d36701327e65d0c7bfbe116` |
| `resume-launch.txt` | `5c4f9be4917019fffacb8255317d2a1f1727a1fae4fc449158e2f9cd2b82b895` |
| `run-before-relaunch.json` | `abeb1076a3d68b428493d5be0807062cb8bdb6c631a56c5e3bc1b8812d44d764` |
| `run.json` | `abeb1076a3d68b428493d5be0807062cb8bdb6c631a56c5e3bc1b8812d44d764` |
