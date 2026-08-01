#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: scripts/reconcile-run.sh <run-directory>" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch_dir="${TMPDIR:-/tmp}/otel-ios-reliability-core-build"
run_dir="$1"
if [[ "$run_dir" != /* ]]; then
  run_dir="$repo_dir/$run_dir"
fi

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CLANG_MODULE_CACHE_PATH="${TMPDIR:-/tmp}/otel-ios-reliability-clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="${TMPDIR:-/tmp}/otel-ios-reliability-swiftpm-cache"

cd "$repo_dir/Packages/ReliabilityCore"
xcrun swift run \
  --disable-sandbox \
  --scratch-path "$scratch_dir" \
  reliability-reconcile \
  "$run_dir"
