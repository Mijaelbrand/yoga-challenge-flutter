#!/bin/bash

echo "=== BUILD DIAGNOSTIC v1.1.34 ==="
echo ""
echo "1. Current Git Status:"
git status --short
echo ""

echo "2. Current Branch:"
git branch --show-current
echo ""

echo "3. Last 5 Commits:"
git log --oneline -5
echo ""

echo "4. Version in pubspec.yaml:"
grep "^version:" pubspec.yaml
echo ""

echo "5. Constants.dart endpoints:"
grep -E "checkPhoneUrl|getVideoTokenUrl" lib/utils/constants.dart
echo ""

echo "6. Auth provider version marker:"
grep "APP VERSION:" lib/providers/auth_provider.dart | head -1
echo ""

echo "7. Dashboard version marker:"
grep "v1\.[0-9]\.[0-9]* " lib/screens/dashboard_screen.dart | head -1
echo ""

echo "8. File modification times:"
ls -la lib/utils/constants.dart
ls -la lib/providers/auth_provider.dart
ls -la pubspec.yaml
echo ""

echo "=== END DIAGNOSTIC ==="