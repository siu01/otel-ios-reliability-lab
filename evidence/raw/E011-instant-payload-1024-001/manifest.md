# E011 instant 1,024-byte payload, attempt 001

- Outcome: Accepted fitting-object observation
- Date: 2026-08-02
- Plan commit: `330beb3`
- Payload metadata commit: `7097952`
- App payload commit: `24c5218`
- Runner commit: `bba1c24`
- Run ID: `00000000-0000-0000-0011-000000000002`
- Persistence: official instant
- Spans / max export batch: 100 / 100
- Payload attribute bytes per span: 1,024

The background event occurred 1.871569920 seconds after ledger commit. Provider
flush completed in 48.170084 ms and produced one 213,715-byte persistence file,
below the 256-KiB object ceiling. Resume sent one 132,418-byte request and
recovered 100/100 with no duplicates. First-process HTTP count was zero and
evidence digests were stable.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `fffb7c005c48950a044cf001983e338de6c996d665cdddd1034772d9c784a480` |
| `background-boundary-state.tsv` | `e1c105a3b9db80346efb599a47a8674fc783b5166c0756f30c06382f8a00f3d8` |
| `collector.log` | `f9014e15c6a6caea6898f416f122de00dbfca2ea2ad03ce75ce10d6fc919f63e` |
| `evidence-digests.tsv` | `bddc0421233b393775d4158e479a6f7b68af1b864b9863b822a1c17ca4be5b58` |
| `first-launch.txt` | `2c9746d29cb09cdcc91f311fef6ae5f8fb4b785bcc6130b76de1dce4c0f28151` |
| `generated-before-relaunch.jsonl` | `10c78b6a3f88b829f960a11b45cc1e261f4b7a7b0bf95919e2a94b8570bd7dbb` |
| `generated.jsonl` | `10c78b6a3f88b829f960a11b45cc1e261f4b7a7b0bf95919e2a94b8570bd7dbb` |
| `host-timing.tsv` | `69ace34c7d0be380429e7fad477ee1a36ddfb61ab54fafb92ec518d51c32ea2a` |
| `http-attempts.jsonl` | `2b5222dc8bb4dd6f1864edf5db46cce74e800fa547112c76bf01c3952df2becd` |
| `lifecycle-events-before-relaunch.jsonl` | `072590b0e99e0af318a1809c07e44658434d76d34c2dca270e343652d98a047e` |
| `lifecycle-events.jsonl` | `072590b0e99e0af318a1809c07e44658434d76d34c2dca270e343652d98a047e` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `c0eda5810051316f4c1545c9ea1f92322b87cb170c9e672c625dcd3d1c73fa3d` |
| `received-otlp.jsonl` | `7ca5192d326e12cc58ec2ac773b5677c3817761eaec3b17fa0945f8e6ac3051f` |
| `reconciliation.json` | `ac8da55eb523fa36c6b914e4e79872a9d7bd9b5110b5fad7a5e7341ee34737be` |
| `resume-launch.txt` | `5a86f23eaa0dd3fd259ff5cd1de709a83302831369d30ddc5cf038b725de4e26` |
| `run-before-relaunch.json` | `cbbdbc282b789016822199e74b000789c87c3c276dadef0034f657f6a52fe0e4` |
| `run.json` | `cbbdbc282b789016822199e74b000789c87c3c276dadef0034f657f6a52fe0e4` |
