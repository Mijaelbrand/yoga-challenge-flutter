@echo off
echo Pushing Flutter changes to trigger iOS build...
echo.

echo Navigating to Flutter project directory...
cd /d "E:\Akila Challenge APP\yoga_challenge_flutter"

echo.
echo Adding all changes to git...
git add .

echo.
echo Creating commit with all UI and phone fixes...
git commit -m "Fix iOS app to match Android: colors, logo, text, phone validation

- Updated color scheme from green to indigo (#4F52BD) to match Android
- Added actual logo image to splash screen and welcome screen  
- Generated app icons from logo for both iOS and Android
- Updated all text strings to match Android app exactly
- Fixed phone number input to allow spaces, dashes, parentheses
- Fixed phone validation to match Android (string length >= 10)
- Fixed phone encoding to only replace + with %%2B like Android
- Updated input formatters and hints for better UX

🤖 Generated with Claude Code"

echo.
echo Pushing to GitHub to trigger Actions build...
git push

echo.
echo ✅ Changes pushed! GitHub Actions should now build the iOS app.
echo Check: https://github.com/your-username/your-repo/actions
echo.
pause