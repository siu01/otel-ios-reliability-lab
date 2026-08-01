# E015 instant 500-span binary search, attempt 001

- Outcome: Accepted exact and faster intervention
- Date: 2026-08-02
- Plan commit: `2bcbbc5`
- Run ID: `00000000-0000-0000-0015-000000000004`
- Persistence: official instant
- Processor batch / object budget: 256 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 0

The actual background event occurred 2.140339200 seconds after ledger commit,
before the 15-second schedule. Binary search preserved the four-object E014
shape and exact sequence coverage:

| Call | Sequences | Spans | Encoded bytes |
|---:|---|---:|---:|
| 1 | 1...243 | 243 | 262,092 |
| 1 | 244...256 | 13 | 14,023 |
| 2 | 257...498 | 242 | 261,124 |
| 2 | 499...500 | 2 | 2,157 |

Provider flush completed in 540.420084 ms and made one 539,396-byte file
visible before direct `SIGKILL`. Resume sent one 138,591-byte request and
recovered 500/500 with no duplicates. Compared with the matched E014 instant
linear run at 4,500.461625 ms, flush duration decreased by 88.0% and satisfied
the preregistered two-second bound.

The policy-event file remained byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `9ce7a416c6243426d3f0fbd7af7177201683ba8d6a7e041cffba28331c4ab03a` |
| `background-boundary-state.tsv` | `ca7a47271ae2ccac3db96d28c629b7889944291b680d711e37b571050fa06a30` |
| `collector.log` | `ab61adbf1d61504ec941f002985a848d112f5aa006b0d9c40f9a5149d75a0827` |
| `evidence-digests.tsv` | `b243279d8730c7a57c7781f2419219e6fbbcb2668d78d23e721f0dfb2b028261` |
| `first-launch.txt` | `015bf79e541e5afff1c3bcd8eb0ab7b4c3d14bca88a5d1f43a2e6f7b35ef7ce9` |
| `generated-before-relaunch.jsonl` | `7c1d81e39e1fa1acd7e7e0ec88b4a5603bd8ee0df5da2ba5cf46bb6088d69964` |
| `generated.jsonl` | `7c1d81e39e1fa1acd7e7e0ec88b4a5603bd8ee0df5da2ba5cf46bb6088d69964` |
| `host-timing.tsv` | `a4a4214d8ac6d618336fcd08f36fe0389f77ee6370d83b3d79e21215d2b776ed` |
| `http-attempts.jsonl` | `f917befc93a7faf5a245e1a6a225f667493094771fcf09da70e8efe0f0a85cb5` |
| `lifecycle-events-before-relaunch.jsonl` | `ebfb797eff5f81c6a09dcc20fafd310a85c70246463e36bc469fd08f820d3c24` |
| `lifecycle-events.jsonl` | `ebfb797eff5f81c6a09dcc20fafd310a85c70246463e36bc469fd08f820d3c24` |
| `object-policy-events-before-relaunch.jsonl` | `c0760cae75f5fe537bac343736842ab94bdaedb858a8d14513ed4cb127987900` |
| `object-policy-events.jsonl` | `c0760cae75f5fe537bac343736842ab94bdaedb858a8d14513ed4cb127987900` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `8570811910b413a6a027effc3a75b7e1f5a2f735ea20986e92d18bc915ecdbb0` |
| `received-otlp.jsonl` | `879825d0fcad24917b04a2f952fda9908ff0a46fce78cc7d0783eb1ecf96cca8` |
| `reconciliation.json` | `5493e4f3d1a8105a195d3267ce19edc7b46f5a179ee3b579b48ce7722be55c44` |
| `resume-launch.txt` | `bb3ec87fb827882fba545d2c1daf53fd7f8c02a9cda612bc0210b9a5a35a51a7` |
| `run-before-relaunch.json` | `f50be1c50dc77cf95859f9118564dcfe23ce955535c1d50b197e6edc2424128f` |
| `run.json` | `f50be1c50dc77cf95859f9118564dcfe23ce955535c1d50b197e6edc2424128f` |
