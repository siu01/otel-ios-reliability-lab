#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 && $# -ne 6 ]]; then
  echo "usage: scripts/run-background-transition.sh <evidence-run-id> <span-run-uuid> <persistence-mode> <flush-mode> [<experiment-id> <span-count>]" >&2
  exit 64
fi

evidence_run_id="$1"
span_run_id="$2"
persistence_mode="$3"
flush_mode="$4"
experiment_id="${5:-E008}"
span_count="${6:-100}"

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
    echo "background run requires officialDefault or officialInstant" >&2
    exit 64
    ;;
esac
case "$flush_mode" in
  disabled|explicit) ;;
  *)
    echo "background flush mode must be disabled or explicit" >&2
    exit 64
    ;;
esac
if [[ ! "$experiment_id" =~ ^E[0-9]{3}$ ]]; then
  echo "experiment ID must match E followed by three digits" >&2
  exit 64
fi
if [[ ! "$span_count" =~ ^[1-9][0-9]*$ ]] || (( span_count > 1000 )); then
  echo "span count must be an integer from 1 through 1000" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
simulator_udid="${LAB_SIMULATOR_UDID:-72FAE57E-1A63-4BF7-A20E-8C1C23C294E9}"
bundle_id="dev.siu01.otel-reliability-lab"
background_bundle_id="com.apple.mobilesafari"
tmp_root="${LAB_TMP_ROOT:-/tmp}"
app_path="$tmp_root/OTelReliabilityLabDerivedData/Build/Products/Debug-iphonesimulator/OTelReliabilityLab.app"
run_dir="$repo_dir/evidence/raw/$evidence_run_id"
capture_path="$run_dir/received-otlp.jsonl"
collector_log="$run_dir/collector.log"
timing_log="$run_dir/host-timing.tsv"
boundary_log="$run_dir/background-boundary-state.tsv"
after_termination_snapshot="$run_dir/persistence-files-after-termination.tsv"
after_resume_snapshot="$run_dir/persistence-files-after-resume.tsv"
digest_log="$run_dir/evidence-digests.tsv"
first_launch_log="$run_dir/first-launch.txt"
background_launch_log="$run_dir/background-app-launch.txt"
resume_launch_log="$run_dir/resume-launch.txt"
http_attempts_path="$run_dir/http-attempts.jsonl"
collector_binary="$repo_dir/collector/bin/otelcol"
collector_pid=""
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
  echo "collector is already running; background experiments require it to be unavailable initially" >&2
  exit 1
fi

mkdir -p "$run_dir"
printf 'event\tutc_timestamp\n' > "$timing_log"
printf 'metric\tvalue\n' > "$boundary_log"
printf 'flush_mode\t%s\n' "$flush_mode" >> "$boundary_log"
printf 'experiment_id\t%s\n' "$experiment_id" >> "$boundary_log"
printf 'planned_span_count\t%s\n' "$span_count" >> "$boundary_log"
printf 'flush_trigger\tbackground\n' >> "$boundary_log"
printf 'processor_schedule_delay_milliseconds\t5000\n' >> "$boundary_log"
printf 'background_app\t%s\n' "$background_bundle_id" >> "$boundary_log"
printf 'stop_mechanism\tdirect_sigkill\n' >> "$boundary_log"
printf 'artifact\tsha256\n' > "$digest_log"

set +e
xcrun simctl terminate "$simulator_udid" "$bundle_id" >/dev/null 2>&1
xcrun simctl terminate "$simulator_udid" "$background_bundle_id" >/dev/null 2>&1
xcrun simctl uninstall "$simulator_udid" "$bundle_id" >/dev/null 2>&1
set -e
xcrun simctl install "$simulator_udid" "$app_path"

app_container="$(xcrun simctl get_app_container "$simulator_udid" "$bundle_id" data)"
lower_span_run_id="$(printf '%s' "$span_run_id" | tr '[:upper:]' '[:lower:]')"
app_run_dir="$app_container/Library/Application Support/OTelReliabilityLab/runs/$lower_span_run_id"
persistence_dir="$app_container/Library/Application Support/OTelReliabilityLab/persistence/$persistence_mode"
lifecycle_path="$app_run_dir/lifecycle-events.jsonl"

record_timing first_launch_requested
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-autorun \
  "--lab-experiment-id=$experiment_id" \
  "--lab-run-id=$span_run_id" \
  "--lab-span-count=$span_count" \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  "--lab-flush=$flush_mode" \
  --lab-flush-trigger=background \
  --lab-schedule-delay-ms=5000 \
  --lab-http-client=instrumentedBase \
  --lab-exporter=statelessHTTP > "$first_launch_log"
record_timing first_launch_returned

app_pid="$(awk -F': ' 'NF == 2 { print $2 }' "$first_launch_log" | tail -1)"
if [[ ! "$app_pid" =~ ^[0-9]+$ ]] || ! kill -0 "$app_pid" 2>/dev/null; then
  echo "could not resolve a live Simulator app PID from first launch" >&2
  exit 1
fi
printf 'first_process_pid\t%s\n' "$app_pid" >> "$boundary_log"

generated_ledger_observed=false
for _ in {1..4000}; do
  if [[ -s "$app_run_dir/generated.jsonl" && -s "$lifecycle_path" ]] \
      && rg -q '"phase":"generatedLedgerCommitted"' "$lifecycle_path"; then
    generated_record_count="$(wc -l < "$app_run_dir/generated.jsonl" | tr -d ' ')"
    if [[ "$generated_record_count" == "$span_count" ]]; then
      generated_ledger_observed=true
      break
    fi
  fi
  sleep 0.005
done
if [[ "$generated_ledger_observed" != true ]]; then
  record_timing generated_ledger_timeout
  echo "complete generated ledger did not appear within 20 seconds" >&2
  exit 1
fi
record_timing generated_ledger_observed
printf 'generated_records_before_background\t%s\n' "$span_count" >> "$boundary_log"

record_timing background_app_launch_requested
xcrun simctl launch "$simulator_udid" "$background_bundle_id" > "$background_launch_log"
record_timing background_app_launch_returned

background_observed=false
for _ in {1..2000}; do
  if rg -q '"phase":"backgroundObserved"' "$lifecycle_path"; then
    background_observed=true
    break
  fi
  sleep 0.005
done
if [[ "$background_observed" != true ]]; then
  record_timing background_event_timeout
  echo "background lifecycle event did not appear within 10 seconds" >&2
  exit 1
fi
record_timing background_event_observed

if [[ "$flush_mode" == "explicit" ]]; then
  flush_completed=false
  for _ in {1..2000}; do
    if rg -q '"phase":"flushCompleted"' "$lifecycle_path"; then
      flush_completed=true
      break
    fi
    sleep 0.005
  done
  if [[ "$flush_completed" != true ]]; then
    record_timing background_flush_timeout
    echo "background flush did not complete within 10 seconds" >&2
    exit 1
  fi
  record_timing background_flush_completed_observed
  flush_duration_nanoseconds="$(jq -sr '[.[] | select(.phase == "flushCompleted")][0].durationNanoseconds' "$lifecycle_path")"
  printf 'flush_duration_nanoseconds\t%s\n' "$flush_duration_nanoseconds" >> "$boundary_log"
  printf 'stop_trigger\tflush_completed\n' >> "$boundary_log"
else
  printf 'flush_duration_nanoseconds\tnone\n' >> "$boundary_log"
  printf 'stop_trigger\tbackground_observed\n' >> "$boundary_log"
fi

background_count="$(jq -s '[.[] | select(.phase == "backgroundObserved")] | length' "$lifecycle_path")"
flush_started_count="$(jq -s '[.[] | select(.phase == "flushStarted")] | length' "$lifecycle_path")"
flush_completed_count="$(jq -s '[.[] | select(.phase == "flushCompleted")] | length' "$lifecycle_path")"
if [[ "$background_count" != "1" ]]; then
  echo "lifecycle evidence must contain exactly one background event" >&2
  exit 1
fi
if [[ "$flush_mode" == "explicit" ]]; then
  if [[ "$flush_started_count" != "1" || "$flush_completed_count" != "1" ]]; then
    echo "provider intervention must contain exactly one flush lifecycle" >&2
    exit 1
  fi
elif [[ "$flush_started_count" != "0" || "$flush_completed_count" != "0" ]]; then
  echo "no-flush control unexpectedly recorded a flush lifecycle" >&2
  exit 1
fi

first_process_http_record_count=0
if [[ -f "$app_run_dir/http-attempts.jsonl" ]]; then
  first_process_http_record_count="$(wc -l < "$app_run_dir/http-attempts.jsonl" | tr -d ' ')"
fi
printf 'first_process_http_records_before_stop\t%s\n' "$first_process_http_record_count" >> "$boundary_log"
if [[ "$experiment_id" == "E009" && "$first_process_http_record_count" != "0" ]]; then
  echo "E009 scale run reached the exporter HTTP path before stop" >&2
  exit 1
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
cp "$lifecycle_path" "$run_dir/lifecycle-events-before-relaunch.jsonl"
before_generated_digest="$(shasum -a 256 "$run_dir/generated-before-relaunch.jsonl" | awk '{print $1}')"
before_run_digest="$(shasum -a 256 "$run_dir/run-before-relaunch.json" | awk '{print $1}')"
before_lifecycle_digest="$(shasum -a 256 "$run_dir/lifecycle-events-before-relaunch.jsonl" | awk '{print $1}')"
printf 'generated-before-relaunch.jsonl\t%s\n' "$before_generated_digest" >> "$digest_log"
printf 'run-before-relaunch.json\t%s\n' "$before_run_digest" >> "$digest_log"
printf 'lifecycle-events-before-relaunch.jsonl\t%s\n' "$before_lifecycle_digest" >> "$digest_log"

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
  "--lab-experiment-id=$experiment_id" \
  "--lab-run-id=$span_run_id" \
  "--lab-span-count=$span_count" \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  "--lab-flush=$flush_mode" \
  --lab-flush-trigger=background \
  --lab-schedule-delay-ms=5000 \
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
cp "$lifecycle_path" "$run_dir/lifecycle-events.jsonl"
if [[ -f "$app_run_dir/http-attempts.jsonl" ]]; then
  cp "$app_run_dir/http-attempts.jsonl" "$http_attempts_path"
else
  touch "$http_attempts_path"
fi
snapshot_persistence "$persistence_dir" "$after_resume_snapshot"

after_generated_digest="$(shasum -a 256 "$run_dir/generated.jsonl" | awk '{print $1}')"
after_run_digest="$(shasum -a 256 "$run_dir/run.json" | awk '{print $1}')"
after_lifecycle_digest="$(shasum -a 256 "$run_dir/lifecycle-events.jsonl" | awk '{print $1}')"
printf 'generated.jsonl\t%s\n' "$after_generated_digest" >> "$digest_log"
printf 'run.json\t%s\n' "$after_run_digest" >> "$digest_log"
printf 'lifecycle-events.jsonl\t%s\n' "$after_lifecycle_digest" >> "$digest_log"

if [[ "$before_generated_digest" != "$after_generated_digest" ]]; then
  echo "generated ledger changed across resume launch" >&2
  exit 1
fi
if [[ "$before_run_digest" != "$after_run_digest" ]]; then
  echo "run metadata changed across resume launch" >&2
  exit 1
fi
if [[ "$before_lifecycle_digest" != "$after_lifecycle_digest" ]]; then
  echo "lifecycle evidence changed across resume launch" >&2
  exit 1
fi

xcrun simctl terminate "$simulator_udid" "$bundle_id"
"$repo_dir/scripts/reconcile-run.sh" "$run_dir"
