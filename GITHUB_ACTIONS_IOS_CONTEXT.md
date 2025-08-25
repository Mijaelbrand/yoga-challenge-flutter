# GitHub Actions iOS Build Context

## 🎯 Project Overview
**Project**: Yoga Challenge Flutter App  
**Location**: E:\Akila Challenge APP\yoga_challenge_flutter  
**Purpose**: Cross-platform yoga challenge app with iOS and Android support

## 📱 iOS Configuration

### Bundle Information
- **Bundle ID**: com.akila.yogachallenge
- **Display Name**: Yoga Challenge
- **App Name**: yoga_challenge
- **Version**: Uses FLUTTER_BUILD_NAME and FLUTTER_BUILD_NUMBER

### Permissions Required
- Camera access (video features)
- Microphone access (video features)
- Photo library access (saving content)
- Location access (personalized content)

### Background Modes Enabled
- Background fetch
- Remote notifications

## 🔧 GitHub Actions Workflow

### Current Workflow File
**Location**: `.github/workflows/ios_build.yml`

### Workflow Configuration
- **Triggers**: 
  - Push to main or develop branches
  - Pull requests to main branch
- **Runner**: macOS-latest
- **Flutter Version**: 3.19.0 (stable channel)

### Build Steps
1. Checkout code (actions/checkout@v4)
2. Setup Flutter (subosito/flutter-action@v2)
3. Install Flutter dependencies (`flutter pub get`)
4. Generate code (`flutter packages pub run build_runner build --delete-conflicting-outputs`)
5. Install iOS dependencies (`cd ios && pod install`)
6. Build iOS app (`flutter build ios --release --no-codesign`)
7. Upload artifacts (Runner.app, 30-day retention)

### Test Job
- Runs on macOS-latest
- Executes Flutter tests
- Runs code analysis
- Uploads test results and coverage

## 🛠️ Dependencies

### Key Flutter Packages
- **State Management**: provider ^6.1.1
- **HTTP**: http ^1.1.0, dio ^5.3.2
- **Storage**: shared_preferences ^2.2.2, sqflite ^2.3.0
- **Video**: video_player ^2.8.1, chewie ^1.7.4, webview_flutter ^4.4.2
- **Notifications**: flutter_local_notifications ^16.3.0
- **Permissions**: permission_handler ^11.0.1
- **Background Tasks**: workmanager ^0.5.2

### Build Dependencies
- json_serializable ^6.7.1
- build_runner ^2.4.7

## ⚠️ Known Issues & Solutions

### Common Build Failures

#### 1. Pod Installation Issues
**Error**: CocoaPods dependencies installation failure
**Solution**:
```bash
cd ios
pod repo update
pod install --repo-update
```

#### 2. Build Runner Conflicts
**Error**: Conflicting outputs in build_runner
**Solution**: Already handled with `--delete-conflicting-outputs` flag

#### 3. Code Signing Issues
**Current Setup**: Building with `--no-codesign` flag
**For Distribution**: Need to configure signing certificates in GitHub Secrets

#### 4. Missing Podfile
**Status**: Podfile not found in ios directory
**Action Required**: Need to generate or create Podfile

## 🔐 Required GitHub Secrets (Not Yet Configured)

For future TestFlight/App Store deployment:
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`
- `CERTIFICATE_PASSWORD`
- `P12_CERTIFICATE`
- `PROVISIONING_PROFILE`

## 📋 Pre-Build Checklist

### Local Setup Required
1. ✅ Flutter project initialized
2. ✅ iOS Runner configuration present
3. ⚠️ Podfile missing - needs generation
4. ✅ Info.plist configured with permissions
5. ✅ GitHub Actions workflow configured

### Before Pushing to GitHub
1. Run locally: `flutter pub get`
2. Generate code: `flutter packages pub run build_runner build`
3. Test locally: `flutter test`
4. Analyze: `flutter analyze`

## 🚀 Deployment Strategy

### Current Setup
- **CI/CD**: GitHub Actions for automated builds
- **Artifacts**: iOS app bundle uploaded (no code signing)
- **Testing**: Automated unit and widget tests

### Alternative: Codemagic
- **Config File**: `codemagic.yaml` present
- **Features**: TestFlight deployment support
- **Requirements**: API keys and certificates

## 📊 Build Matrix

| Platform | Build Command | Status | Notes |
|----------|--------------|--------|-------|
| iOS | `flutter build ios --release --no-codesign` | ⚠️ | No code signing |
| iOS (IPA) | `flutter build ipa --release` | ❌ | Requires signing |
| Android | `flutter build apk --release` | N/A | Not in iOS workflow |

## 🔍 Debugging Steps

### If Build Fails in GitHub Actions

1. **Check Workflow Logs**:
   - Go to Actions tab in GitHub
   - Click on failed workflow run
   - Review step-by-step logs

2. **Common Fixes**:
   ```bash
   # Clean build
   flutter clean
   flutter pub get
   
   # Reset iOS dependencies
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   
   # Regenerate code
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Flutter Version Issues**:
   - Ensure local Flutter matches CI (3.19.0)
   - Check SDK constraints in pubspec.yaml

4. **Dependency Conflicts**:
   - Review pubspec.lock
   - Update dependencies: `flutter pub upgrade`

## 📝 Next Steps

### Immediate Actions
1. **Generate Podfile**: Run `flutter build ios` locally to generate Podfile
2. **Commit Podfile**: Add to repository for CI/CD
3. **Test Workflow**: Push changes to trigger GitHub Actions

### Future Enhancements
1. **Code Signing**: Configure certificates for distribution
2. **TestFlight**: Set up automatic deployment
3. **Multiple Environments**: Add staging/production workflows
4. **Cache Dependencies**: Speed up builds with caching

## 🔗 Resources

### Documentation
- [Flutter iOS Setup](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)
- [CocoaPods Troubleshooting](https://guides.cocoapods.org/using/troubleshooting.html)

### Project Files
- Workflow: `.github/workflows/ios_build.yml`
- iOS Config: `ios/Runner/Info.plist`
- Flutter Config: `pubspec.yaml`
- Codemagic: `codemagic.yaml`

## 📞 Support Channels

### For Build Issues
1. Check this document first
2. Review GitHub Actions logs
3. Search Flutter/iOS issues on GitHub
4. Post in Flutter Community forums

### For App-Specific Issues
- Backend API: Check `API_DOCUMENTATION.md`
- Deployment: See `DEPLOYMENT_GUIDE.md`
- iOS Setup: Refer to `FLUTTER_IOS_SETUP.md`

---

**Last Updated**: Created for persistent context
**Purpose**: Centralized reference for GitHub Actions iOS build configuration and troubleshooting