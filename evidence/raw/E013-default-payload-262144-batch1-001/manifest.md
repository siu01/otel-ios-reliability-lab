# E013 default 256-KiB single span, attempt 001

- Outcome: Accepted silent-oversize result
- Date: 2026-08-02
- Plan commit: `6eb0975`
- Run ID: `00000000-0000-0000-0013-000000000002`
- Persistence: official default
- Spans / max export batch: 1 / 1
- Payload attribute bytes: 262,144

The actual background event occurred 3.293070080 seconds after ledger commit,
before the 15-second schedule. Provider flush completed in 112.084958 ms, but
no persistence file became visible before direct `SIGKILL` or after resume.

Neither process made an HTTP attempt, and reconciliation recovered 0/1. This
differs from the accepted 240-KiB control by payload size alone and demonstrates
that batch 1 cannot split an individually oversized span.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `26ead13badda232bdc43c5f451ae729f2025a8b45fe4786a3253de9aa71da679` |
| `background-boundary-state.tsv` | `638e38736388b7be5a0ea0427512c55ee13a8723d8df4ca6c6285e5bd97fe106` |
| `collector.log` | `e56bcb8a52a0baf7601bef63955d03ed444c70cd78aac83eb593a85be048c2ab` |
| `evidence-digests.tsv` | `9914c717bb0b34d4543ed07bcaddad4adc30ac3cdd6be106c51f99ec72210e64` |
| `first-launch.txt` | `fd101c24fb59a905b69fe5146b9e494eb7b1930bba47bef94186e17e5f86d048` |
| `generated-before-relaunch.jsonl` | `f22a944c7c511eb5c08a6f3e45390c028eeec7d5c955f0338106562535c6d648` |
| `generated.jsonl` | `f22a944c7c511eb5c08a6f3e45390c028eeec7d5c955f0338106562535c6d648` |
| `host-timing.tsv` | `cfecd3e240f0ddc77d15dd320a67a12d35138d0ad5a6fce527bb7ede5ec3a795` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `da6edaba85a63ce6ef1d29a16ecc27a0f49d4317cf300769152901893fd51c77` |
| `lifecycle-events.jsonl` | `da6edaba85a63ce6ef1d29a16ecc27a0f49d4317cf300769152901893fd51c77` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `a47a9d8414a5b6387a94f0b8e66806c8af6243a3adb11927010d4f5d7d0a13fb` |
| `resume-launch.txt` | `448db91f9d5afea33ba8642bc187f3d0abdc0b9e09d22a99b996f13c7d2d0bb0` |
| `run-before-relaunch.json` | `24fb0d10f2fc25134df50cf4af7f843dfd194a277824ec08eb0d1600ced7ace4` |
| `run.json` | `24fb0d10f2fc25134df50cf4af7f843dfd194a277824ec08eb0d1600ced7ace4` |
