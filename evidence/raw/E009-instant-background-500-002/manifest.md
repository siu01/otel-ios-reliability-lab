# E009 instant 500-span background scale, attempt 002

- Outcome: Accepted complete-loss scale observation
- Date: 2026-08-01
- Scale plan commit: `b75a1ec`
- Control-window amendment commit: `b896b51`
- Boundary-check runner commit: `baf183f`
- Run ID: `00000000-0000-0000-0009-000000000011`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Planned spans: 500
- Flush: provider explicit, triggered by `scenePhase.background`
- Batch schedule delay: 15,000 ms

## Lifecycle observation

The app recorded `backgroundObserved` 3.376347136 seconds after generated-ledger
commit, inside the amended 15-second control window. Provider flush reported
completion after 196.757833 ms, but no persistence file was visible before
direct `SIGKILL` or after termination.

No HTTP record existed in the first process. Resume found no persistence file,
made no HTTP attempt, and recovered 0/500. Generated, run, and lifecycle evidence
remained byte-identical across relaunch.

Pinned-source inspection after this outcome found the same 256-KiB
`maxObjectSize` in both official presets. `BatchSpanProcessor` exported the
500-span list in chunks capped at 256 spans. The encoded chunks exceeded the
object limit; the file writer swallowed the size error, while the persistence
export call still returned success. Instant's synchronous queue did not change
that size policy.

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
| `background-app-launch.txt` | `a7e5b657821e24f1d278fba41e8b84007343d45bbf235011a5bb78472c6b978c` |
| `background-boundary-state.tsv` | `0d690cbf1cf8771fe0fe8a7fb9f27dac818cc991e5fa9228f62bdd862d067475` |
| `collector.log` | `2fc3b5d9df1862671ab58b0d3bb199afbf93724e5ead0d02ff08a923fc890db3` |
| `evidence-digests.tsv` | `e76e2beb8b2002a14f5ee55b96235056d42017c674d17516ed501aa1be8660fe` |
| `first-launch.txt` | `08cc71ef17ac5deb6606491333718b4985971a518e479c592eb16b3721ed9795` |
| `generated-before-relaunch.jsonl` | `0716b153760a919c6c540176c91e02302932b3f6215b89afe28161ea6bd7f363` |
| `generated.jsonl` | `0716b153760a919c6c540176c91e02302932b3f6215b89afe28161ea6bd7f363` |
| `host-timing.tsv` | `d2dae77d5b083078501d339050d32b6cdcca4ab94044660c253230b6d3cfeaa1` |
| `http-attempts.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `lifecycle-events-before-relaunch.jsonl` | `07e778e1a6189d665100fbf078e1c30d4f611c35ae9e02774c5c63971e858852` |
| `lifecycle-events.jsonl` | `07e778e1a6189d665100fbf078e1c30d4f611c35ae9e02774c5c63971e858852` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `received-otlp.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `reconciliation.json` | `670521812a8577e22f7ae33b07de494f51da8a4599386215ef2515fcb573935e` |
| `resume-launch.txt` | `16116838d15dec5953f561ab476f05dbfe16c96fb5940b9c6d2055c18f7bfac3` |
| `run-before-relaunch.json` | `798b8d9ed439405c41753e29c8000bb1feccc7da363bba5060dfdedbd279ee0a` |
| `run.json` | `798b8d9ed439405c41753e29c8000bb1feccc7da363bba5060dfdedbd279ee0a` |
