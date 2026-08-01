# E010 safe-chunk recovery figure

Source: the four accepted E010 runs and their direct E009 comparators. The only
relevant configuration intervention was changing `maxExportBatchSize` from 256
to 100; payload, schedule window, lifecycle action, persistence preset, exporter,
stop mechanism, and restart procedure stayed fixed.

| Persistence | Planned | Batch 256 received | Batch 100 received |
|---|---:|---:|---:|
| default | 500 | 0 | 500 |
| default | 1,000 | 232 | 1,000 |
| instant | 500 | 0 | 500 |
| instant | 1,000 | 232 | 1,000 |

At batch size 100, five or ten encoded persistence objects fit beneath the
256-KiB object limit and were appended to one file. Resume flattened that file
into one OTLP request, so smaller storage objects did not increase the observed
transport request count.

The SVG is the editable source. The 1200 × 675 PNG was rendered with headless
Chrome and visually inspected before commit. The safe batch count is scoped to
this payload; varying attribute size moves the byte boundary.

## SHA-256

- SVG: `3d734e4114dad1d0b1eb8a0f13a468e4bb99b994712b698fa3fab880bd0aa7c1`
- PNG: `d688cb291663ae1d94ea6c93d034a8a79370d0aaaa13edace81e95736ef92681`
