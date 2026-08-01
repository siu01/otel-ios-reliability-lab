# E015 instant payload-heavy binary search, attempt 001

- Outcome: Accepted exact and faster intervention
- Date: 2026-08-02
- Plan commit: `2bcbbc5`
- Run ID: `00000000-0000-0000-0015-000000000002`
- Persistence: official instant
- Processor batch / object budget: 100 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 1,536

The actual background event occurred 1.714006784 seconds after ledger commit,
before the 15-second schedule. Binary search preserved E014's partition shape:
98 spans / 259,592 bytes and 2 spans / 5,300 bytes, covering sequences 1...100
exactly once.

Provider flush completed in 135.323875 ms and made one 264,892-byte file visible
before direct `SIGKILL`. Resume sent one 183,618-byte request and recovered
100/100 with no duplicates. Compared with the matched E014 instant linear run at
906.540916 ms, flush duration decreased by 85.1% while delivery and policy
semantics remained unchanged.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `ece2403744de3aa57bf14793248491716baf4d7457519bbda3aee8251af677f3` |
| `background-boundary-state.tsv` | `86d8c0eee51ee179400f83916c27efa516990fdd332434905f1b399940d5b1cc` |
| `collector.log` | `f81a8d47654d836a878604fe59d8af1ab54da71ff5da7ef825a4d697722df0ed` |
| `evidence-digests.tsv` | `4ec771f134fd22a62617ee88226b53c32f2ba5cb7241deeabdd812e340709b80` |
| `first-launch.txt` | `84586c7e1bef696959ac70635432db1661b62187bb9fd83fb98a1bd877a72ac7` |
| `generated-before-relaunch.jsonl` | `3467843c59c506adc9e2c1968875c462d70a0d334d01898bcb73b7c10fed42ad` |
| `generated.jsonl` | `3467843c59c506adc9e2c1968875c462d70a0d334d01898bcb73b7c10fed42ad` |
| `host-timing.tsv` | `346631b50b547f8a9c193a02103ba7730ca651db5725a111c66e4f7dd1645522` |
| `http-attempts.jsonl` | `9e18c5000f472b8cbad93357b4c581c5dad982b55db39ba965a45bd5d2fd64c7` |
| `lifecycle-events-before-relaunch.jsonl` | `8846059ca6df40f7d7e1b13fc8980fef366b7fe4f8cf00993f68b3a7d1f9ab47` |
| `lifecycle-events.jsonl` | `8846059ca6df40f7d7e1b13fc8980fef366b7fe4f8cf00993f68b3a7d1f9ab47` |
| `object-policy-events-before-relaunch.jsonl` | `396f12c408dba42258bf92c8f9ebbf1653bd7aa4f845b79a595398d307619853` |
| `object-policy-events.jsonl` | `396f12c408dba42258bf92c8f9ebbf1653bd7aa4f845b79a595398d307619853` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `2c37195e31aeb3424d3967ebde865900f6abfab9494cb5a956e2b92a93779e24` |
| `received-otlp.jsonl` | `0d998a7f382bd7b7a18a5a21fc1d88c12c492318b206c441f7f594d5fc56a70c` |
| `reconciliation.json` | `c5261bdb409b29e830646f7eff0b589d3aeb56269cecbaa08b15b8413d1acb32` |
| `resume-launch.txt` | `79b4fcaace072320d552213e87a14fa324994d014534cead80083fa87b2cc35a` |
| `run-before-relaunch.json` | `dc66ac1455eab8d8ab42fd0eb6c7fb43afbb172e899e8dc4f6f8ff83c4fa61cc` |
| `run.json` | `dc66ac1455eab8d8ab42fd0eb6c7fb43afbb172e899e8dc4f6f8ff83c4fa61cc` |
