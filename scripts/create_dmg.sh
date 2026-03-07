#!/bin/bash
set -euo pipefail

# Configuration
APP_NAME="EasyCalendarWidget"
SCHEME="EasyCalendarWidget"
BUILD_DIR="$(pwd)/build"
DMG_DIR="${BUILD_DIR}/dmg"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
APP_PATH="${DMG_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

echo "==> Cleaning build directory..."
rm -rf "${BUILD_DIR}"
mkdir -p "${DMG_DIR}"

echo "==> Archiving ${SCHEME}..."
xcodebuild archive \
    -project EasyCalendarWidget.xcodeproj \
    -scheme "${SCHEME}" \
    -configuration Release \
    -archivePath "${ARCHIVE_PATH}" \
    -quiet

echo "==> Exporting app from archive..."
# Create export options plist
EXPORT_OPTIONS="${BUILD_DIR}/ExportOptions.plist"
cat > "${EXPORT_OPTIONS}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>TQV66JM3KL</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${DMG_DIR}" \
    -exportOptionsPlist "${EXPORT_OPTIONS}" \
    -quiet 2>/dev/null || {
    echo "==> Signed export failed, falling back to unsigned export..."
    # Fallback: copy app directly from archive
    cp -R "${ARCHIVE_PATH}/Products/Applications/${APP_NAME}.app" "${DMG_DIR}/"
}

echo "==> Creating DMG..."
# Create a temporary DMG
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

echo ""
echo "==> Done! DMG created at: ${DMG_PATH}"
echo "    Size: $(du -h "${DMG_PATH}" | cut -f1)"
