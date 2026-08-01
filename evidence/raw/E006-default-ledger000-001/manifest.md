# E006 default zero-offset boundary, attempt 001

- Outcome: Preserved protocol-calibration run; not a sharp-stop comparison
- Date: 2026-08-01
- Host runner commit: `d61b9b5`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000001`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: first observation of the complete 100-record ledger plus 0 ms
- Stop mechanism: `simctl terminate`

## Boundary observation

No persistence file was visible at the host's pre-request check. The termination
request was recorded at 13:19:57.757Z, but `simctl terminate` did not return until
13:19:58.228Z, about 471 milliseconds later. One complete 107,769-byte file was
present after termination.

That file recovered 100 unique spans exactly once after resume. This is valid
evidence that a default asynchronous write can complete while a controlled
termination request is in progress. It cannot locate the vulnerable write
window because the stop mechanism allowed substantially more time than the
registered zero offset.

The run remains part of the audit trail, but later E006 sharp-stop comparisons
use direct `SIGKILL` against the Simulator process ID. A replacement zero-offset
default run is registered in the protocol amendment.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Total received records: 100
- Duplicate receipts: 0
- Missing receipts: 0
- Collector batches: 64 and 36 spans
- HTTP attempts after resume: one 27,818-byte success
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `boundary-state.tsv` | `bfc05274b3384b50cd87e543b3bd7250409a1527e7b872cbdf8416b1ef716f91` |
| `collector.log` | `eabb154fe772764b905485e2f1d955d5b38f9c4b1e6f0403b559fd972d89a554` |
| `evidence-digests.tsv` | `0214e780ef1ed6e0bbf549d563b0cd1b3a8faff652dbd905f2162bd497c69231` |
| `first-launch.txt` | `f11e2912a74acc50f3c3c9a791f65ee9b41e21fb5b2cf9e9aee31a0794c456bd` |
| `generated-before-relaunch.jsonl` | `f9db59f48866afce379e67fd1ba13bc9b5d0b91c614c560cb39e09df99ff3749` |
| `generated.jsonl` | `f9db59f48866afce379e67fd1ba13bc9b5d0b91c614c560cb39e09df99ff3749` |
| `host-timing.tsv` | `c106aad1df19af20b8d8eb6fa83d5825feb4c80796d2a2f247fead50695c4a60` |
| `http-attempts.jsonl` | `e5716a630040923acaeb678d7c08611f6a62d982cde8274e2b83135355d82780` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `68472113f218970a8dda2f93f32506bd193297c669ceef58c380553df6c85083` |
| `received-otlp.jsonl` | `6d93dc4e0b9a189d3357d9967130ddd6186a76a6af9bf4385b74a3d34b603cad` |
| `reconciliation.json` | `8f0a203c9d56bc221841707367b92cfb6a91eaaa429032a13f6b21125cd2b839` |
| `resume-launch.txt` | `1d1c682b3933a22e0e4c7b8354ae589708daadc4871b3608fb8c812bff93ba5d` |
| `run-before-relaunch.json` | `23921cd8ae65dbecb9a17f23db0e66ad275bd9576cd7cda291218f822da94ddb` |
| `run.json` | `23921cd8ae65dbecb9a17f23db0e66ad275bd9576cd7cda291218f822da94ddb` |
