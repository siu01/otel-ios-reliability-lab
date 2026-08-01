#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 1 ]] || [[ $# -eq 1 && "$1" != "--require-remote" ]]; then
  echo "usage: scripts/verify-publication.sh [--require-remote]" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
minimum_commit_count="${LAB_MINIMUM_COMMIT_COUNT:-301}"

if [[ ! "$minimum_commit_count" =~ ^[1-9][0-9]*$ ]]; then
  echo "LAB_MINIMUM_COMMIT_COUNT must be a positive integer" >&2
  exit 64
fi

cd "$repo_dir"
git diff --check
"$repo_dir/scripts/test-core.sh"
"$repo_dir/scripts/test-evidence-verifier.sh"
"$repo_dir/scripts/audit-claim-index.sh"
"$repo_dir/scripts/verify-article-assets.sh"

commit_count="$(git rev-list --count HEAD)"
if (( commit_count < minimum_commit_count )); then
  echo "commit history is below the required publication threshold" >&2
  echo "  required $minimum_commit_count" >&2
  echo "  actual   $commit_count" >&2
  exit 1
fi

printf 'commit_count=%s\n' "$commit_count"
printf 'minimum_commit_count=%s\n' "$minimum_commit_count"

if [[ $# -eq 1 ]]; then
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "origin remote is not configured" >&2
    exit 1
  fi
  if ! git rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    echo "current branch has no upstream tracking branch" >&2
    exit 1
  fi
  local_head="$(git rev-parse HEAD)"
  upstream_head="$(git rev-parse '@{upstream}')"
  if [[ "$local_head" != "$upstream_head" ]]; then
    echo "local HEAD does not match the tracked remote HEAD" >&2
    echo "  local    $local_head" >&2
    echo "  upstream $upstream_head" >&2
    exit 1
  fi
  printf 'remote_anchor=verified-tracking-head\n'
else
  printf 'remote_anchor=not-required\n'
fi

printf 'publication_verification=pass\n'
