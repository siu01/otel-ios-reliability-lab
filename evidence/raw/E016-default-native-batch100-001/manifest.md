# E016 default SDK-native main-queue probe, attempt 001

- Outcome: Accepted delivery result; overhead hypothesis failed
- Date: 2026-08-02
- Plan commit: `ed08e96`
- Run ID: `00000000-0000-0000-0016-000000000001`
- Persistence: official default
- Processor batch / object policy: 100 / SDK native
- Payload attribute bytes per span: 0
- Main-queue probe: enabled

The actual background event occurred 3.224402944 seconds after ledger commit,
before the 15-second processor schedule. Provider flush completed in
72.964417 ms. The closure enqueued on the main queue immediately before the
synchronous flush executed after 297.103875 ms, leaving 224.139458 ms beyond
the provider call itself. This fails the preregistered under-100-ms overhead
hypothesis and shows that flush duration alone understated the measured queue
delay in this run.

One 539,360-byte persistence file was visible before direct `SIGKILL`. The
first process made no HTTP attempt. Resume sent one 138,591-byte request and
recovered 500/500 generated sequences with no duplicates or unexpected
receipts. Lifecycle, generated-ledger, run, and policy evidence remained
byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `774242714b77f31f2164572c4d74219ad8d50d136638d6257893ed25e67f4de3` |
| `background-boundary-state.tsv` | `86c1ea53bcf97dd5b381828332290ce0bb03644af56183b294e55b0e52699a83` |
| `collector.log` | `392b6edc266c1392c0a030ecc7b0a323bd7966c0d315394473f3d8733bd14947` |
| `evidence-digests.tsv` | `2067b44313b41540105540f02926e86cd0f7759bd961b0c85ca2c865aa43c148` |
| `first-launch.txt` | `26374c1d689ac0c821377428e405a67003548feb7d44fdc34eb07018945424f5` |
| `generated-before-relaunch.jsonl` | `67fdc477ae89dc11ccb165ca3bbac79ea76091825832fe0e9415bde191909c54` |
| `generated.jsonl` | `67fdc477ae89dc11ccb165ca3bbac79ea76091825832fe0e9415bde191909c54` |
| `host-timing.tsv` | `c3c5db05ae231c0b57c8deb6079df986c77c922842560f63a1ddc0e391b7e517` |
| `http-attempts.jsonl` | `6637cdc01f5087e7040c4ffe42df2a133da54f660a81eeb1788450341d4c06c7` |
| `lifecycle-events-before-relaunch.jsonl` | `2b73d579ccb6167e675f3b0565791c2a695b386fef382d8581d1fd7bf39d2f0a` |
| `lifecycle-events.jsonl` | `2b73d579ccb6167e675f3b0565791c2a695b386fef382d8581d1fd7bf39d2f0a` |
| `object-policy-events-before-relaunch.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `object-policy-events.jsonl` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `2a701f8a96a6c04f310fbb5fd02825005369363209c62faf7983371c70ee26a6` |
| `received-otlp.jsonl` | `32e922e5cb6e612517144d26c8239f15d201f049f66971d515c9e4404ea77388` |
| `reconciliation.json` | `9ae861183dee02a27b08fde432a05afc0463b613156e94d76aa0a07f6fea6ed2` |
| `resume-launch.txt` | `50cf15ce7f334822814e44a78e40d97a055392775946ce2029db57dabee5ee01` |
| `run-before-relaunch.json` | `eab1d75e72b502fdea6b57f0a283f97dd9eb9c933c29c6d36b6ef70f21a3d3cf` |
| `run.json` | `eab1d75e72b502fdea6b57f0a283f97dd9eb9c933c29c6d36b6ef70f21a3d3cf` |
