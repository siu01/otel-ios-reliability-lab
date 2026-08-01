# E011 instant 1,536-byte payload, attempt 001

- Outcome: Accepted oversized-object loss
- Date: 2026-08-02
- Plan commit: `330beb3`
- Payload metadata commit: `7097952`
- App payload commit: `24c5218`
- Runner commit: `bba1c24`
- Run ID: `00000000-0000-0000-0011-000000000003`
- Persistence: official instant
- Spans / max export batch: 100 / 100
- Payload attribute bytes per span: 1,536

The background event occurred 1.931075840 seconds after ledger commit. Provider
flush reported completion in 48.876167 ms, but no persistence file existed
before or after direct `SIGKILL`. Resume made no HTTP attempt and recovered
0/100; all 100 sequences were missing with no duplicates. Evidence digests
remained stable.

The only workload difference from the accepted 1,024-byte run was 512 more
ASCII bytes per span. Keeping the same 100-span count while moving from a
213,715-byte fitting file to no file demonstrates that E010's safe count was
payload-dependent.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `ebf129880048462f6bc4d63983c420ca5a49fee2f4532e100fb545a0617671d6` |
| `background-boundary-state.tsv` | `1bce6298586b40d52d65512160ff027501e63711880d94ceed89165884266fbd` |
| `collector.log` | `08ea83c56874c2dcad9cdbb706da729eb6307afecfc9236a3031843e38df0d32` |
| `evidence-digests.tsv` | `db56e29b252eb23f382c05bb216ddeb0e4ba92b6b050fbfe54e1c805e4863ce7` |
| `first-launch.txt` | `4ee081beb86ca7b2d0567cfceb86aae00c436e43d58d5dab3699c935fa50f150` |
| `generated-before-relaunch.jsonl` | `a68f481fe4cc98ab53642bcab980253a82adadb05f63f55edb23c68035733803` |
| `generated.jsonl` | `a68f481fe4cc98ab53642bcab980253a82adadb05f63f55edb23c68035733803` |
| `host-timing.tsv` | `52a3512654919c83631b2e042c43c886eb66e27e537af75cfdc30461f394a1ca` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `19bb76684206e1b3eb5d371b198d0b40b9ba484ff38024801bd0fb76d2053afd` |
| `lifecycle-events.jsonl` | `19bb76684206e1b3eb5d371b198d0b40b9ba484ff38024801bd0fb76d2053afd` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `0863436c95c0d053d6d9c0da1016708107b30b4615e66f272038f068546cf79c` |
| `resume-launch.txt` | `7073e2f2d2532f59a0b5cb99806b9e952aa0400dfa45972cf2563739ed86f346` |
| `run-before-relaunch.json` | `2c42e05c31259b4bc1df5ead337cf0546bcce6c64c3af68ce47eba663ef5e933` |
| `run.json` | `2c42e05c31259b4bc1df5ead337cf0546bcce6c64c3af68ce47eba663ef5e933` |
