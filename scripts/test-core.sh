#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch_dir="${TMPDIR:-/tmp}/otel-ios-reliability-core-build"
clang_cache="${TMPDIR:-/tmp}/otel-ios-reliability-clang-cache"
swiftpm_cache="${TMPDIR:-/tmp}/otel-ios-reliability-swiftpm-cache"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CLANG_MODULE_CACHE_PATH="$clang_cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$swiftpm_cache"

cd "$repo_dir/Packages/ReliabilityCore"
xcrun swift test --disable-sandbox --scratch-path "$scratch_dir"

