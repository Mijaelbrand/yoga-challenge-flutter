@echo off
echo ========================================
echo Cloud-Based iOS Development Setup
echo ========================================
echo.

echo This script will help you set up cloud-based iOS development
echo for your Yoga Challenge Flutter app.
echo.

echo Prerequisites:
echo - GitHub account
echo - Git installed
echo - Flutter project ready
echo.

echo Step 1: Create GitHub Repository
echo ========================================
echo.
echo 1. Go to https://github.com
echo 2. Click "New repository"
echo 3. Name: yoga-challenge-flutter
echo 4. Description: Yoga Challenge Flutter App with iOS Support
echo 5. Make it PUBLIC (for free GitHub Actions)
echo 6. Don't initialize with README
echo 7. Click "Create repository"
echo.

set /p github_url="Enter your GitHub repository URL (e.g., https://github.com/username/yoga-challenge-flutter.git): "

if "%github_url%"=="" (
    echo Please enter a valid GitHub URL
    pause
    exit /b 1
)

echo.
echo Step 2: Configure Git Remote
echo ========================================
echo.

echo Adding GitHub as remote origin...
git remote add origin %github_url%

if %errorlevel% neq 0 (
    echo Failed to add remote. Please check your GitHub URL.
    pause
    exit /b 1
)

echo.
echo Step 3: Push to GitHub
echo ========================================
echo.

echo Renaming branch to main...
git branch -M main

echo Pushing to GitHub...
git push -u origin main

if %errorlevel% neq 0 (
    echo Failed to push to GitHub. Please check your credentials.
    echo You may need to authenticate with GitHub.
    pause
    exit /b 1
)

echo.
echo Step 4: Enable GitHub Actions
echo ========================================
echo.
echo 1. Go to your repository on GitHub: %github_url%
echo 2. Click on "Actions" tab
echo 3. You should see the iOS workflow we created
echo 4. Click "Run workflow" to test it
echo.

echo Step 5: Monitor Your First Build
echo ========================================
echo.
echo Your first iOS build will:
echo - Install Flutter and dependencies
echo - Build your iOS app
echo - Run all tests
echo - Generate build artifacts
echo - Upload results for download
echo.

echo Step 6: Next Steps
echo ========================================
echo.
echo After your first successful build:
echo.
echo 1. Download build artifacts from GitHub Actions
echo 2. Set up Codemagic for TestFlight builds (optional)
echo 3. Test on physical iOS devices
echo 4. Prepare for App Store submission
echo.

echo Useful Commands:
echo ========================================
echo.
echo To make changes and trigger new builds:
echo   git add .
echo   git commit -m "Your commit message"
echo   git push
echo.
echo To check build status:
echo   - Go to GitHub repository Actions tab
echo   - Monitor build progress
echo   - Download artifacts when complete
echo.

echo Testing Workflow:
echo ========================================
echo.
echo 1. Test on Android locally first:
echo    flutter run
echo.
echo 2. Run tests locally:
echo    flutter test
echo.
echo 3. Push changes to trigger iOS build:
echo    git add . && git commit -m "Update" && git push
echo.
echo 4. Monitor iOS build in GitHub Actions
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Your Flutter project is now set up for cloud-based iOS development.
echo.
echo Repository: %github_url%
echo.
echo Next: Go to GitHub and enable Actions to start your first iOS build!
echo.

pause

