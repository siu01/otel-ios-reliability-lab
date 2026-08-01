# E016 instant binary byte-policy main-queue probe, attempt 001

- Outcome: Accepted exact delivery; queue-delay hypotheses failed
- Date: 2026-08-02
- Plan commit: `ed08e96`
- Run ID: `00000000-0000-0000-0016-000000000004`
- Persistence: official instant
- Processor batch / object budget: 256 / 262,144 bytes
- Partition strategy: binary search encoding
- Payload attribute bytes per span: 0
- Main-queue probe: enabled

The actual background event occurred 1.857213952 seconds after ledger commit,
before the 15-second processor schedule. The binary policy produced the same
four logical partitions as E015: 243 + 13 + 242 + 2. Their measured encoded
sizes were 262,063, 14,033, 261,117, and 2,160 bytes.

Provider flush completed in 968.003625 ms. The closure enqueued on the main
queue immediately before flush executed after 1,271.137125 ms, leaving
303.133500 ms beyond the provider call. This fails both the preregistered
under-100-ms overhead hypothesis and the binary-policy queue-delay bound of one
second. In particular, a sub-second provider duration did not imply a
sub-second measured main-queue delay.

One 539,373-byte persistence file was visible before direct `SIGKILL`. The
first process made no HTTP attempt. Resume sent one 138,591-byte request and
recovered 500/500 generated sequences with no duplicates or unexpected
receipts. Lifecycle, generated-ledger, run, and policy evidence remained
byte-identical across relaunch.

## SHA-256

| File | Digest |
|---|---|
| `background-app-launch.txt` | `474c001e005e742e274c6c7714c2254afe48df17f9c41bc8c483f866d0a92301` |
| `background-boundary-state.tsv` | `0e82e77e44fcc21be53255946a7ed2d4ff6fad5a156e9c0d850eca13cdb4b8ed` |
| `collector.log` | `362524f9728b0b27244a09208f8ee68dbfb744f99b823e27b4d028d628c5c332` |
| `evidence-digests.tsv` | `56ae979ae69ff734cbb3125447f20103596b95e6b247d9fd95907cc428754dc0` |
| `first-launch.txt` | `fcb83901567cec79fce2065d5e47ab6cf4b952e9053067e3ba78b8e56a1f9021` |
| `generated-before-relaunch.jsonl` | `1f300ef8ba0f7555ae53f0f0841aaec8f222dd4ed1af127a39f82069c0b0b603` |
| `generated.jsonl` | `1f300ef8ba0f7555ae53f0f0841aaec8f222dd4ed1af127a39f82069c0b0b603` |
| `host-timing.tsv` | `253dbd27922ff3fb83c0f9f07126eaf250598c9990ef0cf23e119b5b8aabe220` |
| `http-attempts.jsonl` | `4079b159964e4169b3ef59d7baf059266b4f0c0890588b78949feb8f8c0621ff` |
| `lifecycle-events-before-relaunch.jsonl` | `205a53a3954f18fa2ebfe7c7a534c438702dc99be37a68191b4aba258934b0f7` |
| `lifecycle-events.jsonl` | `205a53a3954f18fa2ebfe7c7a534c438702dc99be37a68191b4aba258934b0f7` |
| `object-policy-events-before-relaunch.jsonl` | `950aa6534dedafc808698f8ce7d08f83d3a55484d72fa97adc742c3d1e821217` |
| `object-policy-events.jsonl` | `950aa6534dedafc808698f8ce7d08f83d3a55484d72fa97adc742c3d1e821217` |
| `persistence-files-after-resume.tsv` | `4dd0d816b8dc275d69168fe939cbcf2576aaede7a7a8a507aa01f2438dcb645a` |
| `persistence-files-after-termination.tsv` | `1487f4fb34310b3596c0e9c6e41ba200d36e63b5009c8e6bffbb1873bac1c4b8` |
| `received-otlp.jsonl` | `8aa55c0a75bfe130838f1a21fa5df0b463cd335301a7c04aaa979559189f20cb` |
| `reconciliation.json` | `6ff183ebde64ba397304caed96298fba9eb74fa0387a4a16f324f5fa8360eeae` |
| `resume-launch.txt` | `c9ef146cdd035f5bbd8c0c550cb18c9dd4db46a0aad108bfc2f30d3b6b851d09` |
| `run-before-relaunch.json` | `4ca93a8a6d58cd3526f12926edb847fdf4d8c09e2b17e2cb587b7124516dd82e` |
| `run.json` | `4ca93a8a6d58cd3526f12926edb847fdf4d8c09e2b17e2cb587b7124516dd82e` |
