# E006 default 150-millisecond sharp stop, attempt 001

- Outcome: Accepted zero-recovery boundary run
- Date: 2026-08-01
- Host runner commit: `3d60a94`
- Protocol amendment commit: `19502df`
- Plan commit: `31bc197`
- Run ID: `00000000-0000-0000-0006-000000000004`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default; explicit flush disabled
- Exporter: lab stateless OTLP/HTTP
- Trigger: complete 100-record ledger plus 150 ms
- Stop mechanism: direct `SIGKILL` to Simulator app PID 45096

## Boundary observation

The ledger was observed at 13:30:32.674Z, the signal was requested at
13:30:32.855Z, and the post-signal timestamp was 13:30:32.864Z. The observed to
requested interval was 181 milliseconds, including the registered wait and
host instrumentation.

No persistence file existed before or after termination. Resume made no HTTP
attempt and received zero spans. The generated ledger and metadata remained
byte-identical. The 100-span batch therefore remained unrecoverable at this
host-observed offset; there was no partial sequence recovery.

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
| `boundary-state.tsv` | `8d434226ea24468da8757989c26609192a328fdd06fd57b1ee949ad0e420a20c` |
| `collector.log` | `18e4010b2a272cb9023353f3c89c39d44614e32b7f75f1e7a332543407f8e687` |
| `evidence-digests.tsv` | `13307bca778e724b3c4073d143e6273fce2b814e28d980b6eaa54839d11a4c8a` |
| `first-launch.txt` | `d75f608c148d47eadae90ce76840cfe30c3e8fa646332873308f72170d8eb02a` |
| `generated-before-relaunch.jsonl` | `311db635b0dadea2f763d0c5c8de7fc162924b14d41d20fac6950463b76e4e62` |
| `generated.jsonl` | `311db635b0dadea2f763d0c5c8de7fc162924b14d41d20fac6950463b76e4e62` |
| `host-timing.tsv` | `bb6fc9028140bba07fedcf17894517212bdf3111f8a5fc4a8f802fe3a3b8d8c4` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `906a93c39689a4b152e26e037ab1d5d154466accf9eacd3a86950e7ad491f61e` |
| `resume-launch.txt` | `73a76b4a00fdfd0be25a89b71264845fa48353e0f0644d33cf3c8018ef8b35ce` |
| `run-before-relaunch.json` | `3da2ad3c2e56460505c28a5881a989c61f707f6caccabf67bcf90f27177c6f98` |
| `run.json` | `3da2ad3c2e56460505c28a5881a989c61f707f6caccabf67bcf90f27177c6f98` |
