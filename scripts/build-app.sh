#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="MarkdownPreviewer"
DISPLAY_NAME="Markdown Previewer"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$DISPLAY_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
ICON_FILE="$ROOT_DIR/Packaging/MarkdownPreviewer.icns"
CODESIGN_IDENTITY="${CODESIGN_IDENTITY:--}"
BUILD_DIR="$ROOT_DIR/.build/universal"
BINARY_PATH="$BUILD_DIR/apple/Products/Release/$APP_NAME"
ZIPFOUNDATION_RESOURCES="$BUILD_DIR/apple/Products/Release/ZIPFoundation_ZIPFoundation.bundle"

cd "$ROOT_DIR"

if [[ ! -f "$ICON_FILE" ]]; then
  scripts/build-icon.sh
fi

swift build \
  -c release \
  --arch x86_64 \
  --arch arm64 \
  --build-path "$BUILD_DIR"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$BINARY_PATH" "$MACOS_DIR/$APP_NAME"
cp "$ROOT_DIR/Packaging/Info.plist" "$CONTENTS_DIR/Info.plist"
if [[ -f "$ICON_FILE" ]]; then
  cp "$ICON_FILE" "$RESOURCES_DIR/MarkdownPreviewer.icns"
fi
if [[ -d "$ZIPFOUNDATION_RESOURCES" ]]; then
  ditto "$ZIPFOUNDATION_RESOURCES" "$RESOURCES_DIR/ZIPFoundation_ZIPFoundation.bundle"
fi
chmod +x "$MACOS_DIR/$APP_NAME"

if [[ -n "$CODESIGN_IDENTITY" ]] && command -v codesign >/dev/null 2>&1; then
  if [[ "$CODESIGN_IDENTITY" == "-" ]]; then
    codesign --force --sign - "$APP_DIR" >/dev/null
  else
    codesign \
      --force \
      --options runtime \
      --timestamp \
      --sign "$CODESIGN_IDENTITY" \
      "$APP_DIR" >/dev/null
  fi
fi

echo "Built: $APP_DIR"
