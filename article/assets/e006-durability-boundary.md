# E006 abrupt-stop durability figure

Source: accepted E006 direct-`SIGKILL` runs. The x value is the measured host
interval from first observation of the complete generated ledger to the signal
request. It includes polling and instrumentation overhead and is not an SDK
durability SLA.

| Persistence | Measured interval | File before signal | Recovered |
|---|---:|---|---:|
| default | 14 ms | no | 0/100 |
| default | 55 ms | no | 0/100 |
| default | 73 ms | no | 0/100 |
| default | 181 ms | no | 0/100 |
| default | 331 ms | yes | 100/100 |
| instant | 19 ms | no | 0/100 |
| instant | 328 ms | yes | 100/100 |

The dashed 250-ms `BatchSpanProcessor` schedule-delay line is contextual only;
its clock does not share the chart's host-observation origin. The shaded
181–328 ms region was not sampled by an accepted run.

The bottom annotation preserves the excluded stop-mechanism calibration:
`simctl terminate` took about 471 ms to stop the first process, allowing a file
to appear and recover 100/100 after the request.

The SVG is the editable source. The 1200 × 675 PNG was rendered with headless
Chrome and visually inspected before commit.

## SHA-256

- SVG: `116ef2d229b72dbffad862788e76ad1dbd0d846eb46c0f6c5f62aa0097bb8e06`
- PNG: `cd6d08076625d3e5977d11e1351abcbc3afc928c11c8325f20b4676d4bc88b54`
