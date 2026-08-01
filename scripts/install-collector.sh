#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="0.157.0"
archive="otelcol_${version}_darwin_arm64.tar.gz"
expected_sha256="1ea74db004f247948db7f5f99bc88a38a3c017cd5fb9b3a1fb62a98af0caa8c8"
download_url="https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${version}/${archive}"
binary_dir="$repo_dir/collector/bin"
archive_path="$binary_dir/$archive"

mkdir -p "$binary_dir"

if [[ -x "$binary_dir/otelcol" ]] && \
   "$binary_dir/otelcol" --version | grep -q "version $version"; then
  echo "otelcol $version is already installed"
  exit 0
fi

curl --fail --location --output "$archive_path" "$download_url"

actual_sha256="$(shasum -a 256 "$archive_path" | awk '{print $1}')"
if [[ "$actual_sha256" != "$expected_sha256" ]]; then
  echo "checksum mismatch: expected $expected_sha256, got $actual_sha256" >&2
  exit 1
fi

tar -xzf "$archive_path" -C "$binary_dir"
"$binary_dir/otelcol" --version

