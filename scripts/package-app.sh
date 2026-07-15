#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: package-app.sh <version> <build-number> <arm64-binary> <x86_64-binary> <output-dir>}"
BUILD_NUMBER="${2:?Missing build number}"
ARM64_BINARY="${3:?Missing arm64 binary}"
X86_BINARY="${4:?Missing x86_64 binary}"
OUTPUT_DIR="${5:?Missing output directory}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SwiftUIDemo"
APP_BUNDLE="$OUTPUT_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

rm -rf "$OUTPUT_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

lipo -create "$ARM64_BINARY" "$X86_BINARY" -output "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/$APP_NAME"

cp "$ROOT_DIR/Packaging/Info.plist" "$CONTENTS/Info.plist"
ICON_OUTPUT="$OUTPUT_DIR/generated-icon"
mkdir -p "$ICON_OUTPUT"
swift "$ROOT_DIR/scripts/generate-icon.swift" "$ICON_OUTPUT"
cp "$ICON_OUTPUT/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"
rm -rf "$ICON_OUTPUT"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$CONTENTS/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$CONTENTS/Info.plist"

SIGNING_IDENTITY="-"
if [[ -n "${MACOS_CERTIFICATE:-}" && -n "${MACOS_CERTIFICATE_PASSWORD:-}" && -n "${DEVELOPER_ID_APPLICATION:-}" ]]; then
    KEYCHAIN_PATH="$RUNNER_TEMP/swiftuidemo-signing.keychain-db"
    KEYCHAIN_PASSWORD="${KEYCHAIN_PASSWORD:-swiftuidemo-ci}"
    CERTIFICATE_PATH="$RUNNER_TEMP/swiftuidemo-certificate.p12"

    echo "$MACOS_CERTIFICATE" | base64 --decode > "$CERTIFICATE_PATH"
    security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
    security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
    security import "$CERTIFICATE_PATH" -P "$MACOS_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
    security list-keychain -d user -s "$KEYCHAIN_PATH"
    security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
    SIGNING_IDENTITY="$DEVELOPER_ID_APPLICATION"
fi

if [[ "$SIGNING_IDENTITY" == "-" ]]; then
    codesign --force --deep --sign - "$APP_BUNDLE"
else
    codesign --force --deep --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP_BUNDLE"
fi

codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"
file "$MACOS_DIR/$APP_NAME"

create_zip() {
    local destination="$1"
    rm -f "$destination"
    ditto -c -k --sequesterRsrc --keepParent "$APP_BUNDLE" "$destination"
}

create_dmg() {
    local destination="$1"
    local stage="$OUTPUT_DIR/dmg-stage"
    rm -rf "$stage" "$destination"
    mkdir -p "$stage"
    cp -R "$APP_BUNDLE" "$stage/"
    ln -s /Applications "$stage/Applications"
    hdiutil create \
        -volname "SwiftUI Demo" \
        -srcfolder "$stage" \
        -ov \
        -format UDZO \
        "$destination"
    rm -rf "$stage"
}

ZIP_PATH="$OUTPUT_DIR/$APP_NAME-$VERSION-universal.zip"
DMG_PATH="$OUTPUT_DIR/$APP_NAME-$VERSION-universal.dmg"

if [[ "$SIGNING_IDENTITY" != "-" && -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
    TEMP_ZIP="$OUTPUT_DIR/notarization-upload.zip"
    create_zip "$TEMP_ZIP"
    xcrun notarytool submit "$TEMP_ZIP" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait
    xcrun stapler staple "$APP_BUNDLE"
    rm -f "$TEMP_ZIP"
fi

create_zip "$ZIP_PATH"
create_dmg "$DMG_PATH"

if [[ "$SIGNING_IDENTITY" != "-" && -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --password "$APPLE_APP_SPECIFIC_PASSWORD" \
        --team-id "$APPLE_TEAM_ID" \
        --wait
    xcrun stapler staple "$DMG_PATH"
fi

(
    cd "$OUTPUT_DIR"
    shasum -a 256 "$(basename "$ZIP_PATH")" "$(basename "$DMG_PATH")" > SHA256SUMS.txt
)

echo "Created:"
echo "  $ZIP_PATH"
echo "  $DMG_PATH"
echo "  $OUTPUT_DIR/SHA256SUMS.txt"
