#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
verifier="$repo_dir/scripts/verify-evidence-run.sh"
manifest_paths=("$repo_dir"/evidence/raw/*/manifest.md)

if [[ ${#manifest_paths[@]} -eq 0 ]]; then
  echo "no raw evidence manifests found" >&2
  exit 1
fi

verified_runs=0
verified_files=0
for manifest_path in "${manifest_paths[@]}"; do
  run_dir="$(dirname "$manifest_path")"
  result="$($verifier "$run_dir")"
  run_file_count="$(printf '%s\n' "$result" | awk -F= '$1 == "verified_files" {print $2}')"
  if [[ ! "$run_file_count" =~ ^[1-9][0-9]*$ ]]; then
    echo "verifier returned an invalid file count for $run_dir" >&2
    exit 1
  fi
  verified_runs=$((verified_runs + 1))
  verified_files=$((verified_files + run_file_count))
done

printf 'verified_runs=%s\n' "$verified_runs"
printf 'verified_files=%s\n' "$verified_files"
