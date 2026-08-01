#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: scripts/run-write-boundary.sh <evidence-run-id> <span-run-uuid> <persistence-mode> <ledger-offset-ms>" >&2
  exit 64
fi

evidence_run_id="$1"
span_run_id="$2"
persistence_mode="$3"
ledger_offset_ms="$4"

if [[ ! "$evidence_run_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "invalid evidence run ID" >&2
  exit 64
fi
if [[ ! "$span_run_id" =~ ^[0-9A-Fa-f-]{36}$ ]]; then
  echo "invalid span run UUID" >&2
  exit 64
fi
case "$persistence_mode" in
  officialDefault|officialInstant) ;;
  *)
    echo "write-boundary run requires officialDefault or officialInstant" >&2
    exit 64
    ;;
esac
if [[ ! "$ledger_offset_ms" =~ ^[0-9]+$ ]] || (( ledger_offset_ms > 5000 )); then
  echo "ledger offset must be an integer from 0 through 5000 milliseconds" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
simulator_udid="${LAB_SIMULATOR_UDID:-72FAE57E-1A63-4BF7-A20E-8C1C23C294E9}"
bundle_id="dev.siu01.otel-reliability-lab"
tmp_root="${LAB_TMP_ROOT:-/tmp}"
app_path="$tmp_root/OTelReliabilityLabDerivedData/Build/Products/Debug-iphonesimulator/OTelReliabilityLab.app"
run_dir="$repo_dir/evidence/raw/$evidence_run_id"
capture_path="$run_dir/received-otlp.jsonl"
collector_log="$run_dir/collector.log"
timing_log="$run_dir/host-timing.tsv"
boundary_log="$run_dir/boundary-state.tsv"
after_termination_snapshot="$run_dir/persistence-files-after-termination.tsv"
after_resume_snapshot="$run_dir/persistence-files-after-resume.tsv"
digest_log="$run_dir/evidence-digests.tsv"
first_launch_log="$run_dir/first-launch.txt"
resume_launch_log="$run_dir/resume-launch.txt"
http_attempts_path="$run_dir/http-attempts.jsonl"
collector_binary="$repo_dir/collector/bin/otelcol"
collector_pid=""
offset_seconds="$(awk -v milliseconds="$ledger_offset_ms" 'BEGIN { printf "%.3f", milliseconds / 1000 }')"
timestamp_source="$repo_dir/tools/utc-now.c"
timestamp_binary="$tmp_root/OTelReliabilityLabUtcNow"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

utc_now() {
  "$timestamp_binary"
}

record_timing() {
  printf '%s\t%s\n' "$1" "$(utc_now)" >> "$timing_log"
}

cleanup_collector() {
  if [[ -n "$collector_pid" ]] && kill -0 "$collector_pid" 2>/dev/null; then
    kill -INT "$collector_pid"
    set +e
    wait "$collector_pid"
    set -e
  fi
}

snapshot_persistence() {
  local persistence_dir="$1"
  local destination="$2"

  if [[ -d "$persistence_dir" ]]; then
    printf '# directory_exists=true\n' > "$destination"
  else
    printf '# directory_exists=false\n' > "$destination"
  fi
  printf 'relative_path\tbytes\tsha256\n' >> "$destination"
  if [[ -d "$persistence_dir" ]]; then
    while IFS= read -r persistence_file; do
      local relative_path="${persistence_file#"$persistence_dir"/}"
      local byte_count
      local digest
      byte_count="$(stat -f '%z' "$persistence_file")"
      digest="$(shasum -a 256 "$persistence_file" | awk '{print $1}')"
      printf '%s\t%s\t%s\n' "$relative_path" "$byte_count" "$digest" >> "$destination"
    done < <(find "$persistence_dir" -type f -print | sort)
  fi
}

trap cleanup_collector EXIT INT TERM

if [[ -e "$run_dir" ]]; then
  echo "refusing to overwrite existing evidence directory: $run_dir" >&2
  exit 1
fi
if [[ ! -x "$collector_binary" ]]; then
  echo "collector is missing; run scripts/install-collector.sh" >&2
  exit 1
fi
if [[ ! -d "$app_path" ]]; then
  echo "app build is missing; run scripts/build-simulator.sh" >&2
  exit 1
fi
if [[ ! -x "$timestamp_binary" || "$timestamp_source" -nt "$timestamp_binary" ]]; then
  clang -std=c11 -Wall -Wextra -Werror "$timestamp_source" -o "$timestamp_binary"
fi
if curl --silent --fail http://127.0.0.1:13133/ >/dev/null 2>&1; then
  echo "collector is already running; E006 requires it to be unavailable initially" >&2
  exit 1
fi

mkdir -p "$run_dir"
printf 'event\tutc_timestamp\n' > "$timing_log"
printf 'metric\tvalue\n' > "$boundary_log"
printf 'registered_ledger_offset_ms\t%s\n' "$ledger_offset_ms" >> "$boundary_log"
printf 'stop_mechanism\tdirect_sigkill\n' >> "$boundary_log"
printf 'artifact\tsha256\n' > "$digest_log"

set +e
xcrun simctl terminate "$simulator_udid" "$bundle_id" >/dev/null 2>&1
xcrun simctl uninstall "$simulator_udid" "$bundle_id" >/dev/null 2>&1
set -e
xcrun simctl install "$simulator_udid" "$app_path"

app_container="$(xcrun simctl get_app_container "$simulator_udid" "$bundle_id" data)"
lower_span_run_id="$(printf '%s' "$span_run_id" | tr '[:upper:]' '[:lower:]')"
app_run_dir="$app_container/Library/Application Support/OTelReliabilityLab/runs/$lower_span_run_id"
persistence_dir="$app_container/Library/Application Support/OTelReliabilityLab/persistence/$persistence_mode"

record_timing first_launch_requested
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-autorun \
  --lab-experiment-id=E006 \
  "--lab-run-id=$span_run_id" \
  --lab-span-count=100 \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  --lab-flush=disabled \
  --lab-http-client=instrumentedBase \
  --lab-exporter=statelessHTTP > "$first_launch_log"
record_timing first_launch_returned

app_pid="$(awk -F': ' 'NF == 2 { print $2 }' "$first_launch_log" | tail -1)"
if [[ ! "$app_pid" =~ ^[0-9]+$ ]] || ! kill -0 "$app_pid" 2>/dev/null; then
  echo "could not resolve a live Simulator app PID from first launch" >&2
  exit 1
fi
printf 'first_process_pid\t%s\n' "$app_pid" >> "$boundary_log"

generated_ledger_ready=false
for _ in {1..4000}; do
  if [[ -s "$app_run_dir/generated.jsonl" && -s "$app_run_dir/run.json" ]]; then
    generated_record_count="$(wc -l < "$app_run_dir/generated.jsonl" | tr -d ' ')"
    if [[ "$generated_record_count" == "100" ]]; then
      generated_ledger_ready=true
      break
    fi
  fi
  sleep 0.005
done
if [[ "$generated_ledger_ready" != true ]]; then
  record_timing generated_ledger_timeout
  echo "complete generated ledger did not appear within 20 seconds" >&2
  exit 1
fi
record_timing generated_ledger_observed
printf 'generated_records_before_termination\t100\n' >> "$boundary_log"

if [[ "$ledger_offset_ms" != "0" ]]; then
  sleep "$offset_seconds"
fi

persistence_visible_before_request=false
if [[ -d "$persistence_dir" ]] && [[ -n "$(find "$persistence_dir" -type f -print -quit)" ]]; then
  persistence_visible_before_request=true
fi
printf 'persistence_visible_before_request\t%s\n' "$persistence_visible_before_request" >> "$boundary_log"

record_timing termination_requested
kill -KILL "$app_pid"
record_timing first_process_terminated

snapshot_persistence "$persistence_dir" "$after_termination_snapshot"
after_termination_file_count=0
if [[ -d "$persistence_dir" ]]; then
  after_termination_file_count="$(find "$persistence_dir" -type f | wc -l | tr -d ' ')"
fi
printf 'persistence_files_after_termination\t%s\n' "$after_termination_file_count" >> "$boundary_log"

cp "$app_run_dir/generated.jsonl" "$run_dir/generated-before-relaunch.jsonl"
cp "$app_run_dir/run.json" "$run_dir/run-before-relaunch.json"
before_generated_digest="$(shasum -a 256 "$run_dir/generated-before-relaunch.jsonl" | awk '{print $1}')"
before_run_digest="$(shasum -a 256 "$run_dir/run-before-relaunch.json" | awk '{print $1}')"
printf 'generated-before-relaunch.jsonl\t%s\n' "$before_generated_digest" >> "$digest_log"
printf 'run-before-relaunch.json\t%s\n' "$before_run_digest" >> "$digest_log"

export OTEL_LAB_CAPTURE_PATH="$capture_path"
record_timing collector_start_requested
"$collector_binary" --config "$repo_dir/collector/capture.yaml" > "$collector_log" 2>&1 &
collector_pid=$!

collector_ready=false
for _ in {1..120}; do
  if curl --silent --fail http://127.0.0.1:13133/ >/dev/null; then
    collector_ready=true
    break
  fi
  sleep 0.25
done
if [[ "$collector_ready" != true ]]; then
  echo "collector did not become ready" >&2
  exit 1
fi
record_timing collector_ready

record_timing resume_launch_requested
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-resume \
  --lab-experiment-id=E006 \
  "--lab-run-id=$span_run_id" \
  --lab-span-count=100 \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  --lab-flush=disabled \
  --lab-http-client=instrumentedBase \
  --lab-exporter=statelessHTTP > "$resume_launch_log"
record_timing resume_launch_returned

sleep 30
record_timing capture_window_complete

cleanup_collector
collector_pid=""

if [[ ! -e "$capture_path" ]]; then
  touch "$capture_path"
fi

cp "$app_run_dir/generated.jsonl" "$run_dir/generated.jsonl"
cp "$app_run_dir/run.json" "$run_dir/run.json"
if [[ -f "$app_run_dir/http-attempts.jsonl" ]]; then
  cp "$app_run_dir/http-attempts.jsonl" "$http_attempts_path"
else
  touch "$http_attempts_path"
fi
snapshot_persistence "$persistence_dir" "$after_resume_snapshot"

after_generated_digest="$(shasum -a 256 "$run_dir/generated.jsonl" | awk '{print $1}')"
after_run_digest="$(shasum -a 256 "$run_dir/run.json" | awk '{print $1}')"
printf 'generated.jsonl\t%s\n' "$after_generated_digest" >> "$digest_log"
printf 'run.json\t%s\n' "$after_run_digest" >> "$digest_log"

if [[ "$before_generated_digest" != "$after_generated_digest" ]]; then
  echo "generated ledger changed across resume launch" >&2
  exit 1
fi
if [[ "$before_run_digest" != "$after_run_digest" ]]; then
  echo "run metadata changed across resume launch" >&2
  exit 1
fi

xcrun simctl terminate "$simulator_udid" "$bundle_id"
"$repo_dir/scripts/reconcile-run.sh" "$run_dir"
