# E008 real-background flush figure

Source: all four accepted E008 runs. The left panel combines the default and
instant no-flush controls; both reached a real SwiftUI background event before
the five-second processor schedule, had no persistence file, and recovered
0/100 after abrupt restart.

The right panel combines the registered provider-flush interventions. The app
recorded flush completion in 45.323542 ms for default and 51.393083 ms for
instant. Both had one persistence file before direct `SIGKILL` and recovered
100/100 exactly once after relaunch.

| Persistence | Background action | Flush duration | File before stop | Recovered |
|---|---|---:|---:|---:|
| default | no flush | — | 0 | 0/100 |
| instant | no flush | — | 0 | 0/100 |
| default | provider flush | 45.32 ms | 1 | 100/100 |
| instant | provider flush | 51.39 ms | 1 | 100/100 |

The timeline is explanatory rather than a proportional time axis. The SVG is
the editable source. The 1200 × 675 PNG was rendered with headless Chrome and
visually inspected before commit.

The figure is scoped to the iPhone 17 Simulator on iOS 26.4.1. It does not
claim a real-device suspension or jetsam guarantee.

## SHA-256

- SVG: `3f485b40c63bfdeaa35f5cd1760e455cb9e790beb9aa21c7cc7ae92ea1d19772`
- PNG: `5686fe67587d5b1d6adfcd56300d12abf656f078225348754bbafac46a806dfa`
