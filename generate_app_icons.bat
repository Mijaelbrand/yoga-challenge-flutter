@echo off
echo Generating app icons from logo...
echo.

echo Installing dependencies...
flutter pub get

echo.
echo Generating app icons for iOS and Android...
flutter pub run flutter_launcher_icons

echo.
echo App icons have been generated successfully!
echo.
echo The following have been updated:
echo - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/
echo - Android: android/app/src/main/res/mipmap-*/
echo.
pause