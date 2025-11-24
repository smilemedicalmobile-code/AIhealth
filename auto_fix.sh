#!/bin/bash

echo "🔧 Fixing localization setup..."

# Clean build
echo "1️⃣ Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/AIhealth-*

# Verify localization files exist
echo "2️⃣ Verifying localization files..."
ls -la /Users/chaedongjoo/Developer/AIhealth/AIhealth/Resources/*/Localizable.strings

# Build the project to regenerate bundle
echo "3️⃣ Building project..."
cd /Users/chaedongjoo/Developer/AIhealth
xcodebuild -scheme AIhealth -sdk iphonesimulator -destination 'platform=iOS Simulator,id=5A0000F5-C495-4173-B07F-C868CAFFDB1B' build > /dev/null 2>&1

# Check if localization files are in the app bundle
echo "4️⃣ Checking app bundle..."
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/AIhealth-*/Build/Products/Debug-iphonesimulator/AIhealth.app -maxdepth 0 2>/dev/null | head -1)

if [ -n "$APP_PATH" ]; then
    echo "📦 App bundle found at: $APP_PATH"
    echo ""
    echo "Checking for localization resources in bundle:"
    ls -la "$APP_PATH"/*.lproj 2>/dev/null || echo "❌ No .lproj folders found in bundle"
    echo ""
    echo "Localizable.strings files in bundle:"
    find "$APP_PATH" -name "Localizable.strings" -type f
else
    echo "❌ App bundle not found"
fi

echo ""
echo "✅ Done!"
