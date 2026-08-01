# E013–E015 byte-policy figure

Source: accepted E013 single-span boundary runs, all six E014 linear byte-policy
runs, and all four E015 binary-search runs.

The recoverable panel compares native persistence's matched 0/100 and 0/500
outcomes with the byte policy's exact 100/100 and 500/500 outcomes. The policy
kept the processor batches at 100 and 256, measured the pinned persistence JSON
shape, and forwarded only objects at or below 262,144 bytes.

The indivisible panel is intentionally not labeled a delivery recovery. A
256-KiB single-span payload remained 0/1, but the policy recorded sequence,
span ID, actual encoded bytes, and budget before returning failure instead of
allowing the SDK writer to lose it without a local reason.

The cost panel uses the default 500-span matched comparison: linear prefix
encoding took 7,035.96 ms; binary search preserved the four objects and 500/500
delivery in 520.24 ms. The other three E015 comparisons improved by 85.1–92.4%.

The SVG is the editable source. The 1200 × 675 PNG was rendered with headless
Chrome and visually inspected before commit.

## SHA-256

- SVG: `4225902ca688f65a1450b4dae6a1b00f23d146aac9a3f3c2b6786e0c6a25947a`
- PNG: `7becb19341f74e838a300064fdbb6f653e9b058505d4b97afde51571dba87f91`
