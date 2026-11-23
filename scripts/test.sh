#!/bin/bash
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${WINDOW_ORGANIZER_BUILD_DIR:-$PROJECT_DIR/.build}"
mkdir -p "$BUILD_DIR"
BUILD_DIR="$(cd "$BUILD_DIR" && pwd)"
export CLANG_MODULE_CACHE_PATH="$BUILD_DIR/clang-cache"
# Standalone Command Line Tools keep Swift Testing outside the SDK search paths.
test_options=(--disable-xctest)
toolchain="$(dirname "$(dirname "$(xcrun --find swiftc)")")"
frameworks="$toolchain/../Library/Developer/Frameworks"
if [[ -d "$frameworks/Testing.framework" ]]; then
  test_options+=(-Xswiftc "-F$frameworks" -Xlinker -rpath -Xlinker "$frameworks")
  test_options+=(-Xlinker -rpath -Xlinker "$frameworks/../usr/lib")
  test_options+=(-Xswiftc -plugin-path -Xswiftc "$toolchain/lib/swift/host/plugins/testing")
fi
swift test "${test_options[@]}" --package-path "$PROJECT_DIR" --scratch-path "$BUILD_DIR" \
  --cache-path "$BUILD_DIR/cache" --config-path "$BUILD_DIR/config" --security-path "$BUILD_DIR/security" --disable-sandbox
