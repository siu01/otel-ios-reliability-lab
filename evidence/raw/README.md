# Raw evidence

Each run receives its own immutable directory. Runtime output is ignored by
default so that an accidental local burst cannot enter Git; a reviewed run is
added explicitly with `git add -f evidence/raw/<run-id>`.

Expected files:

- `received-otlp.jsonl`: OTLP JSON lines emitted by the Collector file exporter.
- `collector.log`: Collector lifecycle, error, and batch summaries.
- `generated.jsonl`: app-side sequence ledger, added after exporter integration.
- `environment.json`: exact runtime and configuration manifest.
- `reconciliation.json`: deterministic generated-versus-received report.

Raw files are never edited after capture. Corrections create a new run ID.

