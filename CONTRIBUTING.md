# Experiment contribution protocol

This repository treats experimental history as a product artifact. A successful
run without a preregistered question is not enough, and a failed hypothesis is
not a reason to discard valid evidence.

## Before implementation

1. Choose the next unused `E###` ID.
2. Create `experiments/<id>-<slug>/plan.md`.
3. State one falsifiable question, fixed conditions, matrix, acceptance and
   exclusion rules, expected evidence, and scope limits.
4. Register every runtime evidence directory and span run UUID.
5. Commit the plan before changing code or executing the matrix.

If the work is model-only, say so in the plan. Do not imply an iOS runtime
result. If execution must be deferred, register `runtimePending` rather than
promoting implemented code to evidence.

## Implementation discipline

- Preserve legacy decode defaults for every new run dimension.
- Add parser, model, and round-trip tests before relying on automation.
- Keep generated sequence identity independent of OpenTelemetry delivery.
- Validate runner syntax before a run.
- Refuse to overwrite existing raw evidence.
- Record build, toolchain, harness, and hypothesis failures in the notebook.
- Keep retry ownership, durability, object partition, file aggregation, and
  downstream request aggregation as separate layers.

An optimization that relies on an encoding assumption must fail closed when the
assumption is violated. A faster incorrect partitioner is not an acceptable
result.

## Runtime capture

Use the exact registered IDs. Check that lifecycle boundaries occurred before
the configured schedule, first-process HTTP behavior matches the condition,
generated and received identities reconcile, and pre/post-relaunch evidence is
immutable where required.

Do not exclude a run because its duration, delivery, or hypothesis outcome is
unfavorable. Exclude only by the preregistered validity rules and explain the
reason in its manifest.

## Evidence manifest

Each raw directory must contain `manifest.md` with:

- outcome and inclusion status;
- date, plan commit, run ID, and fixed condition values;
- concise interpretation and limitations;
- every regular evidence file and its SHA-256 digest.

Verify it before commit:

```sh
scripts/verify-evidence-run.sh evidence/raw/<run-id>
```

Raw directories are ignored by default to prevent accidental bulk capture.
Force-add only the reviewed directory, never the whole ignored root.

## Results and claim maturity

Write `results.md` with measurements, hypothesis audit, integrity checks,
failures, interpretation, and boundaries. Then update the lab notebook, README,
and `evidence/claim-index.json`.

Allowed claim states:

- `runtimeComplete`: registered app/Simulator evidence and reconciliation exist;
- `runtimePending`: implementation/model work exists but runtime is unfinished;
- `modelComplete`: the scoped claim is intentionally about a deterministic
  model, repository, or tooling rather than a new app run.

Run the provenance audit:

```sh
scripts/audit-claim-index.sh
```

## Commit policy

Make small commits with one reviewable purpose: plan, model, test, runner,
accepted run, analysis, figure source, or documentation update. Do not split
whitespace or generated noise merely to increase the count. Do not rewrite
historical experiment commits after external publication.

Before handoff, use the publication verification command documented in the
README and report any environment-dependent step that could not run.
