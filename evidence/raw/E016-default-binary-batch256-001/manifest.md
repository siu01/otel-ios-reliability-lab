# E016 default binary byte-policy main-queue probe, attempt 001

- Outcome: Accepted exact delivery and sub-second queue delay
- Date: 2026-08-02
- Plan commit: `ed08e96`
- Run ID: `00000000-0000-0000-0016-000000000003`
- Persistence: official default
- Processor batch / object budget: 256 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 0
- Main-queue probe: enabled

The actual background event occurred 2.008125696 seconds after ledger commit,
before the 15-second processor schedule. The binary policy produced the same
four logical partitions as E015: 243 + 13 + 242 + 2. Their measured encoded
sizes were 262,102, 14,034, 261,128, and 2,162 bytes.

Provider flush completed in 476.152500 ms. The closure enqueued on the main
queue immediately before flush executed after 702.835375 ms, leaving
226.682875 ms beyond the provider call. The full measured queue delay satisfied
the preregistered one-second bound, while again failing the under-100-ms
overhead hypothesis.

One 539,426-byte persistence file was visible before direct `SIGKILL`. The
first process made no HTTP attempt. Resume sent one 138,591-byte request and
recovered 500/500 generated sequences with no duplicates or unexpected
receipts. Lifecycle, generated-ledger, run, and policy evidence remained
byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `d6135132a8e08627215fceaa622b6c93c80387b1d5726b1f3e33d1d01a52d258` |
| `background-boundary-state.tsv` | `5717ea51f55894b306bad92fea50f4822105161fa94e6c3aecd07a92dcfba191` |
| `collector.log` | `e52f4e77d59e70a466c4bd9698e2e31a093a25303670da2ae2553696afb27bd1` |
| `evidence-digests.tsv` | `211c45c4861181473de6d4a627163777e023985f56d16433d0b25e5b0836f61e` |
| `first-launch.txt` | `f5abe41f8940d129621b474a6408b27e3bc13ae42b5aa50c745533b85299c718` |
| `generated-before-relaunch.jsonl` | `cee9f9548c7b8ac778b937b190571f5fafcf93d1808f1b76607fd1af9111f0dd` |
| `generated.jsonl` | `cee9f9548c7b8ac778b937b190571f5fafcf93d1808f1b76607fd1af9111f0dd` |
| `host-timing.tsv` | `fd7d845127d9a75e3a53df83e1e2823f29d6b0ab2d165d64ef4fa6ef9a2fc245` |
| `http-attempts.jsonl` | `9a6a306e79978e27d43bb998b7be02bd377d5de92f22400e13512cb728bf6b77` |
| `lifecycle-events-before-relaunch.jsonl` | `43d12a5a460fc747f37de1db4b210d48de9bde1f164174f3d4c22c9128d54de9` |
| `lifecycle-events.jsonl` | `43d12a5a460fc747f37de1db4b210d48de9bde1f164174f3d4c22c9128d54de9` |
| `object-policy-events-before-relaunch.jsonl` | `96f9bf0fcb51e365da8bb20f2a4c059f9e8273c1bb2e30b6135fe8f4246fe3e7` |
| `object-policy-events.jsonl` | `96f9bf0fcb51e365da8bb20f2a4c059f9e8273c1bb2e30b6135fe8f4246fe3e7` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `8363a62b4a815a7ad018d2198d936c61d1ce7df999ab5dc6aff03a5dcef0a4ee` |
| `received-otlp.jsonl` | `919e90aeb0f2a4479b0d0690d6e7c5596db7fcef1ecc869fd24e621dbe090606` |
| `reconciliation.json` | `d20b2810182648fb80259ae02f04f3105e2bb3bd7a5296c1da750a818e8e660a` |
| `resume-launch.txt` | `f1d0f65f355be12902ed075d6366f4c88fd033ab5595b44ca482b91b1ba11bb4` |
| `run-before-relaunch.json` | `ca7e6bd76c2604ffb5e32d49989208968b0a619c13cb3e94af0ee198eedbf83d` |
| `run.json` | `ca7e6bd76c2604ffb5e32d49989208968b0a619c13cb3e94af0ee198eedbf83d` |
