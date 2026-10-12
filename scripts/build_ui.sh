#!/usr/bin/env bash
# Compile the native UI without packaging the C++ renderers or .NET service.
# This is a development artifact, not a distributable wallpaper player.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
xcodebuild \
    -project "$ROOT_DIR/Mirage/Mirage Wallpaper.xcodeproj" \
    -scheme "Mirage Wallpaper" \
    -configuration Debug \
    -derivedDataPath "$ROOT_DIR/.build/ui" \
    -destination "platform=macOS" \
    -onlyUsePackageVersionsFromResolvedFile \
    MIRAGE_UI_PREVIEW_BUILD=1 CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES build
