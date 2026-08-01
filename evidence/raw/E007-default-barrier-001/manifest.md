# E007 default durability barrier, attempt 001

- Outcome: Accepted exact-recovery barrier run
- Date: 2026-08-01
- Barrier implementation commit: `c74c0e1`
- Host runner commit: `1b0ecfd`
- Plan commit: `b08e47e`
- Run ID: `00000000-0000-0000-0007-000000000003`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Flush: provider plus top-level exporter durability barrier
- Exporter: lab stateless OTLP/HTTP
- Stop: direct `SIGKILL` after observing flush completion

## Flush and boundary observation

The monotonic barrier duration was 100,111,625 ns (100.11 ms). One complete
107,816-byte file was visible before the signal and remained after termination.

Unlike provider-only flush, the barrier invoked the persistence export worker
while the Collector was unavailable. Attempt 1 sent 27,818 bytes and completed
with connection refused before the flush-completed event. The persistence file
remained. After process relaunch, attempt 2 sent the same 27,818-byte body and
succeeded. Reconciliation found all 100 spans exactly once.

The single measured barrier took 62.84 ms longer than the default provider-only
run. That difference includes the failed loopback request and is not a general
performance estimate. Provider-only had already produced a complete file in
its registered run, so E007 does not support claiming that this extra barrier
was necessary under the observed timing.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- HTTP attempts: failure in first process, success in resumed process
- Persistence files after termination: 1
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `0810ee3553ec890fdf7318a1fe03d4355c00c6144793905f4faacf7b6d488c91` |
| `evidence-digests.tsv` | `99e564d1335f4e635ebe7974e1e3706b78fd33462687bea40c876092ad5eafdc` |
| `first-launch.txt` | `96f2f8333a2e83a4b4ca7bb84eae5cd5672780cf9f9e38d0901eda32c8f7b335` |
| `flush-boundary-state.tsv` | `31680892f211adcc632430947622cc56baddea83dde32e7456a58fb0fe42410a` |
| `generated-before-relaunch.jsonl` | `8444c1382f426194fee5a520b88d5b64d1b787d9d8dab63ec567baf5eb1f6600` |
| `generated.jsonl` | `8444c1382f426194fee5a520b88d5b64d1b787d9d8dab63ec567baf5eb1f6600` |
| `host-timing.tsv` | `13541324d06c51db4e658747fee865917767cf28fcca6d6fec62b3991770f3fc` |
| `http-attempts.jsonl` | `191c45272b9b2952681b281f0799cc48125a526ce8703fc9d80b98a4c069a994` |
| `lifecycle-events-before-relaunch.jsonl` | `6b79eefc470f756a68fd20c309562dbb260dc98b75936f9dccf74a3c9cd40862` |
| `lifecycle-events.jsonl` | `6b79eefc470f756a68fd20c309562dbb260dc98b75936f9dccf74a3c9cd40862` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `af672d1c8e07d5d35f93c7c1e87f62dd4efe680d3cb480e11390f445153aaba0` |
| `received-otlp.jsonl` | `21338bf1ea2e830b5b92f9fba680991e62154bbce4f33e7c20c3b1fd31b553eb` |
| `reconciliation.json` | `25f99ab9340ba1afbca8ba8b3bf3663eacbd161517637c7452d0fe7c771dbc51` |
| `resume-launch.txt` | `42d7a8e98e15aa2dd3d4e8ffde8d11f2929d30790777a31da8b266546ab4a8cc` |
| `run-before-relaunch.json` | `c5d2c45f88cba5234e6888c45a59b18b11b658787430e183980973c38576e504` |
| `run.json` | `c5d2c45f88cba5234e6888c45a59b18b11b658787430e183980973c38576e504` |
