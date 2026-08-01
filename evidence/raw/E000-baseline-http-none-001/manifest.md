# E000 baseline HTTP/no-persistence attempt 001

- Outcome: Infrastructure failure before OTLP receivers started
- Date: 2026-08-01
- Collector: `otelcol` 0.157.0 darwin arm64
- Source branch: `agent/initial-lab`
- Collector log SHA-256: `82c214ace29be45dac0a8810a6b986f83822d82423bed1befcb81717cacabec7`

The Collector was launched inside the managed sandbox. Initialization failed
because its default internal Prometheus metrics endpoint could not bind
`127.0.0.1:8888` (`operation not permitted`). No app run was started and no OTLP
capture file was created.

This run ID is intentionally retained and will never be reused.

