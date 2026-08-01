# E006 instant 300-millisecond sharp stop, attempt 001

- Outcome: Accepted exact-recovery preset comparison
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000007`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: complete 100-record ledger plus 300 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 46325

## Boundary observation

The ledger was observed at 13:35:17.208Z, the signal was requested at
13:35:17.536Z, and the post-signal timestamp was 13:35:17.545Z. The observed to
requested interval was 328 milliseconds, including the registered wait and
host instrumentation.

One complete 107,793-byte file was already visible before the signal request
and remained after termination. Resume made one successful 27,818-byte request
and recovered all 100 spans exactly once. The generated ledger and metadata
stayed byte-identical.

Together with the instant zero-offset loss, this shows that synchronous
persistence protects the batch once its file exists but does not remove the
upstream end-to-end interval before the persistence exporter is reached.

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
| `boundary-state.tsv` | `5dab71edaa91de7c232d00bf73c46788e40d75559432474ba54d0861a8e972e0` |
| `collector.log` | `30c0cbef8626efe8b3d6ae216961d5f97db83c1c30087f8a31945f9152f5d9cb` |
| `evidence-digests.tsv` | `12490e4a12d68b4bdb14a2797b47a66a56654ce67814c7af014e9f289efb11dd` |
| `first-launch.txt` | `db87e087656df497290ae7228c98da68f3a63f80fba1bde1352d31c40e724d76` |
| `generated-before-relaunch.jsonl` | `b8ace4ff4df8ced9110514af279348b85a789acec90a66ce6d9f8ea0279b8432` |
| `generated.jsonl` | `b8ace4ff4df8ced9110514af279348b85a789acec90a66ce6d9f8ea0279b8432` |
| `host-timing.tsv` | `5eb96606bc72c8cabf9950373b15ca47bc98d93214d04e5fe318fc2904da6024` |
| `http-attempts.jsonl` | `f9dd37e0a963e40fc05ba7d077615f9e61f89d1a1a8c582b0b788f7dc0b60228` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `f1621a1d806624d53a2e382906fabdd1c48cc3c40565b5a159e2db90db89d334` |
| `received-otlp.jsonl` | `41d994c6b18c00e0d2f14bd4cdd48536782f60da24169fbc4fd6ee810287cc12` |
| `reconciliation.json` | `b3de57cfc52e1be7e2ccfef807a49cc5570dc604fe0700c758fa4166ae0747f0` |
| `resume-launch.txt` | `c25af853523aa05056d57918419a2f1a2a65b82510831adb291eb99373599a2f` |
| `run-before-relaunch.json` | `7733c1a3a36de79e35ce7f57a6b80f1e0c93f188a1845859893a4feb3f5b8dd5` |
| `run.json` | `7733c1a3a36de79e35ce7f57a6b80f1e0c93f188a1845859893a4feb3f5b8dd5` |
