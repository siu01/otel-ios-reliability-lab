# E021 plan: Audit claim provenance before publication

## Question

Can every indexed experiment state be traced to existing plan/result/evidence
artifacts without presenting model-only or runtime-pending work as completed iOS
evidence?

## Design

Create a machine-readable claim index for E000 through E020. Each entry records:

- experiment ID and one concise scoped claim;
- lifecycle state: `runtimeComplete`, `modelComplete`, or `runtimePending`;
- experiment directory, plan/result document paths, and raw-evidence prefix;
- whether the current article draft includes the experiment; and
- one explicit limitation.

Add a validator that requires consecutive unique IDs, existing documents,
committed raw manifests for runtime-complete entries, no raw run for the two
runtime-pending entries, and exact E-ID/state vocabulary. It will invoke the
E020 evidence verifier for every runtime-complete raw directory.

## Hypotheses

- E000–E016 validate as runtime-complete with at least one raw manifest each.
- E017/E018 validate as runtime-pending and have no raw runtime directory.
- E019/E020 validate as model-complete with result documents but no fabricated
  iOS raw-run requirement.
- The index contains exactly 21 consecutive experiments and no missing paths.
- The combined claim and raw-evidence audit passes from a clean checkout.

These expectations were registered before creating the index or validator.

## Scope limit

The audit proves link and state consistency, not that each scientific
conclusion is correct. Human review is still required for design quality,
exclusion decisions, statistics, and whether the article paraphrases a result
fairly.
