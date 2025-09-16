#!/bin/bash

# Build DMG for macOS
echo "🎵 Building MusicX for macOS..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Build the macOS app
echo -e "${YELLOW}Building macOS app...${NC}"
flutter build macos --release

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to build macOS app${NC}"
    exit 1
fi

echo -e "${GREEN}✓ macOS app built successfully${NC}"

# Step 2: Check if create-dmg is installed
if ! command -v create-dmg &> /dev/null; then
    echo -e "${YELLOW}create-dmg not found. Installing via Homebrew...${NC}"
    brew install create-dmg
fi

# Step 3: Variables
APP_NAME="music_app"
DMG_NAME="MusicX-macOS"
APP_PATH="build/macos/Build/Products/Release/${APP_NAME}.app"
OUTPUT_DMG="${DMG_NAME}.dmg"

# Remove old DMG if exists
if [ -f "$OUTPUT_DMG" ]; then
    echo -e "${YELLOW}Removing old DMG file...${NC}"
    rm "$OUTPUT_DMG"
fi

# Step 4: Create DMG
echo -e "${YELLOW}Creating DMG installer...${NC}"

create-dmg \
  --volname "MusicX" \
  --window-pos 200 120 \
  --window-size 800 450 \
  --icon-size 100 \
  --icon "${APP_NAME}.app" 200 190 \
  --hide-extension "${APP_NAME}.app" \
  --app-drop-link 600 185 \
  --no-internet-enable \
  "$OUTPUT_DMG" \
  "$APP_PATH"

# Check if DMG creation was successful
if [ -f "$OUTPUT_DMG" ]; then
    # Get file size
    SIZE=$(du -h "$OUTPUT_DMG" | cut -f1)
    echo -e "${GREEN}✅ DMG created successfully: ${OUTPUT_DMG} (${SIZE})${NC}"
    echo -e "${GREEN}📍 Location: $(pwd)/${OUTPUT_DMG}${NC}"
else
    echo -e "${RED}Failed to create DMG${NC}"

    # Fallback method using hdiutil
    echo -e "${YELLOW}Trying fallback method with hdiutil...${NC}"
    hdiutil create -volname "MusicX" \
        -srcfolder "$APP_PATH" \
        -ov -format UDZO \
        "$OUTPUT_DMG"

    if [ -f "$OUTPUT_DMG" ]; then
        SIZE=$(du -h "$OUTPUT_DMG" | cut -f1)
        echo -e "${GREEN}✅ DMG created successfully with fallback method: ${OUTPUT_DMG} (${SIZE})${NC}"
        echo -e "${GREEN}📍 Location: $(pwd)/${OUTPUT_DMG}${NC}"
    else
        echo -e "${RED}Failed to create DMG with both methods${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}🎉 Build complete!${NC}"