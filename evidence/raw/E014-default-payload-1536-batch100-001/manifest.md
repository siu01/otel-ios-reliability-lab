# E014 default 1,536-byte payload byte policy, attempt 001

- Outcome: Accepted exact-recovery intervention
- Date: 2026-08-02
- Plan commit: `37a0cb2`
- Run ID: `00000000-0000-0000-0014-000000000001`
- Persistence: official default
- Processor batch / object budget: 100 / 262,144 bytes
- Payload attribute bytes per span: 1,536

The actual background event occurred 9.039771904 seconds after ledger commit,
before the 15-second schedule. The policy split one 100-span processor input
into an accepted 98-span, 259,557-byte object and an accepted 2-span,
5,299-byte object. Their recorded sequences cover 1...100 exactly once.

Provider flush completed in 2,072.657167 ms and made one 264,856-byte file
visible before direct `SIGKILL`. Resume sent one 183,618-byte request and
recovered 100/100 with no duplicates. E011 lost this same preset, total count,
batch count, and payload at the native writer boundary.

The policy-event file remained byte-identical across relaunch. The comparatively
long flush is accepted evidence and motivates a later implementation-cost test.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `ae10a72c9335a8b32e36b5322faff3fa0d1a024c75c1f20b8e21bdc90902904e` |
| `background-boundary-state.tsv` | `a1ea4cbc0a7aaa4ec0ee9b49d6091d66ee818d7765dc2fdb03c5cc86209d63d7` |
| `collector.log` | `31fa4b6c84aeff8be97e8ab90b6efb2a0c67ddb6322e2c50c2f188994c3e08a4` |
| `evidence-digests.tsv` | `3761e334f0b066aeccc3cc7049c9602196d012e16ed7796fdba19f2c2bb3b397` |
| `first-launch.txt` | `06014e7b1947fadc4283b490be5c4b5f711e750623d5d9553228e116296997f7` |
| `generated-before-relaunch.jsonl` | `0776cdff01008e23863d947a626c8299ec435ea5cee0e4422f9db7f16475952e` |
| `generated.jsonl` | `0776cdff01008e23863d947a626c8299ec435ea5cee0e4422f9db7f16475952e` |
| `host-timing.tsv` | `96057344e7da13ed782c5a07644945eee66b9283aa8475062e7cd691a35536c2` |
| `http-attempts.jsonl` | `a93995f9cd02d5735b2b575f6630b38f3ce815ec9d4298c0b25d173d635e3b9c` |
| `lifecycle-events-before-relaunch.jsonl` | `3b9a4c7db4314c5fbef760f3702c214246c71e2dc68698f1a75c4d1f0c593cfe` |
| `lifecycle-events.jsonl` | `3b9a4c7db4314c5fbef760f3702c214246c71e2dc68698f1a75c4d1f0c593cfe` |
| `object-policy-events-before-relaunch.jsonl` | `9e079e9ea080f14ce4555125b33864f1131375cdc608916e95728571441524c0` |
| `object-policy-events.jsonl` | `9e079e9ea080f14ce4555125b33864f1131375cdc608916e95728571441524c0` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `57d20a3dbced75cc2c20b87cc888844b972a87f3ef94468af696cec46b9f4d6d` |
| `received-otlp.jsonl` | `ffb42bfb119867bddcc11f1b2d211fbbd8d77c70cf3e52de47045da838eb5e65` |
| `reconciliation.json` | `a714dd6bcf7827621a3ae4399476192cd31420f31b72e1b8c5fa16e4ad48ac32` |
| `resume-launch.txt` | `ed94e4e1f981df3650bc27e6e6e8665adcabf10e191c121f77e643c320307c0b` |
| `run-before-relaunch.json` | `9846e2f43ff832e7b0f10f2585bad7d0c76f03d039f1a76dbb89b2bee77e0d2f` |
| `run.json` | `9846e2f43ff832e7b0f10f2585bad7d0c76f03d039f1a76dbb89b2bee77e0d2f` |
