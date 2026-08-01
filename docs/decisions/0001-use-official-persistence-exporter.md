# ADR 0001: Test the official persistence exporter before building one

- Status: Accepted
- Date: 2026-08-01

## Context

The initial concept assumed that a custom disk-backed span exporter would be
needed. Dependency inspection found that `opentelemetry-swift` 2.5.0 already
ships `PersistenceSpanExporterDecorator`.

Its stated use case exactly matches this lab: telemetry generated without stable
connectivity can be written to disk, then picked up after connectivity returns or
the application relaunches.

## Decision

Use the official persistence decorator as the first durable configuration.
Compare it with the standard non-persistent exporters before proposing custom
code.

Pin the initial investigation to:

- `opentelemetry-swift` 2.5.0, tag commit
  `9a6d6a8aed22c415bb1673206e337824635f818b`.
- `opentelemetry-swift-core` 2.5.1, tag commit
  `06f8a460a66f813758d22f09025d85df45450a63`.

## Consequences

- The article becomes a verification of an existing implementation, not a
  reinvention presented as a necessity.
- A custom implementation is allowed only if a documented experiment exposes a
  gap that cannot be fixed by configuration.
- Any discovered defect should be reduced to a minimal reproduction suitable for
  an upstream issue or pull request.

