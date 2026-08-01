# E016 main-queue delay figure

Source: all four accepted E016 main-queue probe runs.

Each row shows the provider `forceFlush` duration followed by the additional
delay until a closure that was already enqueued on `DispatchQueue.main`
executed. The total bar is therefore the measured queued-work delay, not a sum
of independent benchmarks.

All conditions recovered 500/500 with no duplicates. The figure emphasizes the
two preregistered failures: every run had more than 100 ms beyond the provider
call, and the Instant binary condition resumed queued work after 1,271 ms even
though its provider call completed in 968 ms.

The SVG is the editable and currently referenced article source. It passes XML
validation. A PNG rendering was intentionally not committed in this step:
headless Chrome required an external execution approval, and the approval
service reported its usage limit before launch. The SVG was not visually
rendered under that condition, so visual QA remains explicitly pending.

## SHA-256

- SVG: `d5e640dabe19e28250de1a8c64f1a22d147cb981bad04c18e38e80caccbe5429`
- PNG: pending approved render and visual inspection
