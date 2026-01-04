#!/bin/bash

# Icon Generation Script for Easy Calendar Widget
# Usage: ./scripts/generate_icons.sh <source_image.png>
#
# This script generates all required app icon sizes for macOS from a source image.
# The source image should be at least 1024x1024 pixels.

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <source_image.png>"
    echo "Example: $0 AppIcon-Source.png"
    exit 1
fi

SOURCE="$1"

if [ ! -f "$SOURCE" ]; then
    echo "Error: Source file '$SOURCE' not found"
    exit 1
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Output directories
MAIN_APP_ICONS="$PROJECT_DIR/EasyCalendarWidget/Assets.xcassets/AppIcon.appiconset"
WIDGET_ICONS="$PROJECT_DIR/CalendarWidgetExtension/Assets.xcassets/AppIcon.appiconset"

echo "Generating icons from: $SOURCE"
echo "Main app icons: $MAIN_APP_ICONS"
echo "Widget icons: $WIDGET_ICONS"

# Icon sizes for macOS (size@scale)
# 16x16 @1x, 16x16 @2x (32px)
# 32x32 @1x, 32x32 @2x (64px)
# 128x128 @1x, 128x128 @2x (256px)
# 256x256 @1x, 256x256 @2x (512px)
# 512x512 @1x, 512x512 @2x (1024px)

declare -a SIZES=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

generate_icons() {
    local output_dir="$1"

    for size_info in "${SIZES[@]}"; do
        IFS=':' read -r size filename <<< "$size_info"
        output_file="$output_dir/$filename"

        echo "  Creating ${size}x${size} -> $filename"
        sips -z "$size" "$size" "$SOURCE" --out "$output_file" > /dev/null 2>&1
    done
}

echo ""
echo "Generating main app icons..."
generate_icons "$MAIN_APP_ICONS"

echo ""
echo "Generating widget extension icons..."
generate_icons "$WIDGET_ICONS"

echo ""
echo "Done! Icons generated successfully."
echo ""
echo "Next steps:"
echo "1. Open Xcode and verify the icons appear in Assets.xcassets"
echo "2. Clean build folder (Cmd+Shift+K) and rebuild"
