#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
derived_data="${TMPDIR:-/tmp}/OTelReliabilityLabDerivedData"
source_packages="${TMPDIR:-/tmp}/OTelReliabilityLabSourcePackages"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CLANG_MODULE_CACHE_PATH="${TMPDIR:-/tmp}/OTelReliabilityLabClangCache"
export SWIFTPM_MODULECACHE_OVERRIDE="${TMPDIR:-/tmp}/OTelReliabilityLabSwiftPMCache"

"$repo_dir/scripts/generate-project.sh"

xcodebuild \
  -quiet \
  -project "$repo_dir/OTelReliabilityLab.xcodeproj" \
  -scheme OTelReliabilityLab \
  -sdk iphonesimulator \
  -derivedDataPath "$derived_data" \
  -clonedSourcePackagesDirPath "$source_packages" \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "$derived_data/Build/Products/Debug-iphonesimulator/OTelReliabilityLab.app"

