#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$ROOT_DIR/27SoonTM.xcodeproj"
SCHEME="27SoonTM"
CONFIGURATION="Release"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build-unsigned}"
DERIVED_DATA="$BUILD_DIR/DerivedData"
PAYLOAD_DIR="$BUILD_DIR/Payload"
OUTPUT_IPA="$ROOT_DIR/27SoonTM-unsigned.ipa"

rm -rf "$BUILD_DIR" "$OUTPUT_IPA"
mkdir -p "$BUILD_DIR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

APP_PATH="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphoneos/${SCHEME}.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found: $APP_PATH" >&2
  exit 1
fi

mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"
(
  cd "$BUILD_DIR"
  /usr/bin/zip -qry "$OUTPUT_IPA" Payload
)

if /usr/bin/codesign -dv "$PAYLOAD_DIR/${SCHEME}.app" 2>&1 | grep -q "Signature="; then
  echo "Unexpected code signature found in app bundle; refusing to label this IPA unsigned." >&2
  exit 1
fi

echo "Unsigned IPA created: $OUTPUT_IPA"
echo "Note: this IPA is not installable on iOS devices without signing and provisioning."
