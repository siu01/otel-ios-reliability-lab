#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: scripts/run-e001-late-collector.sh <evidence-run-id> <span-run-uuid> <persistence-mode>" >&2
  exit 64
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$repo_dir/scripts/run-late-collector.sh" \
  E001 \
  "$1" \
  "$2" \
  "$3" \
  explicit
