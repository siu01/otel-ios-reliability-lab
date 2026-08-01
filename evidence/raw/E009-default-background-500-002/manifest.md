# E009 default 500-span background scale, attempt 002

- Outcome: Accepted complete-loss scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000008`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official default
- Planned spans: 500
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 4.912497152 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush reported
completion after 167.324750 ms, but no persistence file was visible before
direct `SIGKILL` or after termination.

No HTTP record existed in the first process. Resume found no persistence file,
made no HTTP attempt, and recovered 0/500. Generated, run, and lifecycle evidence
remained byte-identical across relaunch.

This is an accepted negative result, not a runner failure. Pinned-source
inspection after the instant run produced the same outcome found a
preset-independent cause: both presets cap one encoded object at 256 KiB. The
500-span list was exported in 256- and 244-span chunks; neither encoded object
fit. The writer swallowed each size error while the outer exporter still
reported success, so provider force-flush completed with nothing durable.

## Reconciliation

- Unique generated: 500
- Unique received: 0
- Duplicate receipts: 0
- Missing receipts: 500
- Persistence files after termination and resume: 0
- HTTP attempts across both processes: 0

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `794b1685ee30093558a239ac7776e6e54affcfc50087f4e180e8f8648b960032` |
| `background-boundary-state.tsv` | `9cd396697dd940f61852db1636bda1b1cdfee2145c79bf6af3ac15463bc72df2` |
| `collector.log` | `5dc9165902bf1679bc79bc5abd3ead061f9ac79de9129101860c1c2fce1b4cf7` |
| `evidence-digests.tsv` | `addde1af653f5cb9b3fe86dea87eaabdacc0159c86939ba9b912822c49bec51e` |
| `first-launch.txt` | `b96f226d77c9d0841828f6b1a0df1ef8013995bb220e6fe3c8d18597b60e1ae0` |
| `generated-before-relaunch.jsonl` | `9634ee3a70bbcb4b8d5e38ba247640820eea04f57ab9e43217eb1432d6288ff9` |
| `generated.jsonl` | `9634ee3a70bbcb4b8d5e38ba247640820eea04f57ab9e43217eb1432d6288ff9` |
| `host-timing.tsv` | `fb57922001086c55e5955c5236ea162d63fe225745f4be14fbfad4ec880fa3d5` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `9de0b5df1c415a4c3e5da244feca6f9edbb36f75ad0f2cd7cce13b1560af6b42` |
| `lifecycle-events.jsonl` | `9de0b5df1c415a4c3e5da244feca6f9edbb36f75ad0f2cd7cce13b1560af6b42` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `e45a825867f4d427949202d9b983d6a882e23543f19bca4555f2a4ac54a8022b` |
| `resume-launch.txt` | `90d19e4176b8766bd5c9abca4bf4f0a52b6b8b94585a2695acf5ace4b1cbcc0c` |
| `run-before-relaunch.json` | `6c65c9abb981b2be273b22e527107b423affdf1500105b7c3235971c9940de65` |
| `run.json` | `6c65c9abb981b2be273b22e527107b423affdf1500105b7c3235971c9940de65` |
