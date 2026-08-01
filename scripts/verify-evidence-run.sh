#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: scripts/verify-evidence-run.sh <evidence-run-directory>" >&2
  exit 64
fi

run_dir="$1"
manifest_path="$run_dir/manifest.md"
if [[ ! -d "$run_dir" ]]; then
  echo "evidence run directory does not exist: $run_dir" >&2
  exit 1
fi
if [[ ! -s "$manifest_path" ]]; then
  echo "evidence manifest is missing or empty: $manifest_path" >&2
  exit 1
fi

temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/otel-evidence-verify.XXXXXX")"
cleanup() {
  rm -rf "$temporary_dir"
}
trap cleanup EXIT INT TERM

manifest_rows="$temporary_dir/manifest-rows.tsv"
listed_files="$temporary_dir/listed-files.txt"
actual_files="$temporary_dir/actual-files.txt"
duplicate_files="$temporary_dir/duplicate-files.txt"

awk -F'`' '
  NF >= 5 && $4 ~ /^[0-9a-f]{64}$/ {
    print $2 "\t" $4
  }
' "$manifest_path" > "$manifest_rows"

row_count="$(wc -l < "$manifest_rows" | tr -d ' ')"
if [[ "$row_count" == "0" ]]; then
  echo "manifest contains no parseable SHA-256 rows" >&2
  exit 1
fi

cut -f1 "$manifest_rows" | LC_ALL=C sort > "$listed_files"
uniq -d "$listed_files" > "$duplicate_files"
if [[ -s "$duplicate_files" ]]; then
  echo "manifest contains duplicate file entries:" >&2
  sed 's/^/  /' "$duplicate_files" >&2
  exit 1
fi

while IFS=$'\t' read -r filename expected_digest; do
  if [[ ! "$filename" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "manifest contains an unsafe filename: $filename" >&2
    exit 1
  fi
  evidence_path="$run_dir/$filename"
  if [[ ! -f "$evidence_path" ]]; then
    echo "listed evidence file is missing: $filename" >&2
    exit 1
  fi
  actual_digest="$(shasum -a 256 "$evidence_path" | awk '{print $1}')"
  if [[ "$actual_digest" != "$expected_digest" ]]; then
    echo "SHA-256 mismatch: $filename" >&2
    echo "  expected $expected_digest" >&2
    echo "  actual   $actual_digest" >&2
    exit 1
  fi
done < "$manifest_rows"

find "$run_dir" \
  -maxdepth 1 \
  -type f \
  ! -name manifest.md \
  -exec basename {} \; | LC_ALL=C sort > "$actual_files"

if ! diff -u "$listed_files" "$actual_files" >/dev/null; then
  echo "manifest inventory does not match evidence files" >&2
  diff -u "$listed_files" "$actual_files" >&2 || true
  exit 1
fi

printf 'verified_run=%s\n' "$(basename "$run_dir")"
printf 'verified_files=%s\n' "$row_count"
