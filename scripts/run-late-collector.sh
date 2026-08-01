#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 5 || $# -gt 7 ]]; then
  echo "usage: scripts/run-late-collector.sh <experiment-id> <evidence-run-id> <span-run-uuid> <persistence-mode> <flush-mode> [http-client-mode] [collector-delay-seconds]" >&2
  exit 64
fi

experiment_id="$1"
evidence_run_id="$2"
span_run_id="$3"
persistence_mode="$4"
flush_mode="$5"
http_client_mode="${6:-officialBase}"
collector_delay_seconds="${7:-8}"

if [[ ! "$experiment_id" =~ ^E[0-9]{3}$ ]]; then
  echo "invalid experiment ID" >&2
  exit 64
fi
if [[ ! "$evidence_run_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "invalid evidence run ID" >&2
  exit 64
fi
if [[ ! "$span_run_id" =~ ^[0-9A-Fa-f-]{36}$ ]]; then
  echo "invalid span run UUID" >&2
  exit 64
fi
case "$persistence_mode" in
  disabled|officialDefault|officialInstant) ;;
  *)
    echo "invalid persistence mode" >&2
    exit 64
    ;;
esac
case "$flush_mode" in
  disabled|explicit) ;;
  *)
    echo "invalid flush mode" >&2
    exit 64
    ;;
esac
case "$http_client_mode" in
  officialBase|instrumentedBase) ;;
  *)
    echo "invalid HTTP client mode" >&2
    exit 64
    ;;
esac
if [[ ! "$collector_delay_seconds" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "invalid Collector delay" >&2
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
persistence_snapshot="$run_dir/persistence-files-after.tsv"
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
trap cleanup_collector EXIT INT TERM

for path in "$capture_path" "$collector_log" "$timing_log" "$persistence_snapshot" "$http_attempts_path"; do
  if [[ -e "$path" ]]; then
    echo "refusing to overwrite existing evidence: $path" >&2
    exit 1
  fi
done
if [[ ! -x "$collector_binary" ]]; then
  echo "collector is missing; run scripts/install-collector.sh" >&2
  exit 1
fi
if [[ ! -d "$app_path" ]]; then
  echo "app build is missing; run scripts/build-simulator.sh" >&2
  exit 1
fi

mkdir -p "$run_dir"
printf 'event\tutc_timestamp\n' > "$timing_log"

# A clean install prevents files from previous persistence runs from becoming a
# hidden retry source.
set +e
xcrun simctl terminate "$simulator_udid" "$bundle_id" >/dev/null 2>&1
xcrun simctl uninstall "$simulator_udid" "$bundle_id" >/dev/null 2>&1
set -e
xcrun simctl install "$simulator_udid" "$app_path"

printf 'app_launch_requested\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"
xcrun simctl launch \
  "$simulator_udid" \
  "$bundle_id" \
  --lab-autorun \
  "--lab-experiment-id=$experiment_id" \
  "--lab-run-id=$span_run_id" \
  --lab-span-count=100 \
  --lab-transport=http \
  "--lab-persistence=$persistence_mode" \
  "--lab-flush=$flush_mode" \
  "--lab-http-client=$http_client_mode"
printf 'app_launch_returned\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

sleep "$collector_delay_seconds"

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

sleep 30
printf 'capture_window_complete\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$timing_log"

cleanup_collector
collector_pid=""

if [[ ! -e "$capture_path" ]]; then
  touch "$capture_path"
fi

app_container="$(xcrun simctl get_app_container "$simulator_udid" "$bundle_id" data)"
lower_span_run_id="$(printf '%s' "$span_run_id" | tr '[:upper:]' '[:lower:]')"
app_run_dir="$app_container/Library/Application Support/OTelReliabilityLab/runs/$lower_span_run_id"
persistence_dir="$app_container/Library/Application Support/OTelReliabilityLab/persistence/$persistence_mode"
cp "$app_run_dir/generated.jsonl" "$run_dir/generated.jsonl"
cp "$app_run_dir/run.json" "$run_dir/run.json"
if [[ -f "$app_run_dir/http-attempts.jsonl" ]]; then
  cp "$app_run_dir/http-attempts.jsonl" "$http_attempts_path"
elif [[ "$http_client_mode" == "instrumentedBase" ]]; then
  echo "instrumented HTTP attempt log is missing" >&2
  exit 1
fi

if [[ -d "$persistence_dir" ]]; then
  printf '# directory_exists=true\n' > "$persistence_snapshot"
else
  printf '# directory_exists=false\n' > "$persistence_snapshot"
fi
printf 'relative_path\tbytes\tsha256\n' >> "$persistence_snapshot"
if [[ -d "$persistence_dir" ]]; then
  while IFS= read -r persistence_file; do
    relative_path="${persistence_file#"$persistence_dir"/}"
    byte_count="$(stat -f '%z' "$persistence_file")"
    digest="$(shasum -a 256 "$persistence_file" | awk '{print $1}')"
    printf '%s\t%s\t%s\n' "$relative_path" "$byte_count" "$digest" >> "$persistence_snapshot"
  done < <(find "$persistence_dir" -type f -print | sort)
fi
xcrun simctl terminate "$simulator_udid" "$bundle_id"

"$repo_dir/scripts/reconcile-run.sh" "$run_dir"
