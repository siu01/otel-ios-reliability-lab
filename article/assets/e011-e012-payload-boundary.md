# E011/E012 payload-boundary figure

Source: the six accepted E011 payload-boundary runs and four accepted E012
matched interventions. E011 kept 100 total spans and `maxExportBatchSize=100`;
changing `lab.payload` from 1,024 to 1,536 bytes moved both persistence presets
from exact recovery to zero. The 2,048-byte instant condition repeated the loss.

E012 kept the 100 total spans, 1,536- or 2,048-byte payload, persistence preset,
background callback, schedule boundary, abrupt stop, and resume procedure fixed.
Changing only `maxExportBatchSize` from 100 to 50 restored 100/100 with no
duplicates for both payloads and both presets.

The 50-span objects were individually below the 256-KiB object ceiling and were
appended into one file, then flattened into one request on resume. This figure
does not present 50 as a universal safe count; it shows a matched mechanism
intervention and motivates a byte-aware production policy.

The SVG is the editable source. The 1200 × 675 PNG was rendered with headless
Chrome and visually inspected before commit.

## SHA-256

- SVG: `f8024777e0dbf52ac5c6adb65672cbe239c83bbad5d49db773d81ca11480ca0d`
- PNG: `fdc425e9ffdfaf62f1e8236547ea0dc95b23927f6648cfd570c7571bfe75f0e5`
