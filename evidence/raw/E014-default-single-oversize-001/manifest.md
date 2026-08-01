# E014 default single-span explicit oversize, attempt 001

- Outcome: Accepted explicit-rejection intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000005`
- Persistence: official default
- Processor batch / object budget: 1 / 262,144 bytes
- Payload attribute bytes: 262,144

The actual background event occurred 2.564247808 seconds after ledger commit,
before the 15-second schedule. Before calling the official persistence exporter,
the policy encoded the single span as 263,257 bytes and recorded one
`rejectedOversize` decision for sequence 1 and span ID
`6ffbbe197c914eb0`. The encoded object exceeded budget by 1,113 bytes.

Provider flush returned after 14.737 ms. No persistence file or HTTP attempt
appeared in either process, and reconciliation remained 0/1. Unlike the matched
E013 silent loss, this condition has an explicit, checksummed local identity and
byte reason. It is accepted as observability recovery, not delivery recovery.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `3f6a7aee99e3595a84cbf8950a4e1245de5a98317639040f61897dcac5a9c4c6` |
| `background-boundary-state.tsv` | `3ac73e0387e9d5216c1f5a68d90f27ba9f3a6e33906bbbafbcd022e2b53fd6a3` |
| `collector.log` | `d01149f1b0ba6f431a9f70736b73feb275adc6968bb4b9ae31cd25afc4b3e15c` |
| `evidence-digests.tsv` | `af11be2c8c102b79f66c2e8e53cb807421e1844b1235e63df2f8b4bc5864fbea` |
| `first-launch.txt` | `3fc5a4f09770d9d76a05e367aee98190d5524bb608455487bc205bb043efce3d` |
| `generated-before-relaunch.jsonl` | `477dc31c9a1059be4d871182dd7230b06abfe734a39e3caaf67fc2c7aebb4349` |
| `generated.jsonl` | `477dc31c9a1059be4d871182dd7230b06abfe734a39e3caaf67fc2c7aebb4349` |
| `host-timing.tsv` | `81a07ed09a3edd05b5d4cf9f716971d45c2414cfecc0e86f587d9a5d5fdb98f4` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `321e0a4d511594d3944e1bd3b50f6edbd7d52420b44e8eaac55bd2f0d61304c7` |
| `lifecycle-events.jsonl` | `321e0a4d511594d3944e1bd3b50f6edbd7d52420b44e8eaac55bd2f0d61304c7` |
| `object-policy-events-before-relaunch.jsonl` | `887a6bbf4ea3a45636f8adb11e163c29c1a2f5586a089018904b570d5c73804e` |
| `object-policy-events.jsonl` | `887a6bbf4ea3a45636f8adb11e163c29c1a2f5586a089018904b570d5c73804e` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `9b114a3ad97170caeba3ec7574dbb501786a4e5492455fa171c9694829f51079` |
| `resume-launch.txt` | `85ed81b3ba6be11f96dfe217a5129263bd0fa4cb2ba28efbf311d5eae0cfaf82` |
| `run-before-relaunch.json` | `a8983a3b116b8758ec1b968dec32d150f7d014952311295329c2a7540d4c5f06` |
| `run.json` | `a8983a3b116b8758ec1b968dec32d150f7d014952311295329c2a7540d4c5f06` |
