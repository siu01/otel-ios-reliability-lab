# E012 instant 1,536-byte payload with batch 50, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-02
- Plan commit: `e60c6bb`
- Run ID: `00000000-0000-0000-0012-000000000003`
- Persistence: official instant
- Spans / max export batch: 100 / 50
- Payload attribute bytes per span: 1,536

The background event occurred 5.654656 seconds after ledger commit. Provider
flush completed in 82.216458 ms. Two encoded objects fit individually and were
appended to one 264,891-byte file, even though the combined file is larger than
the separate 256-KiB per-object ceiling.

Resume sent one 183,618-byte request and recovered 100/100 with no duplicates.
This directly recovers the E011 instant 1,536-byte, batch-100 outcome of 0/100
without changing span count, payload, persistence preset, or lifecycle timing.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `0b90de2390ae5245a7b89d6b848ae104b3428cc0396142ade0ead79b94bde409` |
| `background-boundary-state.tsv` | `af4c3941c4c357fe5781438ca496462e3a57fa6a0f3bd5ec84e4add2c920e401` |
| `collector.log` | `42ec646a4022dbb779e18aef3c15208dcce2a42a3487ffa9b5e5e62ea88dbae8` |
| `evidence-digests.tsv` | `fdc94eb1e9150e84d7923a26edc87727c2cc773e3c640953fa1ef5c52bc38004` |
| `first-launch.txt` | `62f165dbf6e6101af6b183d857a68125dc1f781ce5006710ea6c3c6726842805` |
| `generated-before-relaunch.jsonl` | `dafb30cc6a26ffc4d741298af75382f9fd38f937ea8664175e84ee81d0c6d0cb` |
| `generated.jsonl` | `dafb30cc6a26ffc4d741298af75382f9fd38f937ea8664175e84ee81d0c6d0cb` |
| `host-timing.tsv` | `831c1842b42825b910572bacee4afcb8fa1486087a9d590a4c7e92238b2bae04` |
| `http-attempts.jsonl` | `e232f69e6efbec8445b128db68b6dbdd77d8e85af0bf3842292d1acee60f7d1e` |
| `lifecycle-events-before-relaunch.jsonl` | `29d804d0d365ce8c7de71d16d9e3cff416117a54ac40a7c89ba8d4bb3c589db1` |
| `lifecycle-events.jsonl` | `29d804d0d365ce8c7de71d16d9e3cff416117a54ac40a7c89ba8d4bb3c589db1` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `487e5e883f973bfdf4ea8f33048fce3b5332dd526304f2d224e26996f25e70ff` |
| `received-otlp.jsonl` | `0e9a257c6f7ac18e17f199e522fc7803a903c6144217667462687c136d4bb543` |
| `reconciliation.json` | `9e914cce61a632132f5829f278931f2618623f209e39aa4f4bf8c028d68085e4` |
| `resume-launch.txt` | `6e1ea88d5ed5e39bd88cf227264ed189bbd04f6eb562ad192408309a0c47be3f` |
| `run-before-relaunch.json` | `874fd1cd07c9fce3902b005330eca1403114150a756f032d8c40788571763241` |
| `run.json` | `874fd1cd07c9fce3902b005330eca1403114150a756f032d8c40788571763241` |
