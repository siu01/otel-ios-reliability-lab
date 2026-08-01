# E011 default 1,024-byte payload, attempt 001

- Outcome: Accepted fitting-object preset comparison
- Date: 2026-08-02
- Plan commit: `330beb3`
- Payload metadata commit: `7097952`
- App payload commit: `24c5218`
- Runner commit: `bba1c24`
- Run ID: `00000000-0000-0000-0011-000000000005`
- Persistence: official default
- Spans / max export batch: 100 / 100
- Payload attribute bytes per span: 1,024

The background event occurred 1.840655872 seconds after ledger commit. Provider
flush completed in 51.931166 ms and produced one 213,688-byte persistence file.
Resume sent one 132,418-byte request and recovered 100/100 with no duplicates.
First-process HTTP count was zero and evidence digests were stable. This matches
the instant 1,024-byte fitting condition.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `57e69ae3f29c960f51f46bce570b09a94b78c904671af12bd986340646382812` |
| `background-boundary-state.tsv` | `806d677a64b504083b462ad6d252d46671e91a77c38977b58d54dc6a9da60f6c` |
| `collector.log` | `2a2273fe59a0e592eadea68f109207c92e1883f310f8ce09774b6ce030b7339d` |
| `evidence-digests.tsv` | `91b8c2ff10dc976efe30384a549bbbee90469bb2fae57c3ad11672aea451129a` |
| `first-launch.txt` | `928e6073db05ab4f6be3866b26b23cebb5eda1e68d99745ebeb824b95ce3b11b` |
| `generated-before-relaunch.jsonl` | `16efb059a79154ad59cfd60cf2a098afe46b31d49ccbae6ee6418afe315f4658` |
| `generated.jsonl` | `16efb059a79154ad59cfd60cf2a098afe46b31d49ccbae6ee6418afe315f4658` |
| `host-timing.tsv` | `a150ff3c222126ac08ecc5009c6117a25c5eae3d9e096fe657b4c07413227ec7` |
| `http-attempts.jsonl` | `0e89f0dda9a4e9316aa595bc0f5194015999496d46b01c8afca97cc55ffebbba` |
| `lifecycle-events-before-relaunch.jsonl` | `23c7585a94d710e61c58720a93dd8456d751d2ad62711db5559cb69fd9ddcb53` |
| `lifecycle-events.jsonl` | `23c7585a94d710e61c58720a93dd8456d751d2ad62711db5559cb69fd9ddcb53` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `33f8f568df40114d670a15b71465679ef08231e6ca6e0bc0d2c7378153924229` |
| `received-otlp.jsonl` | `800987b79140e182d258a94354e1d392e1b5b198e47334871b95f4b130d7cd9e` |
| `reconciliation.json` | `a49797efa65c0fa5ebd8c71f4a2e2f67bad34108b821ecb73159e8a09ab8a25b` |
| `resume-launch.txt` | `be049ca9b4876b9bbfc8cbb7f47ca57a95c9e9b7f6ecb36caccbc1f05ac6166a` |
| `run-before-relaunch.json` | `aa055e06df3613b0a4579b00edce3570279f3780601e2f1040fc11b6ac503fc9` |
| `run.json` | `aa055e06df3613b0a4579b00edce3570279f3780601e2f1040fc11b6ac503fc9` |
