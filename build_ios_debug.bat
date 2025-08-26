@echo off
echo Building iOS app (Debug mode with logs)...
echo Version: 1.1.18+19
echo Build Date: %date% %time%

REM Clean build artifacts
"C:\Users\mijae\flutter\bin\flutter.bat" clean

REM Get dependencies
"C:\Users\mijae\flutter\bin\flutter.bat" pub get

REM Build iOS app in debug mode (shows all logs and errors)
"C:\Users\mijae\flutter\bin\flutter.bat" build ios --debug --no-codesign

echo Build complete! Debug build includes:
echo - Full error logging and stack traces
echo - dart:developer log() output
echo - Debug overlay visible in app
echo - All exceptions will show red error screen
pause