@echo off
echo ========================================
echo Yoga Challenge Flutter App Builder
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Generating JSON models...
flutter packages pub run build_runner build
if %errorlevel% neq 0 (
    echo WARNING: Failed to generate JSON models
    echo This might be expected if no models need generation
)

echo.
echo Available commands:
echo 1. Run on connected device: flutter run
echo 2. Build APK: flutter build apk
echo 3. Build APK (release): flutter build apk --release
echo 4. Clean project: flutter clean
echo 5. Get dependencies: flutter pub get
echo.

set /p choice="Enter your choice (1-5) or press Enter to run on device: "

if "%choice%"=="1" (
    flutter run
) else if "%choice%"=="2" (
    flutter build apk
) else if "%choice%"=="3" (
    flutter build apk --release
) else if "%choice%"=="4" (
    flutter clean
) else if "%choice%"=="5" (
    flutter pub get
) else (
    flutter run
)

echo.
echo Build process completed!
pause
