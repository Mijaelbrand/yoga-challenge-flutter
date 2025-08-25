@echo off
echo 🧪 Starting iOS Testing for Yoga Challenge App
echo ================================================
echo.

echo Checking if Flutter is installed...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo Please install Flutter first: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo ✅ Flutter is installed
echo.

echo 🔍 Running Flutter doctor...
flutter doctor
echo.

echo ✅ Cleaning previous builds...
flutter clean

echo ✅ Installing dependencies...
flutter pub get

echo ✅ Generating code...
flutter packages pub run build_runner build --delete-conflicting-outputs

echo ✅ Installing iOS dependencies...
cd ios
pod install
cd ..

echo ✅ Running unit and widget tests...
flutter test

if %errorlevel% neq 0 (
    echo ❌ Some tests failed!
    pause
    exit /b 1
)

echo ✅ All tests passed!
echo.

echo 📱 Available devices:
flutter devices
echo.

echo Choose testing option:
echo 1. Run on iOS Simulator
echo 2. Build for iOS device
echo 3. Build for TestFlight
echo 4. Run performance tests
echo 5. All of the above
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo ✅ Running on iOS Simulator...
    flutter run -d ios
) else if "%choice%"=="2" (
    echo ✅ Building for iOS device...
    flutter build ios --release
    echo ✅ iOS build completed! Check build/ios/iphoneos/Runner.app
) else if "%choice%"=="3" (
    echo ✅ Building for TestFlight...
    flutter build ipa --release
    echo ✅ TestFlight build completed! Check build/ios/ipa/
) else if "%choice%"=="4" (
    echo ✅ Running performance tests...
    flutter run -d ios --profile --trace-startup
) else if "%choice%"=="5" (
    echo ✅ Running comprehensive iOS testing...
    echo.
    echo 1. Testing on iOS Simulator...
    start /B flutter run -d ios
    timeout /t 30 /nobreak >nul
    taskkill /F /IM dart.exe >nul 2>&1
    echo.
    echo 2. Building for iOS device...
    flutter build ios --release
    echo.
    echo 3. Building for TestFlight...
    flutter build ipa --release
    echo.
    echo 4. Running performance tests...
    start /B flutter run -d ios --profile --trace-startup
    timeout /t 30 /nobreak >nul
    taskkill /F /IM dart.exe >nul 2>&1
    echo.
    echo ✅ All iOS testing completed!
) else (
    echo ❌ Invalid choice!
    pause
    exit /b 1
)

echo.
echo ✅ iOS testing completed successfully!
echo.
echo 📋 Next steps:
echo 1. Test the app on physical iOS devices
echo 2. Upload to TestFlight for beta testing
echo 3. Submit to App Store for review
echo.
echo 📚 Useful commands:
echo - flutter run -d ios                    # Run on iOS Simulator
echo - flutter build ios --release          # Build for device
echo - flutter build ipa --release          # Build for TestFlight
echo - flutter test --coverage              # Run tests with coverage
echo - flutter analyze                      # Analyze code
echo.

pause

