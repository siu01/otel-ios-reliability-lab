# E009 silent object-size loss figure

Source: the six accepted E009 runs after the lifecycle-window amendment. Default
and instant produced identical delivery counts at each workload, so the figure
shows one shared outcome series.

| Planned spans | Default received | Instant received | Surviving sequence range |
|---:|---:|---:|---|
| 100 | 100 | 100 | 1...100 |
| 500 | 0 | 0 | none |
| 1,000 | 232 | 232 | 769...1,000 |

The chunk diagram follows pinned `BatchSpanProcessor` source and the lab's
`maxExportBatchSize=256`: 500 becomes 256 + 244, while 1,000 becomes 256 + 256
+ 256 + 232. Pinned persistence source caps a single encoded object at 256 KiB
for both presets and swallows the writer's oversize error.

The diagram labels oversized chunks from the combined source-and-evidence
inference. The surviving 232-span persistence files were 250,297 and 250,307
bytes and decoded into exactly the final 232 sequences. The exact safe span
count is payload-dependent because the internal ceiling is bytes, not items.

The SVG is the editable source. The 1200 × 675 PNG was rendered with headless
Chrome and visually inspected before commit.

## SHA-256

- SVG: `64d6b38b4864c6441ea811f640fabe735ff5e5003cdffbff5c6a735941fcb2eb`
- PNG: `a522dfb52a242bb2e04809a8e142451aa9faced81d36248e401126f79947725b`
