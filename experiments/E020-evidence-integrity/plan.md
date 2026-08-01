# E020 plan: Verify evidence integrity and expose the trust-root limit

## Question

Can the repository automatically detect accidental or isolated modification of
a committed raw-evidence directory, and which coordinated modifications remain
undetectable without an external history anchor?

## Verifier design

Add a read-only script that accepts one evidence-run directory and:

1. parses every filename/SHA-256 row in `manifest.md`;
2. rejects malformed, duplicate, missing, or mismatched entries;
3. requires the manifest inventory to cover every regular file except the
   manifest itself; and
4. reports the verified file count without changing evidence.

Add a temporary-fixture harness. It must never edit committed evidence; it will
copy one accepted E016 run into a fresh `mktemp` directory for each mutation.

## Registered cases

| Case | Mutation | Expected verifier result |
|---|---|---|
| control | none | pass |
| truncated evidence | remove bytes from `lifecycle-events.jsonl` | fail digest |
| unlisted evidence | add one regular file | fail inventory |
| missing evidence | delete one listed file | fail missing file |
| coordinated rewrite | alter one file and update its manifest digest | pass |

The coordinated-rewrite case is intentionally expected to pass. A local hash
stored beside the data protects against accidental or partial mutation, not an
actor who can replace both data and expected hash.

## Hypotheses

- The accepted E016 control verifies without modification.
- All three isolated mutations fail for the registered reason.
- Coordinated rewrite passes, proving that an external immutable or signed Git
  history is required as a trust anchor.
- The harness leaves the committed E016 directory byte-identical and the
  worktree clean.

These cases were registered before implementing the verifier or mutation
harness.

## Scope limit

This experiment validates repository artifact integrity, not telemetry
authenticity at collection time. SHA-256 does not prove that the app or
Collector generated a truthful observation. GitHub push provides a public-ish
history anchor, not cryptographic authorship unless commits/tags are signed and
the remote history is independently retained.
