# E006 instant zero-offset sharp stop, attempt 001

- Outcome: Accepted zero-recovery preset comparison
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000006`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: complete 100-record ledger plus 0 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 45911

## Boundary observation

The ledger was observed at 13:33:46.818Z, the signal was requested at
13:33:46.837Z, and the post-signal timestamp was 13:33:46.848Z. The observed to
requested interval was 19 milliseconds.

No persistence file existed before or after termination. Resume made no HTTP
attempt and received zero spans, while ledger and metadata digests remained
unchanged. This matches the default zero-offset result: synchronous persistence
cannot protect spans that have not yet crossed the upstream batch processor
handoff.

The observation is end-to-end; it does not directly inspect the batch queue and
therefore does not identify its exact internal state at the signal instruction.

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
| `boundary-state.tsv` | `e690482c91e476a542bbb2f81abef3f8e31a59675e9ee609a5529876dca4dea3` |
| `collector.log` | `a76cc14d4195709556c5c4bd8529791be62e579545ad0f4cb8a623a585bd8d7c` |
| `evidence-digests.tsv` | `c2840489aedfaa33f0e95e8322808a1e91cf6962c5cee366a505d350144d6c8d` |
| `first-launch.txt` | `5a23559d71fd88d09806c070b9c434b796b46e7e3f2ca1a60d3d2332a85eb856` |
| `generated-before-relaunch.jsonl` | `6dbde090e74400636933e74d2281c49a75c0f8b947637ea619b16ffaed703bb6` |
| `generated.jsonl` | `6dbde090e74400636933e74d2281c49a75c0f8b947637ea619b16ffaed703bb6` |
| `host-timing.tsv` | `186f6a9461770930be607f8e481bd3db3c9bde2fcc81b5e6f4ae17824de666dc` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `7837dc6be917a489f98a3da9ad6d3eb10b715145e78fa5efbbbdc56fe52313f3` |
| `resume-launch.txt` | `1f3069db42827744d6278610fe98896deb6496ce39559f2fcfb1dcab9f467706` |
| `run-before-relaunch.json` | `1a23f83c117e2b8d1ee49c74d3851e448dd8e5069b5def78871db0d175a37481` |
| `run.json` | `1a23f83c117e2b8d1ee49c74d3851e448dd8e5069b5def78871db0d175a37481` |
