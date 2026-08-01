# E012 default 1,536-byte payload with batch 50, attempt 001

- Outcome: Accepted complete-recovery intervention
- Date: 2026-08-02
- Plan commit: `e60c6bb`
- Run ID: `00000000-0000-0000-0012-000000000001`
- Persistence: official default
- Spans / max export batch: 100 / 50
- Payload attribute bytes per span: 1,536

The background event occurred 3.243685888 seconds after ledger commit. Provider
flush completed in 119.463875 ms. Two encoded objects fit individually and were
appended to one 264,897-byte file—larger than the 256-KiB per-object ceiling but
below the independent 4-MiB file limit.

Resume sent one 183,618-byte request and recovered 100/100 with no duplicates.
This changed the direct E011 default comparison from 0/100 at batch 100 to exact
recovery at batch 50 without changing total spans or payload.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `222edf3d6e2695502c82d58acfe8911adc3b16f3e959094d3e87ce953b553a5e` |
| `background-boundary-state.tsv` | `5e8d34cdb3b6ef31ed1c008db7a12064c235ed2d090561acbd3901e2a997775e` |
| `collector.log` | `4648fd313d3005a16fb104ad2426d200c7a0d2d96344faec8851d50647155bb0` |
| `evidence-digests.tsv` | `bdb08f68d35afff6a6c74d947d3cca8bc84006e4427d199bc2ebb7c335349111` |
| `first-launch.txt` | `1697dc93b5ea58e5a42f3de0f7794b9e5cd4be89dfcc07a7544679f991be641b` |
| `generated-before-relaunch.jsonl` | `a2be5b7f85bef42731b09df0e0bf91850175ba9315527586de84539cc547af26` |
| `generated.jsonl` | `a2be5b7f85bef42731b09df0e0bf91850175ba9315527586de84539cc547af26` |
| `host-timing.tsv` | `e92922b7b63b514d29d8dc6ad221f256c590e44de7e8f47297f709bebcb481f6` |
| `http-attempts.jsonl` | `6450cbf47a383d1d3f0973df03f7717a07e4605142fb87cad1ae41d7d43013fb` |
| `lifecycle-events-before-relaunch.jsonl` | `af790fee6ff1c62bfd46cecac6db047247bb55276574728bcb2697f0e112a371` |
| `lifecycle-events.jsonl` | `af790fee6ff1c62bfd46cecac6db047247bb55276574728bcb2697f0e112a371` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `517a858a360b59a0a15b0eac68c95221265911ed31c7d53c502dfc95ed8dc770` |
| `received-otlp.jsonl` | `d71d32e7a7d99ee234b65d57e0ff82196921428fa7534939eaff5c5817b3f8a4` |
| `reconciliation.json` | `c9752793477ca6fd8854337fe0b389ddbf7e477680e1e89a10fd3d02b8a7e7cd` |
| `resume-launch.txt` | `f0b4701b0b1c365a74afb04450a8f8dfcac1d93c81a36895baa466be000a36ba` |
| `run-before-relaunch.json` | `245393629d15e00f94a668973c2f9cac02a2ae06a3f6d5df3ccba69acff46187` |
| `run.json` | `245393629d15e00f94a668973c2f9cac02a2ae06a3f6d5df3ccba69acff46187` |
