#!/bin/bash

echo "=== DEPENDENCY RESET SCRIPT ==="
echo ""
echo "This script forces a complete dependency refresh"
echo ""

# Step 1: Clean everything
echo "Step 1: Cleaning project..."
flutter clean
rm -f pubspec.lock
rm -rf .dart_tool/
rm -rf .packages
rm -rf build/

echo ""
echo "Step 2: Getting fresh dependencies..."
flutter pub get

echo ""
echo "Step 3: Upgrading dependencies to latest compatible versions..."
flutter pub upgrade

echo ""
echo "Step 4: Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "Step 5: Verifying package versions..."
echo "Key packages that should NOT be downgraded:"
echo ""
grep "dart_style:" pubspec.lock | head -2
grep "analyzer:" pubspec.lock | head -2
grep "build_runner:" pubspec.lock | head -2
grep "http:" pubspec.lock | head -2

echo ""
echo "=== DEPENDENCY RESET COMPLETE ==="
echo ""
echo "If packages still show old versions, try:"
echo "1. flutter upgrade"
echo "2. flutter pub cache clean"
echo "3. Re-run this script"