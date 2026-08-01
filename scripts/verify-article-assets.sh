#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
article_path="$repo_dir/article/draft.md"
asset_dir="$repo_dir/article/assets"

temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/otel-article-assets.XXXXXX")"
cleanup() {
  rm -rf "$temporary_dir"
}
trap cleanup EXIT INT TERM

references_path="$temporary_dir/references.txt"
rg -o '\./assets/[^)]+' "$article_path" | LC_ALL=C sort -u > "$references_path"
reference_count="$(wc -l < "$references_path" | tr -d ' ')"
if [[ "$reference_count" == "0" ]]; then
  echo "article contains no asset references" >&2
  exit 1
fi

verified_assets=0
while IFS= read -r reference; do
  relative_asset_path="${reference#./}"
  asset_path="$repo_dir/article/$relative_asset_path"
  if [[ ! -f "$asset_path" ]]; then
    echo "article references a missing asset: $reference" >&2
    exit 1
  fi

  filename="$(basename "$asset_path")"
  extension="${filename##*.}"
  basename_without_extension="${filename%.*}"
  metadata_path="$asset_dir/$basename_without_extension.md"
  if [[ ! -s "$metadata_path" ]]; then
    echo "article asset metadata is missing: $metadata_path" >&2
    exit 1
  fi

  case "$extension" in
    png) digest_label="PNG" ;;
    svg)
      digest_label="SVG"
      xmllint --noout "$asset_path"
      ;;
    *)
      echo "unsupported article asset extension: $filename" >&2
      exit 1
      ;;
  esac

  expected_digest="$(awk -F'`' -v label="$digest_label" '
    index($0, "- " label ":") == 1 && NF >= 3 { print $2 }
  ' "$metadata_path")"
  if [[ ! "$expected_digest" =~ ^[0-9a-f]{64}$ ]]; then
    echo "metadata has no valid $digest_label digest: $metadata_path" >&2
    exit 1
  fi
  actual_digest="$(shasum -a 256 "$asset_path" | awk '{print $1}')"
  if [[ "$actual_digest" != "$expected_digest" ]]; then
    echo "article asset digest mismatch: $filename" >&2
    echo "  expected $expected_digest" >&2
    echo "  actual   $actual_digest" >&2
    exit 1
  fi
  verified_assets=$((verified_assets + 1))
done < "$references_path"

printf 'verified_article_assets=%s\n' "$verified_assets"
