#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]] || [[ ! "$1" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "usage: scripts/run-collector.sh <run-id>" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
run_id="$1"
run_dir="$repo_dir/evidence/raw/$run_id"
capture_path="$run_dir/received-otlp.jsonl"
collector_log="$run_dir/collector.log"
binary="$repo_dir/collector/bin/otelcol"

if [[ ! -x "$binary" ]]; then
  echo "collector is missing; run scripts/install-collector.sh" >&2
  exit 1
fi

if [[ -e "$capture_path" ]] || [[ -e "$collector_log" ]]; then
  echo "refusing to overwrite existing evidence for run $run_id" >&2
  exit 1
fi

mkdir -p "$run_dir"
export OTEL_LAB_CAPTURE_PATH="$capture_path"

"$binary" --config "$repo_dir/collector/capture.yaml" 2>&1 | tee "$collector_log"
exit "${PIPESTATUS[0]}"

