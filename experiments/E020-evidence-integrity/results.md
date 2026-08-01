# E020 results: Isolated corruption is detectable; coordinated rewrite is not

## Registered mutation outcomes

| Case | Expected | Observed |
|---|---|---|
| Unmodified E016 control | pass | pass, 20 files verified |
| Truncated lifecycle evidence | digest failure | failed with SHA-256 mismatch |
| Added unlisted file | inventory failure | failed with inventory diff |
| Deleted listed file | missing-file failure | failed with missing-file error |
| Evidence plus updated manifest digest | pass | passed as registered |

The harness computed a digest over the source E016 directory before and after
all temporary mutations and reported `source_evidence_unchanged=true`. Every
mutation occurred inside a fresh `mktemp` copy.

Reproduce with:

```sh
scripts/test-evidence-verifier.sh
```

## Repository-wide audit

The first all-manifest audit found one compatibility failure. The earliest E000
infrastructure-failure manifest stored its Collector digest in prose before the
standard SHA table existed. Its raw `collector.log` already matched that
recorded digest. The same digest was added to a standard table without changing
the log, after which the full audit passed:

```text
verified_runs=75
verified_files=1142
```

Reproduce with:

```sh
scripts/verify-all-evidence.sh
```

The verifier rejects malformed/duplicate rows, unsafe filenames, missing files,
digest mismatches, and any regular file absent from the manifest inventory.

## Hypothesis audit

All registered hypotheses passed, including the intentionally negative one.
The coordinated rewrite passed because its modified file and expected digest
agreed. A hash stored in the same writable directory cannot distinguish that
rewrite from a legitimate update.

## Interpretation

The repository now detects accidental truncation, incomplete copying, a stale
manifest, and most one-sided edits. It does not make evidence self-authenticating.
The trust chain is:

```text
raw file → manifest digest → Git commit → external remote/history observer
```

E020 implements and tests the first arrow. Git commits provide the second once
the tree is committed. The unavailable GitHub push is still necessary for an
external history anchor, and signed commits/tags plus independent retention
would be stronger than an unsigned mutable remote branch.

## Scope

Integrity is not truthfulness. These checks cannot prove that the app,
Collector, clock, or experiment procedure produced a valid observation. That
requires the preregistered controls, immutable run metadata, identity
reconciliation, and methodological review used by the other experiments.
