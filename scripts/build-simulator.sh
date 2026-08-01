#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_root="${LAB_TMP_ROOT:-/tmp}"
derived_data="$tmp_root/OTelReliabilityLabDerivedData"
source_packages="$tmp_root/OTelReliabilityLabSourcePackages"

export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export CLANG_MODULE_CACHE_PATH="$tmp_root/OTelReliabilityLabClangCache"
export SWIFTPM_MODULECACHE_OVERRIDE="$tmp_root/OTelReliabilityLabSwiftPMCache"

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
