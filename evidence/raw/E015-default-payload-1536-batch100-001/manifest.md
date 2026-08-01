# E015 default payload-heavy binary search, attempt 001

- Outcome: Accepted exact and faster intervention
- Date: 2026-08-02
- Plan commit: `2bcbbc5`
- Run ID: `00000000-0000-0000-0015-000000000001`
- Persistence: official default
- Processor batch / object budget: 100 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 1,536

The actual background event occurred 1.581088768 seconds after ledger commit,
before the 15-second schedule. Binary search preserved E014's partition shape:
98 spans / 259,614 bytes and 2 spans / 5,302 bytes, covering sequences 1...100
exactly once.

Provider flush completed in 158.236167 ms and made one 264,916-byte file visible
before direct `SIGKILL`. Resume sent one 183,618-byte request and recovered
100/100 with no duplicates. Compared with the matched E014 default linear run at
2,072.657167 ms, flush duration decreased by 92.4% while delivery and policy
semantics remained unchanged.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `4a2937b62a475aa24a871f94bbd9e153e3f578ce698d74383d72d9d34658abb0` |
| `background-boundary-state.tsv` | `b86e4ce9b2af6866cdf4d32ce0fbab7a4b780499f753d25931c4e0c37ac95a75` |
| `collector.log` | `628fdfbd073421ab5f72b791792251efe584ba87784ba73f4df3e90a274c0c7f` |
| `evidence-digests.tsv` | `a90a6044377d3bbd32975c5a7d2e167116fa20470ea4940eafe2281c611ab6a4` |
| `first-launch.txt` | `b3a82bdfcb1f9483700c9044b33539c28ed1a3b58981ac8b00ae18ba6ea83013` |
| `generated-before-relaunch.jsonl` | `0d68ac0dfde7ff99f3edf8982b88f4d6b7ed8c20cfac092a85f727a79763a51c` |
| `generated.jsonl` | `0d68ac0dfde7ff99f3edf8982b88f4d6b7ed8c20cfac092a85f727a79763a51c` |
| `host-timing.tsv` | `482b35ad6726dcf37cd4f0a9772cfbce1be9f2e734ae16216ebcee0b61ad83de` |
| `http-attempts.jsonl` | `11d8364da7004ceae22af9ecf622fbde2d6d348e68d77a686b2e274e3a533b9f` |
| `lifecycle-events-before-relaunch.jsonl` | `e80d64ebdf9f2710fcdb8d6123206349dc1798e485e267e0dce7f68bfb2ef350` |
| `lifecycle-events.jsonl` | `e80d64ebdf9f2710fcdb8d6123206349dc1798e485e267e0dce7f68bfb2ef350` |
| `object-policy-events-before-relaunch.jsonl` | `14688e03a5c5d3414fb2a9669728c3cb99b893b7b83e3f8e157a5ed2c89e8823` |
| `object-policy-events.jsonl` | `14688e03a5c5d3414fb2a9669728c3cb99b893b7b83e3f8e157a5ed2c89e8823` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `215f00a1b53320f5cbc6e8d8b7d5d4b6f4048466358c500746f8afccdc53ae83` |
| `received-otlp.jsonl` | `35969b943135c0b76e0c44c42a0bb6d15ba51f0086cfb30b0b52b5ede736d99b` |
| `reconciliation.json` | `498c766afa501912c889b748e5966b190be3e51b6519ff0470ecbc85b927ce74` |
| `resume-launch.txt` | `b5b15ca535c39795abfe83dc3cf0fd889a112e77729426942779304ddd9fe253` |
| `run-before-relaunch.json` | `2a5eb4621da830f7a3a1f60034f86ea13d51252d27d356da095dc506cf056bea` |
| `run.json` | `2a5eb4621da830f7a3a1f60034f86ea13d51252d27d356da095dc506cf056bea` |
