# Native Collector

The lab uses the official macOS arm64 `otelcol` 0.157.0 binary. Docker is not a
prerequisite on the bootstrap host.

Install and checksum it with:

```shell
scripts/install-collector.sh
```

The binary and archive live under `collector/bin/` and are intentionally ignored.
The installer pins both the release and the official SHA-256 digest.

Why `otelcol` rather than `otelcol-contrib`: release 0.157.0 of the core
distribution already contains the OTLP receiver, file exporter, batch processor,
and health-check extension needed by this lab. The smaller dependency keeps the
initial environment easier to reproduce.

