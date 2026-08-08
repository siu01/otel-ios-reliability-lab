# E021 results: Claim states and evidence links are internally consistent

## Audit output

```text
indexed_experiments=21
runtime_complete=17
runtime_pending=2
model_complete=2
verified_runtime_runs=75
verified_runtime_files=1142
```

The index covers E000 through E020 consecutively with no duplicate ID. Every
experiment directory, plan/protocol path, and result path exists.

## State audit

- E000–E016 are `runtimeComplete`. Their `E###-` raw prefixes resolve to 75
  run directories, and every manifest/inventory digest verifies.
- E017 and E018 are `runtimePending`. They have plans and explicitly scoped
  pre-runtime results, but no raw directories matching their runtime IDs.
- E019 and E020 are `modelComplete`. Their claims are model/repository results
  and do not pretend to be new Simulator evidence.
- The article-inclusion flags match the current draft: E000–E016 occur, while
  E017–E020 do not.

This passes every preregistered hypothesis.

## Reproduction

```sh
scripts/audit-claim-index.sh
```

The validator checks path existence, exact state vocabulary, consecutive IDs,
raw-evidence requirements, article inclusion, and every runtime manifest through
the E020 verifier.

## Interpretation

The audit makes an important distinction machine-checkable: implementation or
model progress is not automatically a completed mobile experiment. In
particular, the E017/E018 code and core proofs can remain useful without being
promoted into runtime claims before application build and Simulator evidence
exist.

The index is also an article-review checklist. A reviewer can start from one
scoped claim, follow its plan/results paths, enumerate raw runs by prefix, and
read the explicit limitation. This reduces the chance that a headline silently
outgrows the experiment that supports it.

## Scope

E021 validates repository consistency, not scientific validity. It cannot judge
whether a hypothesis was well chosen, an exclusion was appropriate, one run is
enough, or a write-up's prose gives the right emphasis. Those remain human
review tasks.

## Update

The article draft this section originally cross-checked against has since been
removed from the repository, and `scripts/audit-claim-index.sh` no longer
performs the article-inclusion check described above. The remaining checks
(path existence, state vocabulary, consecutive IDs, raw-evidence requirements,
and the E020 manifest verifier) are unaffected and still pass.
