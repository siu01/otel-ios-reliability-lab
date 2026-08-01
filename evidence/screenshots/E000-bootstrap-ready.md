# E000 bootstrap-ready screenshot

- Captured: 2026-08-01 20:30 Asia/Tokyo
- Source commit: `86ac356`
- Experiment state: bootstrap UI, before exporter integration
- Device: iPhone 17 Simulator
- Runtime: iOS 26.4.1
- UDID: `72FAE57E-1A63-4BF7-A20E-8C1C23C294E9`
- Bundle ID: `dev.siu01.otel-reliability-lab`
- SHA-256: `802ab98823c908ebbc4a488c1a5f378f93adae6571171f4267a08c9f6adb30ba`

## Capture command

```shell
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcrun simctl io 72FAE57E-1A63-4BF7-A20E-8C1C23C294E9 \
  screenshot evidence/screenshots/E000-bootstrap-ready.png
```

## Supports

- The generated app launches successfully.
- HTTP/gRPC and persistence choices are represented in the controller UI.
- The UI explicitly distinguishes a dry run from experiment evidence.

## Does not support

- Any claim that spans are emitted or delivered.
- Any transport or persistence comparison.
- Any physical-device behavior claim.

