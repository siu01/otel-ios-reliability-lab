# E006 default zero-offset sharp stop, replacement attempt 003

- Outcome: Accepted zero-recovery boundary run
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000008`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: first observation of the complete 100-record ledger plus 0 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 43595

## Boundary observation

The host first observed the complete ledger at 13:25:33.467Z. Instrumentation
and the pre-request file check took 55 milliseconds before the signal request
at 13:25:33.522Z. The post-signal timestamp was 13:25:33.559Z.

No persistence file was visible before the request and none existed after the
process stopped. Relaunching the same run with the Collector available produced
no HTTP attempt and no receipt. Both the generated ledger and run metadata had
identical before/after resume digests.

The result establishes an end-to-end vulnerable interval after the app finished
emitting and independently recording all 100 logical spans but before a
recoverable persistence file existed. It does not identify whether the killed
state was the batch processor queue, encoding, async dispatch, or file I/O.

## Reconciliation

- Unique generated: 100
- Unique received: 0
- Total received records: 0
- Duplicate receipts: 0
- Missing receipts: 100 (sequences 1 through 100)
- HTTP attempts across resume: 0
- Persistence files after termination: 0
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `boundary-state.tsv` | `402ba5491ea4e2bbd1de390e9a7f08e4ae9e5e47b10de48ece063ab163ee7c57` |
| `collector.log` | `bcb385d246227f36994dd0af4fe668c0982655d3f60c4c511da3ffde75b7ea3e` |
| `evidence-digests.tsv` | `3c7e832eb68d9a04a8cc4da4974b5adc11460f0be646c101cebc7477f6e00c36` |
| `first-launch.txt` | `db7d6ee5a5a427fdfd7ba556161d4d0d7ad320b17355fafb6ade01f526355447` |
| `generated-before-relaunch.jsonl` | `53d75ec91d57bba330e545f25e145a3025a21d3ff1944c2cf968b26283b0f9ab` |
| `generated.jsonl` | `53d75ec91d57bba330e545f25e145a3025a21d3ff1944c2cf968b26283b0f9ab` |
| `host-timing.tsv` | `16cf0d8934450b23a0631b442f16a0addc5b424bf15ea0689be25786da6455cb` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `a3f9f92743aa189777a527fefd727c9f1b54cb10ba1666cf6adcd91bdc21dcf6` |
| `resume-launch.txt` | `b2826e89baaf3eb39b2ba8c47d3f3f73f7dea599c30ca84ff485689ccc71c4f8` |
| `run-before-relaunch.json` | `709f7b5f2d61373af67cc5e2c6db55cd88aa3391c4c88056fd16b40b3ad46d62` |
| `run.json` | `709f7b5f2d61373af67cc5e2c6db55cd88aa3391c4c88056fd16b40b3ad46d62` |
