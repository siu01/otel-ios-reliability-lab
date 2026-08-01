#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 && $# -ne 6 && $# -ne 7 && $# -ne 8 && $# -ne 9 \
    && $# -ne 10 && $# -ne 11 && $# -ne 12 ]]; then
  echo "usage: scripts/run-background-transition.sh <evidence-run-id> <span-run-uuid> <persistence-mode> <flush-mode> [<experiment-id> <span-count> [<schedule-delay-ms> [<max-export-batch-size> [<payload-bytes> [<object-policy> [<object-byte-budget> [<partition-strategy>]]]]]]]" >&2
  exit 64
fi

evidence_run_id="$1"
span_run_id="$2"
persistence_mode="$3"
flush_mode="$4"
experiment_id="${5:-E008}"
span_count="${6:-100}"
schedule_delay_milliseconds="${7:-5000}"
max_export_batch_size="${8:-256}"
payload_attribute_bytes="${9:-0}"
persistence_object_policy="${10:-sdkNative}"
persistence_object_byte_budget="${11:-262144}"
persistence_object_partition_strategy="${12:-linearPrefixEncoding}"

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
if [[ ! "$schedule_delay_milliseconds" =~ ^[1-9][0-9]*$ ]] \
    || (( schedule_delay_milliseconds < 250 || schedule_delay_milliseconds > 60000 )); then
  echo "schedule delay must be an integer from 250 through 60000 milliseconds" >&2
  exit 64
fi
if [[ ! "$max_export_batch_size" =~ ^[1-9][0-9]*$ ]] || (( max_export_batch_size > 512 )); then
  echo "maximum export batch size must be an integer from 1 through 512" >&2
  exit 64
fi
if [[ ! "$payload_attribute_bytes" =~ ^[0-9]+$ ]] || (( payload_attribute_bytes > 524288 )); then
  echo "payload attribute bytes must be an integer from 0 through 524288" >&2
  exit 64
fi
case "$persistence_object_policy" in
  sdkNative|encodedByteBudget) ;;
  *)
    echo "persistence object policy must be sdkNative or encodedByteBudget" >&2
    exit 64
    ;;
esac
if [[ ! "$persistence_object_byte_budget" =~ ^[1-9][0-9]*$ ]] \
    || (( persistence_object_byte_budget > 524288 )); then
  echo "persistence object byte budget must be an integer from 1 through 524288" >&2
  exit 64
fi
case "$persistence_object_partition_strategy" in
  linearPrefixEncoding|binarySearchEncoding) ;;
  *)
    echo "partition strategy must be linearPrefixEncoding or binarySearchEncoding" >&2
    exit 64
    ;;
esac

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
object_policy_events_path="$run_dir/object-policy-events.jsonl"
object_policy_events_before_path="$run_dir/object-policy-events-before-relaunch.jsonl"
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
printf 'processor_schedule_delay_milliseconds\t%s\n' "$schedule_delay_milliseconds" >> "$boundary_log"
printf 'max_export_batch_size\t%s\n' "$max_export_batch_size" >> "$boundary_log"
printf 'payload_attribute_bytes\t%s\n' "$payload_attribute_bytes" >> "$boundary_log"
printf 'persistence_object_policy\t%s\n' "$persistence_object_policy" >> "$boundary_log"
printf 'persistence_object_byte_budget\t%s\n' "$persistence_object_byte_budget" >> "$boundary_log"
printf 'persistence_object_partition_strategy\t%s\n' "$persistence_object_partition_strategy" >> "$boundary_log"
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
app_object_policy_events_path="$app_run_dir/object-policy-events.jsonl"

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
  "--lab-schedule-delay-ms=$schedule_delay_milliseconds" \
  "--lab-max-export-batch-size=$max_export_batch_size" \
  "--lab-payload-bytes=$payload_attribute_bytes" \
  "--lab-persistence-object-policy=$persistence_object_policy" \
  "--lab-persistence-object-byte-budget=$persistence_object_byte_budget" \
  "--lab-persistence-object-partition-strategy=$persistence_object_partition_strategy" \
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

generated_commit_nanoseconds="$(jq -sr '[.[] | select(.phase == "generatedLedgerCommitted")][0].timestampUnixNanoseconds' "$lifecycle_path")"
background_observed_nanoseconds="$(jq -sr '[.[] | select(.phase == "backgroundObserved")][0].timestampUnixNanoseconds' "$lifecycle_path")"
if [[ ! "$generated_commit_nanoseconds" =~ ^[0-9]+$ ]] \
    || [[ ! "$background_observed_nanoseconds" =~ ^[0-9]+$ ]]; then
  echo "could not read lifecycle timestamps" >&2
  exit 1
fi
ledger_to_background_nanoseconds=$((background_observed_nanoseconds - generated_commit_nanoseconds))
schedule_delay_nanoseconds=$((schedule_delay_milliseconds * 1000000))
schedule_boundary_valid=true
if (( ledger_to_background_nanoseconds >= schedule_delay_nanoseconds )); then
  schedule_boundary_valid=false
fi
printf 'ledger_to_background_nanoseconds\t%s\n' "$ledger_to_background_nanoseconds" >> "$boundary_log"
printf 'background_before_schedule_boundary\t%s\n' "$schedule_boundary_valid" >> "$boundary_log"

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
if [[ "$experiment_id" == "E009" || "$experiment_id" == "E014" ]] \
    && [[ "$first_process_http_record_count" != "0" ]]; then
  echo "$experiment_id run reached the exporter HTTP path before stop" >&2
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
if [[ -f "$app_object_policy_events_path" ]]; then
  cp "$app_object_policy_events_path" "$object_policy_events_before_path"
else
  touch "$object_policy_events_before_path"
fi
before_generated_digest="$(shasum -a 256 "$run_dir/generated-before-relaunch.jsonl" | awk '{print $1}')"
before_run_digest="$(shasum -a 256 "$run_dir/run-before-relaunch.json" | awk '{print $1}')"
before_lifecycle_digest="$(shasum -a 256 "$run_dir/lifecycle-events-before-relaunch.jsonl" | awk '{print $1}')"
before_object_policy_digest="$(shasum -a 256 "$object_policy_events_before_path" | awk '{print $1}')"
printf 'generated-before-relaunch.jsonl\t%s\n' "$before_generated_digest" >> "$digest_log"
printf 'run-before-relaunch.json\t%s\n' "$before_run_digest" >> "$digest_log"
printf 'lifecycle-events-before-relaunch.jsonl\t%s\n' "$before_lifecycle_digest" >> "$digest_log"
printf 'object-policy-events-before-relaunch.jsonl\t%s\n' "$before_object_policy_digest" >> "$digest_log"

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
  "--lab-schedule-delay-ms=$schedule_delay_milliseconds" \
  "--lab-max-export-batch-size=$max_export_batch_size" \
  "--lab-payload-bytes=$payload_attribute_bytes" \
  "--lab-persistence-object-policy=$persistence_object_policy" \
  "--lab-persistence-object-byte-budget=$persistence_object_byte_budget" \
  "--lab-persistence-object-partition-strategy=$persistence_object_partition_strategy" \
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
if [[ -f "$app_object_policy_events_path" ]]; then
  cp "$app_object_policy_events_path" "$object_policy_events_path"
else
  touch "$object_policy_events_path"
fi
snapshot_persistence "$persistence_dir" "$after_resume_snapshot"

after_generated_digest="$(shasum -a 256 "$run_dir/generated.jsonl" | awk '{print $1}')"
after_run_digest="$(shasum -a 256 "$run_dir/run.json" | awk '{print $1}')"
after_lifecycle_digest="$(shasum -a 256 "$run_dir/lifecycle-events.jsonl" | awk '{print $1}')"
after_object_policy_digest="$(shasum -a 256 "$object_policy_events_path" | awk '{print $1}')"
printf 'generated.jsonl\t%s\n' "$after_generated_digest" >> "$digest_log"
printf 'run.json\t%s\n' "$after_run_digest" >> "$digest_log"
printf 'lifecycle-events.jsonl\t%s\n' "$after_lifecycle_digest" >> "$digest_log"
printf 'object-policy-events.jsonl\t%s\n' "$after_object_policy_digest" >> "$digest_log"

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
if [[ "$before_object_policy_digest" != "$after_object_policy_digest" ]]; then
  echo "object policy evidence changed across resume launch" >&2
  exit 1
fi

if [[ "$persistence_object_policy" == "encodedByteBudget" ]]; then
  if [[ ! -s "$object_policy_events_path" ]]; then
    echo "encoded-byte policy produced no decision evidence" >&2
    exit 1
  fi
  if ! jq -e -s \
      --argjson budget "$persistence_object_byte_budget" \
      'all(.[];
        .byteBudget == $budget and
        ((.outcome == "acceptedChunk" and .encodedByteCount <= $budget) or
         (.outcome == "rejectedOversize" and .encodedByteCount > $budget)))' \
      "$object_policy_events_path" >/dev/null; then
    echo "object policy evidence contains an invalid outcome or byte boundary" >&2
    exit 1
  fi
  observed_policy_sequences="$(jq -cs '[.[].sequences[]] | sort' "$object_policy_events_path")"
  expected_policy_sequences="$(jq -cn --argjson count "$span_count" '[range(1; $count + 1)]')"
  if [[ "$observed_policy_sequences" != "$expected_policy_sequences" ]]; then
    echo "object policy evidence does not cover each generated sequence exactly once" >&2
    exit 1
  fi
fi

xcrun simctl terminate "$simulator_udid" "$bundle_id"
"$repo_dir/scripts/reconcile-run.sh" "$run_dir"

if [[ "$schedule_boundary_valid" != true ]]; then
  echo "run completed but is excluded because background occurred after the processor schedule boundary" >&2
  exit 65
fi
