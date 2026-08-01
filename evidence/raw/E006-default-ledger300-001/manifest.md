# E006 default 300-millisecond sharp stop, attempt 001

- Outcome: Accepted exact-recovery boundary run
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000005`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: complete 100-record ledger plus 300 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 45505

## Boundary observation

The ledger was observed at 13:32:11.010Z, the signal was requested at
13:32:11.341Z, and the post-signal timestamp was 13:32:11.350Z. The observed to
requested interval was 331 milliseconds, including the registered wait and
host instrumentation.

Unlike the 0/50/150-ms conditions, one complete 107,778-byte persistence file
was already visible before the signal request and remained afterward. Resume
made one successful 27,818-byte request and recovered all 100 spans exactly
once. The generated ledger and metadata stayed byte-identical.

This run supplies the durable side of the observed transition: no file and zero
recovery at an effective 181 milliseconds, versus a pre-request file and exact
recovery at an effective 331 milliseconds. It does not prove a universal SDK
deadline between those values.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- HTTP attempts after resume: one success
- Persistence files after termination: 1
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `boundary-state.tsv` | `db69ee604edb026b865ee50b0ec283e7c574cf12bc97eafcbd747565fd9d6d78` |
| `collector.log` | `f2b693af396be236b55242e2be24ec7f4580b4e6a031589354e4959e2f4e2599` |
| `evidence-digests.tsv` | `883aaadec6c90842f0d2429c73f6103d77d79114d48525343354ae98def07a00` |
| `first-launch.txt` | `d0ae42c35d00a5f3f43bfebd3445195204266ecc6d0fdd775d2e94f52b9e402b` |
| `generated-before-relaunch.jsonl` | `3b70226d9b835eb5218d5d88a4354218f7f3a6bbb3d9d917048aad34d21b25e3` |
| `generated.jsonl` | `3b70226d9b835eb5218d5d88a4354218f7f3a6bbb3d9d917048aad34d21b25e3` |
| `host-timing.tsv` | `6a0cb69c55609b4346ce93976fca160e847dc6d9209693850c4601009b5f6d73` |
| `http-attempts.jsonl` | `fb08f527ddb9377eff70f3a45f66f3276b3a9143c7e85cd0f2b750f9ead907a0` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4e5a89abb7118e54a81491fa30db720add98fb5a7c087461e1bba3e018228e35` |
| `received-otlp.jsonl` | `41c2b85b4d9a4c073416da1dfa1e1bf741acba9caa1ded6cb533764ea9e6725c` |
| `reconciliation.json` | `6d0ca9d97bdb815dc82e3adbd3a120984eb3d68c2ceb277aa9fd5230a6d80074` |
| `resume-launch.txt` | `f258798d379a434ceba16ffd215df2adaae941b906bdcdaf1c87fcc1680774bb` |
| `run-before-relaunch.json` | `f12e354b1e69349d94ed38baf928749b89e3d9621881295efe05ad38c5ec7cc3` |
| `run.json` | `f12e354b1e69349d94ed38baf928749b89e3d9621881295efe05ad38c5ec7cc3` |
