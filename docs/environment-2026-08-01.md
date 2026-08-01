# Bootstrap environment — 2026-08-01

## Host tools

| Component | Observed version |
|---|---|
| macOS architecture | arm64 |
| Xcode | 26.5 (17F42) |
| Swift | 6.2.4 |
| XcodeGen | `/opt/homebrew/bin/xcodegen` |
| GitHub CLI | 2.89.0 |
| Docker | Not installed |

`xcodebuild` requires `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
because the active command-line developer directory points to Command Line Tools.

## Simulator selected for the first milestone

- Device: iPhone 17
- Runtime: iOS 26.4
- UDID: `72FAE57E-1A63-4BF7-A20E-8C1C23C294E9`

The repository must not treat simulator lifecycle behavior or resource usage as
equivalent to physical-device behavior.

## Tooling constraint discovered

Docker is unavailable. Collector experiments will use a pinned native
`otelcol-contrib` binary and checksummed download rather than making Docker a
prerequisite.

## Publishing constraint discovered

The GitHub CLI account `siu01` was present but its token was invalid at bootstrap.
Local work continues, while remote creation and push wait for reauthentication.

