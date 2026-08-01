# Reproduction guide

## Pinned environment

The committed runtime evidence used:

- macOS host with Xcode and iPhone 17 Simulator, iOS 26.4.1;
- `opentelemetry-swift` persistence 2.5.0;
- `opentelemetry-swift-core` 2.5.1;
- OpenTelemetry Collector 0.157.0, Darwin arm64; and
- loopback OTLP/HTTP JSON on port 4318.

`project.yml`, Swift package pins, Collector config, run manifests, and raw
digests are the sources of truth. Generated Xcode project data and downloaded
binaries are intentionally ignored.

## Repository-only verification

These checks do not need an iOS Simulator:

```sh
scripts/test-core.sh
scripts/test-evidence-verifier.sh
scripts/verify-all-evidence.sh
scripts/audit-claim-index.sh
```

Expected provenance totals at the E021 commit are 21 indexed experiments, 17
runtime-complete, two runtime-pending, two model-complete, 75 verified raw runs,
and 1,142 verified raw files.

The synthetic cost probes are deterministic:

```sh
scripts/run-partition-cost.sh 500 1024 262144
scripts/run-payload-order-cost.sh 20 143360 102400 262144 \
  alternatingPrimarySecondary
scripts/run-processor-boundary-cost.sh 500 1024 262144 256
```

They validate exact JSON representations used by their own models. They are not
substitutes for actual `SpanData` runtime evidence.

## Simulator build

Generate and build with:

```sh
scripts/generate-project.sh
scripts/build-simulator.sh
```

Xcode needs access to CoreSimulator and SwiftPM caches. A sandbox denial before
compilation is an environment failure and should be recorded separately from a
Swift compile failure.

The default registered device UUID can be overridden without editing scripts:

```sh
export LAB_SIMULATOR_UDID=<simulator-uuid>
```

Changing device or OS creates a new experimental condition; do not append its
result to an existing run manifest as if it were matched evidence.

## Collector and runtime evidence

Install the pinned Collector once:

```sh
scripts/install-collector.sh
```

Each experiment directory contains its exact command matrix and exclusion
rules. Always commit the plan before implementation or execution. Runtime
runners refuse to overwrite an existing evidence directory.

After capture:

1. inspect lifecycle, HTTP, persistence, and reconciliation artifacts;
2. write a manifest that explains inclusion/exclusion and lists every digest;
3. run `scripts/verify-evidence-run.sh evidence/raw/<run-id>`;
4. force-add the intentionally ignored raw directory; and
5. update result, notebook, README, article, and claim state only to the level
   supported by evidence.

## Current deferred work

E017 and E018 have core/model results but registered Simulator matrices are
pending. Their claim-index state must remain `runtimePending` until app build,
raw manifests, and reconciliation are committed.

The E016 article SVG is committed and XML-valid. PNG rendering and visual QA are
pending because the headless browser execution approval stopped before launch.
Do not claim that inspection occurred until the PNG, digest, and QA note exist.

## External publication anchor

Local manifests detect partial corruption but not coordinated data-plus-digest
rewrite. A Git remote provides an external history anchor; signed tags and
independent retention are stronger. Before first push:

```sh
gh auth status -h github.com
```

The current local environment last reported an invalid GitHub token. Authenticate
with `gh auth login -h github.com`, create the remote intentionally, then push
the current branch without rewriting the existing experiment history.
