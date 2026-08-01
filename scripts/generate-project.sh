#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

xcodegen generate --spec "$repo_dir/project.yml" --project "$repo_dir"

