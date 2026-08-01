# E007 instant durability barrier, attempt 001

- Outcome: Accepted exact-recovery barrier comparison
- Date: 2026-08-01
- Barrier implementation commit: `c74c0e1`
- Host runner commit: `1b0ecfd`
- Plan commit: `b08e47e`
- Run ID: `00000000-0000-0000-0007-000000000004`
- Device: iPhone 17 Simulator, iOS 26.4.1
- Persistence: official instant
- Flush: provider plus top-level exporter durability barrier
- Exporter: lab stateless OTLP/HTTP
- Stop: direct `SIGKILL` after observing flush completion

## Flush and boundary observation

The monotonic barrier duration was 88,318,209 ns (88.32 ms). One complete
107,794-byte file was visible before the signal and remained after termination.

Attempt 1 sent 27,818 bytes while the Collector was unavailable and completed
with connection refused before the flush-completed event. After relaunch,
attempt 2 sent the same body and succeeded. Reconciliation found all 100 spans
exactly once, and lifecycle plus generation evidence remained unchanged.

The instant barrier was 14.28 ms longer than the instant provider-only run in
this one comparison. Both modes already had a complete file at the host check,
so the barrier added an immediate failed delivery attempt without improving the
observed recovery count.

## Reconciliation

- Unique generated: 100
- Unique received: 100
- Duplicate receipts: 0
- Missing receipts: 0
- HTTP attempts: failure in first process, success in resumed process
- Persistence files after termination: 1
- Persistence files after resume: 0

## SHA-256

| File | Digest |
|---|---|
| `collector.log` | `9abbbeb526ced748af3e437982b6d655cd73cb5c13825c99b24d82453de7da40` |
| `evidence-digests.tsv` | `babf5ac14a83015cd9ed7816f655b5630fa8aaf8b1c222da6ce625a34cc15b7f` |
| `first-launch.txt` | `036403032db5368a2e49f45d8ea246dfce77794637af7dc63ee5f5d39e8beb3a` |
| `flush-boundary-state.tsv` | `96b5506e7aef00cfafbad454b508a998c35d3b5384be5b7f5a4f981931a54fe9` |
| `generated-before-relaunch.jsonl` | `98214067ae4f11170c27119250d309bbd784b8f7e91c8986cdd891c550078552` |
| `generated.jsonl` | `98214067ae4f11170c27119250d309bbd784b8f7e91c8986cdd891c550078552` |
| `host-timing.tsv` | `bc3146e1af6a67e33852f657bcddfd014ac148a5cf3902c4da68f82124be5c1c` |
| `http-attempts.jsonl` | `61a181d599a1eee5c84f43e1b3404df14ae3a38022c6c68c9a10212afac82924` |
| `lifecycle-events-before-relaunch.jsonl` | `db430cf81750127d6342d2f4c39c16da3e120722aadd45fc2f929b0f00fc5527` |
| `lifecycle-events.jsonl` | `db430cf81750127d6342d2f4c39c16da3e120722aadd45fc2f929b0f00fc5527` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `84abacbc008ef4ca65242c47e4d9b8bef6c46e9fe93f4639c7bc163378853520` |
| `received-otlp.jsonl` | `c754c016ee0cf721c8ffb56235ec769f695d18946344810d8ee7797e08fc91e4` |
| `reconciliation.json` | `f3e13f0c4b75a4f11fa9ab5eed91ef096f7a2da09a29a2075276b26e9e5409d9` |
| `resume-launch.txt` | `a9f5c49e3d580e126cbbeca7ba67d42f2d4c245150d0da01edea0c3a589b83a8` |
| `run-before-relaunch.json` | `2219cab5e59beda27765c00167fc54dc5b405825677f5fa5dbb9c6e25470d863` |
| `run.json` | `2219cab5e59beda27765c00167fc54dc5b405825677f5fa5dbb9c6e25470d863` |
