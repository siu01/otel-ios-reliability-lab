#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: scripts/run-process-relaunch.sh <evidence-run-id> <span-run-uuid> <persistence-mode>" >&2
  exit 64
fi

evidence_run_id="$1"
span_run_id="$2"
persistence_mode="$3"

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
    echo "process relaunch requires officialDefault or officialInstant" >&2
    exit 64
    ;;
esac

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
simulator_udid="${LAB_SIMULATOR_UDID:-72FAE57E-1A63-4BF7-A20E-8C1C23C294E9}"
bundle_id="dev.siu01.otel-reliability-lab"
tmp_root="${LAB_TMP_ROOT:-/tmp}"
app_path="$tmp_root/OTelReliabilityLabDerivedData/Build/Products/Debug-iphonesimulator/OTelReliabilityLab.app"
run_dir="$repo_dir/evidence/raw/$evidence_run_id"
capture_path="$run_dir/received-otlp.jsonl"
collector_log="$run_dir/collector.log"
timing_log="$run_dir/host-timing.tsv"
before_snapshot="$run_dir/persistence-files-before-termination.tsv"
after_snapshot="$run_dir/persistence-files-after.tsv"
digest_log="$run_dir/evidence-digests.tsv"
first_launch_log="$run_dir/first-launch.txt"
resume_launch_log="$run_dir/resume-launch.txt"
http_attempts_path="$run_dir/http-attempts.jsonl"
collector_binary="$repo_dir/collector/bin/otelcol"
collector_pid=""

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

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
if curl --silent --fail http://127.0.0.1:13133/ >/dev/null 2>&1; then
  echo "collector is already running; E005 requires it to be unavailable initially" >&2
  exit 1
fi

mkdir -p "$run_dir"
printf 'event\tutc_timestamp\n' > "$timing_log"
printf 'artifact\tsha256\n' > "$digest_log"

# A clean install ensures the only recovered file was written by this run.
set +e
xcrun simctl terminate "$simulator_udid" "$bundle_id" >/dev/null 2>&1
xcrun simctl uninstall "$simulator_udid" "$bundle_id" >/dev/null 2>&1
set -e
xcrun simctl install "$simulator_udid" "$app_path"

app_container="$(xcrun simctl get_app_container "$simulator_udid" "$bundle_id" data)"
lower_span_run_id="$(printf '%s' "$span_run_id" | tr '[:upper:]' '[:lower:]')"
app_run_dir="$app_container/Library/Application Support/OTelReliabilityLab/runs/$lower_span_run_id"
persistence_dir="$app_container/Library/Application Support/OTelReliabilityLab/persistence/$persistence_mode"

printf 'first_launch_requested\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-autorun \
  --lab-experiment-id=E005 \
  "--lab-run-id=$span_run_id" \
  --lab-span-count=100 \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  --lab-flush=disabled \
  --lab-http-client=instrumentedBase \
  --lab-exporter=statelessHTTP > "$first_launch_log"
printf 'first_launch_returned\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

persisted_state_ready=false
for _ in {1..80}; do
  first_persistence_file=""
  if [[ -d "$persistence_dir" ]]; then
    first_persistence_file="$(find "$persistence_dir" -type f -print -quit)"
  fi
  if [[ -n "$first_persistence_file" && -s "$app_run_dir/generated.jsonl" && -s "$app_run_dir/run.json" ]]; then
    persisted_state_ready=true
    break
  fi
  sleep 0.25
done
if [[ "$persisted_state_ready" != true ]]; then
  printf 'persisted_state_timeout\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"
  echo "persistence file and generation evidence did not appear within 20 seconds" >&2
  exit 1
fi
printf 'persistence_file_observed\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

snapshot_persistence "$persistence_dir" "$before_snapshot"
cp "$app_run_dir/generated.jsonl" "$run_dir/generated-before-relaunch.jsonl"
cp "$app_run_dir/run.json" "$run_dir/run-before-relaunch.json"
before_generated_digest="$(shasum -a 256 "$run_dir/generated-before-relaunch.jsonl" | awk '{print $1}')"
before_run_digest="$(shasum -a 256 "$run_dir/run-before-relaunch.json" | awk '{print $1}')"
printf 'generated-before-relaunch.jsonl\t%s\n' "$before_generated_digest" >> "$digest_log"
printf 'run-before-relaunch.json\t%s\n' "$before_run_digest" >> "$digest_log"

xcrun simctl terminate "$simulator_udid" "$bundle_id"
printf 'first_process_terminated\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

export OTEL_LAB_CAPTURE_PATH="$capture_path"
printf 'collector_start_requested\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"
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
printf 'collector_ready\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

printf 'resume_launch_requested\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-resume \
  --lab-experiment-id=E005 \
  "--lab-run-id=$span_run_id" \
  --lab-span-count=100 \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  --lab-flush=disabled \
  --lab-http-client=instrumentedBase \
  --lab-exporter=statelessHTTP > "$resume_launch_log"
printf 'resume_launch_returned\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

sleep 30
printf 'capture_window_complete\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

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
  echo "instrumented HTTP attempt log is missing" >&2
  exit 1
fi
snapshot_persistence "$persistence_dir" "$after_snapshot"

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
