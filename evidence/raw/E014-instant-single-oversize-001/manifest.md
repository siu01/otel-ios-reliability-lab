# E014 instant single-span explicit oversize, attempt 001

- Outcome: Accepted explicit-rejection intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000006`
- Persistence: official instant
- Processor batch / object budget: 1 / 262,144 bytes
- Payload attribute bytes: 262,144

The actual background event occurred 2.005045760 seconds after ledger commit,
before the 15-second schedule. Before calling the official persistence exporter,
the policy encoded the single span as 263,259 bytes and recorded one
`rejectedOversize` decision for sequence 1 and span ID
`9b59014ee99bcf2e`. The encoded object exceeded budget by 1,115 bytes.

Provider flush returned after 48.651292 ms. No persistence file or HTTP attempt
appeared in either process, and reconciliation remained 0/1. The result matches
the default policy behavior and is accepted as observability recovery, not
delivery recovery.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `251389d2fd49c6e33c5956c3fb439243256279445ada27597d29ffa68580696e` |
| `background-boundary-state.tsv` | `391bad37b22494ba624d1c4ba76c847dc31835b81ce122c6d93c98701d0006f8` |
| `collector.log` | `200bcc117745bc9e05bb47566f389b108ab3912c03b3d16dcdcf15e4b46fe56a` |
| `evidence-digests.tsv` | `a21347d5bc1918f1ea9c066992c8767fec34cdfd8ded5815700e03ea48db16ee` |
| `first-launch.txt` | `0d607625dd4345bf8216bf3862a21bc81146c6d9c6f665d31c48472851dd91d9` |
| `generated-before-relaunch.jsonl` | `a8ffcee7eeade35eb7f15816d5dde6e2da3fedc6ea198b6c95aca4626e53fc8e` |
| `generated.jsonl` | `a8ffcee7eeade35eb7f15816d5dde6e2da3fedc6ea198b6c95aca4626e53fc8e` |
| `host-timing.tsv` | `f7061c2d0879d833098ed6164e9a3ea0d3e3ac124f11e425f485576899bcffd4` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `9e420217d45c102ffaf55a9eca6205c7b5dd220ac20aea73073468ac5afbe500` |
| `lifecycle-events.jsonl` | `9e420217d45c102ffaf55a9eca6205c7b5dd220ac20aea73073468ac5afbe500` |
| `object-policy-events-before-relaunch.jsonl` | `196fe292a41b376a2f81280e9e8fafaf1d386ee4184946f225655e80f91be81d` |
| `object-policy-events.jsonl` | `196fe292a41b376a2f81280e9e8fafaf1d386ee4184946f225655e80f91be81d` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `a50c20442cfd8c72915e61b1b66b9cb5c8177b50d26499bac2defc982b7c864e` |
| `resume-launch.txt` | `608bb76911e62170505016a090f7c7f827cc9689c30632ee0bfc455e36538721` |
| `run-before-relaunch.json` | `eac7287b2ba4d38afe9d893aeb1c32c2919db11a451efb1653bfbd32e60be28f` |
| `run.json` | `eac7287b2ba4d38afe9d893aeb1c32c2919db11a451efb1653bfbd32e60be28f` |
