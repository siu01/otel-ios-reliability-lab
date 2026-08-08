#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
index_path="$repo_dir/evidence/claim-index.json"
verifier="$repo_dir/scripts/verify-evidence-run.sh"

if ! jq -e 'type == "array" and length == 21' "$index_path" >/dev/null; then
  echo "claim index must contain exactly 21 array entries" >&2
  exit 1
fi
if ! jq -e '
  all(.[].state; . == "runtimeComplete" or . == "modelComplete" or . == "runtimePending") and
  ([.[].id] | length == (unique | length)) and
  all(.[];
    (.id | test("^E[0-9]{3}$")) and
    (.claim | length > 0) and
    (.limitation | length > 0) and
    (.rawEvidencePrefix == (.id + "-")))
' "$index_path" >/dev/null; then
  echo "claim index schema or state vocabulary is invalid" >&2
  exit 1
fi

runtime_complete=0
runtime_pending=0
model_complete=0
verified_runs=0
verified_files=0
entry_ordinal=0

while IFS=$'\t' read -r \
    experiment_id \
    state \
    experiment_directory \
    plan_path \
    results_path \
    raw_prefix; do
  expected_id="$(printf 'E%03d' "$entry_ordinal")"
  if [[ "$experiment_id" != "$expected_id" ]]; then
    echo "claim index is not consecutive at ordinal $entry_ordinal: $experiment_id" >&2
    exit 1
  fi
  entry_ordinal=$((entry_ordinal + 1))

  for relative_path in "$experiment_directory" "$plan_path" "$results_path"; do
    if [[ ! -e "$repo_dir/$relative_path" ]]; then
      echo "$experiment_id references a missing path: $relative_path" >&2
      exit 1
    fi
  done

  raw_directories=("$repo_dir"/evidence/raw/"$raw_prefix"*)
  case "$state" in
    runtimeComplete)
      runtime_complete=$((runtime_complete + 1))
      if [[ ${#raw_directories[@]} -eq 0 ]]; then
        echo "$experiment_id is runtime-complete without raw evidence" >&2
        exit 1
      fi
      for raw_directory in "${raw_directories[@]}"; do
        if [[ ! -d "$raw_directory" ]]; then
          echo "$experiment_id raw prefix matched a non-directory" >&2
          exit 1
        fi
        result="$($verifier "$raw_directory")"
        file_count="$(printf '%s\n' "$result" | awk -F= '$1 == "verified_files" {print $2}')"
        if [[ ! "$file_count" =~ ^[1-9][0-9]*$ ]]; then
          echo "$experiment_id verifier returned an invalid file count" >&2
          exit 1
        fi
        verified_runs=$((verified_runs + 1))
        verified_files=$((verified_files + file_count))
      done
      ;;
    runtimePending)
      runtime_pending=$((runtime_pending + 1))
      if [[ ${#raw_directories[@]} -ne 0 ]]; then
        echo "$experiment_id is runtime-pending but raw evidence already exists" >&2
        exit 1
      fi
      ;;
    modelComplete)
      model_complete=$((model_complete + 1))
      ;;
  esac
done < <(jq -r '.[] | [
  .id,
  .state,
  .experimentDirectory,
  .planPath,
  .resultsPath,
  .rawEvidencePrefix
] | @tsv' "$index_path")

printf 'indexed_experiments=%s\n' "$entry_ordinal"
printf 'runtime_complete=%s\n' "$runtime_complete"
printf 'runtime_pending=%s\n' "$runtime_pending"
printf 'model_complete=%s\n' "$model_complete"
printf 'verified_runtime_runs=%s\n' "$verified_runs"
printf 'verified_runtime_files=%s\n' "$verified_files"
