# Article publication checklist

## Scientific scope

- [x] Current article claims stop at E016, the latest runtime-complete experiment.
- [x] Every numeric table maps to committed accepted-run evidence.
- [x] Failed hypotheses and excluded attempts are described rather than hidden.
- [x] Simulator, single-run, SDK-version, lifecycle, and prototype limits are explicit.
- [x] Delivery recovery and oversize observability recovery are not conflated.
- [x] Provider duration and measured main-queue delay are not conflated.
- [ ] E017/E018 remain outside the article until registered runtime evidence exists.

## Evidence and reproducibility

- [x] Core suite passes with deterministic boundary, parser, and reconciliation tests.
- [x] Claim index distinguishes runtime-complete, runtime-pending, and model-complete work.
- [x] All 75 raw manifests and 1,142 listed files verify.
- [x] Mutation harness proves isolated corruption detection and coordinated-rewrite limit.
- [x] Reproduction and contribution protocols are committed.
- [x] Publication verifier enforces more than 300 commits by default.

## Article assets

- [x] All eight article asset references exist and match metadata SHA-256 values.
- [x] Referenced SVG sources pass XML validation.
- [x] E003–E015 PNGs were rendered and visually inspected as recorded.
- [ ] Render `e016-main-queue-delay.svg` to PNG after execution approval returns.
- [ ] Inspect that PNG at original resolution and update its metadata digest.
- [ ] If the publication platform does not preserve SVG, change the article link only
  after the verified PNG exists.

## Git history and external anchor

- [x] Local history exceeds 300 meaningful commits once the publication gate passes.
- [x] Evidence manifests cover the raw tree beneath the Git commit.
- [ ] Restore GitHub CLI authentication with `gh auth login -h github.com`.
- [ ] Create the intended repository and configure `origin`.
- [ ] Push the current branch without rewriting experiment history.
- [ ] Run `scripts/verify-publication.sh --require-remote` after fetching the remote.
- [ ] Prefer a signed release tag and retain the article commit hash in publication notes.

## Final editorial pass

- [ ] Choose the publication platform and adapt relative asset paths without changing
  evidence values.
- [ ] Confirm title, lead, and conclusion make the scoped mechanism claim rather than
  a universal SDK guarantee.
- [ ] Link the public repository at the first methodology reference.
- [ ] Add the exact branch/tag/commit used for the article.
- [ ] Preview mobile and desktop rendering.
- [ ] Submit only after unresolved checklist items that affect the chosen platform are
  either completed or explicitly disclosed.

The unchecked items are real blockers or deferred scope, not cosmetic reminders.
This file should be updated in new commits; do not edit historical run manifests to
make publication state look complete.
