# E006 default 50-millisecond sharp stop, attempt 001

- Outcome: Accepted zero-recovery boundary run
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: complete 100-record ledger plus 50 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 44641

## Boundary observation

The ledger was observed at 13:28:59.199Z, the signal was requested at
13:28:59.272Z, and the post-signal timestamp was 13:28:59.278Z. The observed to
requested interval was 73 milliseconds, including the registered 50-ms wait and
host instrumentation.

No persistence file existed before or after termination. Resume made no HTTP
attempt and received zero spans. The generated ledger and metadata remained
byte-identical. Like both zero-offset sharp stops, this run lost the entire
batch after the app had recorded all 100 logical generations.

## Reconciliation

- Unique generated: 100
- Unique received: 0
- Duplicate receipts: 0
- Missing receipts: 100
- HTTP attempts across resume: 0
- Persistence files after termination and resume: 0

## SHA-256

| File | Digest |
|---|---|
| `boundary-state.tsv` | `46a6e6eb584ab42381dc60bfe786f7c866b4ddebd0cd079e1a0abeb860c05ddb` |
| `collector.log` | `5ae449ae11e313d3f243dec2363c4f28a2a9610984ff1910289da4e826fa2eaa` |
| `evidence-digests.tsv` | `d5240b377270eeb1936339b277f61751408398dadc1872f9aebfdcd346cec543` |
| `first-launch.txt` | `631522aaf4591a99584653a5773d3b448fb0468fbe95fc098d85a3c8f1e5d853` |
| `generated-before-relaunch.jsonl` | `8b81436e51fc93aa8fe673655b16f23fb1794d6099f5e834fcb4a9e7526e2703` |
| `generated.jsonl` | `8b81436e51fc93aa8fe673655b16f23fb1794d6099f5e834fcb4a9e7526e2703` |
| `host-timing.tsv` | `875998892a24dfe7ce9ffe2f23af23ccc2f5bec46fd58bbaa5fd80557aeb2872` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `dad42ffda1e67960a6e41cd42b4cbbd33946dac93d181e52b76ea75417bb7259` |
| `resume-launch.txt` | `46a48a02a887372a229e3aafa2430a4e5a0f3ff68c7aeb421e43ab9bd072eda5` |
| `run-before-relaunch.json` | `ce07d2cbe92c8bf36e6e9b28e6e7085563f52b54096e74d6ddd78e5f8fed9340` |
| `run.json` | `ce07d2cbe92c8bf36e6e9b28e6e7085563f52b54096e74d6ddd78e5f8fed9340` |
