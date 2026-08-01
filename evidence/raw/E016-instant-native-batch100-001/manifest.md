# E016 instant SDK-native main-queue probe, attempt 001

- Outcome: Accepted delivery result; overhead hypothesis failed
- Date: 2026-08-02
- Plan commit: `ed08e96`
- Run ID: `00000000-0000-0000-0016-000000000002`
- Persistence: official instant
- Processor batch / object policy: 100 / SDK native
- Payload attribute bytes per span: 0
- Main-queue probe: enabled

The actual background event occurred 1.822760960 seconds after ledger commit,
before the 15-second processor schedule. Provider flush completed in
129.497375 ms. The closure enqueued on the main queue immediately before the
synchronous flush executed after 374.176958 ms, leaving 244.679583 ms beyond
the provider call itself. Like the matched Default condition, this fails the
preregistered under-100-ms overhead hypothesis.

One 539,397-byte persistence file was visible before direct `SIGKILL`. The
first process made no HTTP attempt. Resume sent one 138,591-byte request and
recovered 500/500 generated sequences with no duplicates or unexpected
receipts. Lifecycle, generated-ledger, run, and policy evidence remained
byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `092c3d62d32f21ef8761839ceadc1801b5a0645def59ee003e9076920444458b` |
| `background-boundary-state.tsv` | `3371163406545a84055f547e729d8cddf70ac55c0b9979fccebda9aed7084ca4` |
| `collector.log` | `0219a753e748bf84786dc1b8e914ee8b751c9670ca243bd26b81997d2162daca` |
| `evidence-digests.tsv` | `f2ae729548422df7bc27c6aa46bcbc252e647e7996e49f8b7a49e1c0939450c7` |
| `first-launch.txt` | `7474a2030246dbeadb0cdecd8d9630c379ecb197c4f1e557d6962a0c023d2c87` |
| `generated-before-relaunch.jsonl` | `84150c88466f1bf975c421093f119626ed454ef8d92acf64cc858bd654cc7492` |
| `generated.jsonl` | `84150c88466f1bf975c421093f119626ed454ef8d92acf64cc858bd654cc7492` |
| `host-timing.tsv` | `0c75e7390bba035e1ac0762aa96ed2b9d6947644b7652fbeb3bfd85630111a3e` |
| `http-attempts.jsonl` | `b51c0fa56d216a283faa61ba9ffe922d97c8df809a3a235e619fbf05f63394ca` |
| `lifecycle-events-before-relaunch.jsonl` | `ba8f6f73d46794b5dd84b608ac937d238508a6ebd8f8e6032cbd3a1cfa3484df` |
| `lifecycle-events.jsonl` | `ba8f6f73d46794b5dd84b608ac937d238508a6ebd8f8e6032cbd3a1cfa3484df` |
| `object-policy-events-before-relaunch.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `object-policy-events.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `29d6f148d29ccca56cb6c17204d120eefbff5660ad996125cea66f49508e92af` |
| `received-otlp.jsonl` | `0410b490ff2a042b34a7f3902958e0267f441032ca2cf854e80a5b57616c0550` |
| `reconciliation.json` | `f65c8454a479dc632902f1f452c8776cdade6f326b11db2a501b38dd15deeaeb` |
| `resume-launch.txt` | `0aff291cd79b13fa82ef1e2e364389140e5ce0d86e4861f6c856931f7bcbe339` |
| `run-before-relaunch.json` | `d137c09e6fcb3f525564f3671059bac639399daf86279c719715130c2c649578` |
| `run.json` | `d137c09e6fcb3f525564f3671059bac639399daf86279c719715130c2c649578` |
