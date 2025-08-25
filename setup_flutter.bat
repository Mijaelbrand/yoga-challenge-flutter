@echo off
echo ========================================
echo Flutter iOS Development Setup
echo ========================================
echo.

echo Checking if Flutter is installed...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed or not in PATH
    echo.
    echo Please install Flutter first:
    echo 1. Download from: https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to your PATH
    echo 4. Restart this script
    echo.
    pause
    exit /b 1
)

echo Flutter is installed!
echo.

echo Running flutter doctor...
flutter doctor

echo.
echo ========================================
echo iOS Development Requirements:
echo ========================================
echo.
echo IMPORTANT: iOS development requires macOS and Xcode
echo.
echo Options for iOS development:
echo.
echo 1. LOCAL MAC:
echo    - Install Xcode from Mac App Store
echo    - Install CocoaPods: sudo gem install cocoapods
echo    - Run: flutter doctor
echo.
echo 2. CLOUD SERVICES:
echo    - Codemagic (https://codemagic.io/)
echo    - GitHub Actions with macOS runners
echo    - MacStadium (https://www.macstadium.com/)
echo.
echo 3. TEST ON ANDROID FIRST:
echo    - Test your app on Android to ensure it works
echo    - Use Flutter Web for UI testing
echo.
echo ========================================
echo.

echo Current project status:
echo.
echo Available commands:
echo - flutter pub get          (install dependencies)
echo - flutter run              (run on connected device)
echo - flutter build apk        (build Android APK)
echo - flutter build ios        (build iOS - requires Mac)
echo - flutter build web        (build web version)
echo.

echo Would you like to install dependencies now? (y/n)
set /p choice=
if /i "%choice%"=="y" (
    echo Installing dependencies...
    flutter pub get
    echo.
    echo Dependencies installed!
    echo.
    echo Next steps:
    echo 1. Connect an Android device or start an emulator
    echo 2. Run: flutter run
    echo 3. For iOS: Set up Mac environment and run: flutter run -d ios
)

pause


