#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: scripts/summarize-main-queue-probes.sh <evidence-directory> [...]" >&2
  exit 64
fi

printf 'evidence_run\tpersistence\tpolicy\tbatch\tflush_ns\tprobe_delay_ns\toverhead_ns\treceived\tduplicates\n'

for run_dir in "$@"; do
  lifecycle_path="$run_dir/lifecycle-events.jsonl"
  run_path="$run_dir/run.json"
  reconciliation_path="$run_dir/reconciliation.json"

  for required_path in "$lifecycle_path" "$run_path" "$reconciliation_path"; do
    if [[ ! -s "$required_path" ]]; then
      echo "missing required evidence: $required_path" >&2
      exit 1
    fi
  done

  flush_count="$(jq -s '[.[] | select(.phase == "flushCompleted")] | length' "$lifecycle_path")"
  probe_count="$(jq -s '[.[] | select(.phase == "mainQueueProbeExecuted")] | length' "$lifecycle_path")"
  if [[ "$flush_count" != "1" || "$probe_count" != "1" ]]; then
    echo "expected exactly one flush and executed probe in $run_dir" >&2
    exit 1
  fi

  evidence_run="$(basename "$run_dir")"
  persistence="$(jq -r '.persistence' "$run_path")"
  policy="$(jq -r '.persistenceObjectPolicy' "$run_path")"
  batch="$(jq -r '.maxExportBatchSize' "$run_path")"
  flush_ns="$(jq -sr '[.[] | select(.phase == "flushCompleted")][0].durationNanoseconds' "$lifecycle_path")"
  probe_delay_ns="$(jq -sr '[.[] | select(.phase == "mainQueueProbeExecuted")][0].durationNanoseconds' "$lifecycle_path")"
  overhead_ns=$((probe_delay_ns - flush_ns))
  received="$(jq -r '.report.uniqueReceivedCount' "$reconciliation_path")"
  duplicates="$(jq -r '.report.duplicateReceiptRecordCount' "$reconciliation_path")"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$evidence_run" \
    "$persistence" \
    "$policy" \
    "$batch" \
    "$flush_ns" \
    "$probe_delay_ns" \
    "$overhead_ns" \
    "$received" \
    "$duplicates"
done
