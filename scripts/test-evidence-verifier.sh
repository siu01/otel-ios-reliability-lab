#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_run="$repo_dir/evidence/raw/E016-default-native-batch100-001"
verifier="$repo_dir/scripts/verify-evidence-run.sh"

if [[ ! -d "$source_run" ]]; then
  echo "registered E016 source run is missing" >&2
  exit 1
fi

temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/otel-evidence-mutations.XXXXXX")"
cleanup() {
  rm -rf "$temporary_root"
}
trap cleanup EXIT INT TERM

source_digest() {
  while IFS= read -r evidence_path; do
    shasum -a 256 "$evidence_path"
  done < <(find "$source_run" -maxdepth 1 -type f -print | LC_ALL=C sort) \
    | shasum -a 256 \
    | awk '{print $1}'
}

copy_fixture() {
  local case_name="$1"
  local fixture="$temporary_root/$case_name"
  cp -R "$source_run" "$fixture"
  printf '%s\n' "$fixture"
}

expect_failure() {
  local case_name="$1"
  local fixture="$2"
  local expected_pattern="$3"
  local stdout_path="$temporary_root/$case_name.stdout"
  local stderr_path="$temporary_root/$case_name.stderr"

  if "$verifier" "$fixture" > "$stdout_path" 2> "$stderr_path"; then
    echo "$case_name unexpectedly passed verification" >&2
    exit 1
  fi
  if ! rg -q "$expected_pattern" "$stderr_path"; then
    echo "$case_name failed for the wrong reason" >&2
    sed 's/^/  /' "$stderr_path" >&2
    exit 1
  fi
  printf 'case=%s\tresult=expected-failure\n' "$case_name"
}

before_source_digest="$(source_digest)"

"$verifier" "$source_run" >/dev/null
printf 'case=control\tresult=pass\n'

truncated_fixture="$(copy_fixture truncated-evidence)"
sed '$d' "$truncated_fixture/lifecycle-events.jsonl" \
  > "$temporary_root/truncated-lifecycle.jsonl"
mv "$temporary_root/truncated-lifecycle.jsonl" \
  "$truncated_fixture/lifecycle-events.jsonl"
expect_failure truncated-evidence "$truncated_fixture" 'SHA-256 mismatch'

unlisted_fixture="$(copy_fixture unlisted-evidence)"
touch "$unlisted_fixture/unlisted-observation.txt"
expect_failure unlisted-evidence "$unlisted_fixture" 'inventory does not match'

missing_fixture="$(copy_fixture missing-evidence)"
rm "$missing_fixture/http-attempts.jsonl"
expect_failure missing-evidence "$missing_fixture" 'listed evidence file is missing'

coordinated_fixture="$(copy_fixture coordinated-rewrite)"
old_digest="$(shasum -a 256 "$coordinated_fixture/collector.log" | awk '{print $1}')"
printf '\ncoordinated rewrite fixture\n' >> "$coordinated_fixture/collector.log"
new_digest="$(shasum -a 256 "$coordinated_fixture/collector.log" | awk '{print $1}')"
perl -0pi -e "s/$old_digest/$new_digest/g" "$coordinated_fixture/manifest.md"
"$verifier" "$coordinated_fixture" >/dev/null
printf 'case=coordinated-rewrite\tresult=pass-as-registered\n'

after_source_digest="$(source_digest)"
if [[ "$before_source_digest" != "$after_source_digest" ]]; then
  echo "committed source evidence changed during mutation tests" >&2
  exit 1
fi
printf 'source_evidence_unchanged=true\n'
