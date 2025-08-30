# Simulator Build Branch Documentation
**Branch: `simulator-build`**  
**Created: August 30, 2025**  
**Purpose: iOS Simulator build for Appetize.io testing while waiting for Apple Developer license**

## 🎯 Overview

This branch creates a working iOS simulator build that can be uploaded to Appetize.io for testing. The main branch requires Apple Developer code signing for device builds, but this branch builds for iOS Simulator which doesn't require code signing.

## 🔄 Android to iOS Flutter Migration Summary

### Original State (Prior Work)
The Flutter iOS app was already functional with these completed upgrades from Android:

#### ✅ **Security Upgrade (v1.1.42-v1.1.46)**
- **Phone Number Encryption**: Ported from Android's `SecurePreferences.kt` 
- **Device-Specific Keys**: Uses device ID + salt for encryption keys
- **XOR Encryption**: Replaced AES/GCM with simpler XOR encryption for Flutter compatibility
- **File**: `lib/services/secure_storage.dart`

#### ✅ **Core App Functionality (v1.1.21-v1.1.41)**
- **Navigation**: Fixed grey screen issues and setState timing problems
- **Spanish Localization**: Fixed LocaleDataException crashes
- **iOS-Specific Endpoints**: Separate API endpoints for iOS (`ios-check-phone.php`, `ios-get-video-token.php`)
- **Video Access**: Working token generation and video streaming
- **UI/UX**: Optimized for iPhone SE and various iOS devices

#### ✅ **Date/Time Handling Fixes**
- **Timezone Support**: Fixed Spanish locale date formatting crashes
- **Practice Scheduling**: Time-based progression vs completion-based
- **Day Calculation**: Proper calendar day advancement logic

## 🔥 Firebase Integration (This Branch's Work)

### **Phase 1: Full Firebase Integration (Attempted)**
Added comprehensive Firebase services to match Android app:

#### **Firebase Analytics Service** (`lib/services/firebase_analytics_service.dart`)
- **User Tracking**: Phone verification, registration attempts, screen views
- **Link Click Analytics**: Track "Watch Today's Video" button usage
- **Schedule Analytics**: Track user practice scheduling selections  
- **Video Access Analytics**: Token generation, access methods, practice day tracking
- **User Engagement**: Practice completion, streak tracking
- **BrowserStack Optimization**: Events specifically for testing environment

#### **Firebase FCM Service** (`lib/services/fcm_service.dart`)
- **Server-Side Notifications**: Replaced local notifications with Firebase FCM
- **Cloud Functions Backend**: `https://southamerica-west1-akila-challenge.cloudfunctions.net/api/`
- **Device Registration**: Automatic FCM token registration with server
- **Notification Scheduling**: Server handles sending practice reminders
- **Background Message Handling**: Proper iOS background notification processing

#### **Firebase Configuration**
- **iOS Setup**: `ios/Runner/GoogleService-Info.plist` (Project ID: `akila-challenge`)
- **Bundle ID**: `com.akila.yogachallenge`
- **Swift Integration**: `ios/Runner/AppDelegate.swift` Firebase initialization
- **Background Notifications**: iOS notification permissions and remote notification registration

### **Phase 2: Compilation Issues (29,000+ Line Errors)**
Firebase integration caused massive compilation errors in GitHub Actions:

#### **Root Causes Identified**
1. **iOS 18.0 SDK Conflicts**: GitHub Actions runners had iOS 18.x but app targeted iOS 13.0
2. **Simulator vs Device Builds**: Release builds don't work with simulators
3. **Firebase Messaging Complexity**: Firebase Messaging has extensive native dependencies
4. **Destination Specifier Issues**: `simctl list` devices ≠ `xcodebuild` destinations

#### **Build Attempts & Solutions Tried**
- **SDK Version Fixes**: Explicit iOS 13.0 deployment targets
- **Generic Simulator Destination**: `generic/platform=iOS Simulator`
- **Direct xcodebuild Commands**: Bypassing Flutter build system
- **Code Signing Disablement**: Various approaches for unsigned builds

### **Phase 3: Surgical Fix (Current Solution)**
Implemented surgical approach to maintain core functionality while enabling builds:

#### **Firebase FCM: ENABLED** 
- **Why**: Core app functionality - tells users when yoga practices are ready
- **Server Integration**: Device registration with Firebase Cloud Functions
- **Notification Flow**: Server → FCM → iOS app → User notification
- **Dependencies**: `firebase_core: ^2.24.2`, `firebase_messaging: ^14.7.10`

#### **Firebase Analytics: STUBBED**
- **Why**: Not core functionality, was causing compilation issues
- **Solution**: `firebase_analytics_service_stub.dart` - provides same API, no actual analytics
- **Result**: Prevents compilation errors, maintains code compatibility
- **Dependencies**: `firebase_analytics` and `firebase_crashlytics` commented out

#### **Build Configuration**
```yaml
# pubspec.yaml
firebase_core: ^2.24.2                  # Required for FCM
# firebase_analytics: ^10.7.4           # Analytics disabled for simulator  
# firebase_crashlytics: ^3.4.8          # Crashlytics disabled for simulator
firebase_messaging: ^14.7.10            # Keep FCM for notifications
```

## 🏗️ Build Process Fixes

### **GitHub Actions Workflow** (`.github/workflows/ios_build.yml`)
- **Simulator Target**: `flutter build ios --simulator --debug` (not release)
- **Generic Destination**: `generic/platform=iOS Simulator` for automatic device selection
- **SDK Debugging**: Lists available iOS simulators and SDKs
- **Clean Builds**: Aggressive cache clearing to prevent stale builds

### **iOS Project Configuration**
- **Deployment Target**: iOS 13.0 (compatible with GitHub Actions runners)
- **Code Signing**: Disabled for simulator builds (no Apple Developer account needed)
- **Firebase Integration**: Maintains FCM while removing analytics dependencies

## 📱 Current Functionality

### **✅ Working Features (Simulator Build)**
- **Phone Verification**: Encrypted phone number storage with device-specific keys
- **Navigation Flow**: Welcome → Phone Entry → Dashboard → Video Access
- **Video Token Generation**: iOS-specific API endpoints working
- **Practice Scheduling**: Time-based progression with Spanish date support
- **Firebase FCM**: Server-side notification registration (tokens generated)
- **UI/UX**: All screens render properly in iOS Simulator

### **🔇 Disabled Features (Simulator Only)**
- **Firebase Analytics**: Event tracking stubbed out (prevents compilation issues)
- **Firebase Crashlytics**: Error reporting disabled
- **Actual Notifications**: FCM tokens generated but notifications won't show in simulator

### **📦 Build Output**
- **Artifact**: `ios-simulator-build` → `Runner.app`
- **Compatible With**: Appetize.io, iOS Simulator testing platforms
- **Size**: ~7-10MB (estimated, without analytics dependencies)

## 🔄 Branch Strategy

### **Main Branch: Device Builds** 
- Full Firebase integration (analytics + FCM)
- Requires Apple Developer code signing
- For App Store deployment

### **Simulator-Build Branch: Testing**
- FCM enabled, analytics stubbed
- No code signing required  
- For Appetize.io testing

## 🚀 Usage Instructions

### **For Appetize.io Upload**
1. Wait for GitHub Actions build completion
2. Download `ios-simulator-build` artifact 
3. Extract `Runner.app`
4. Upload to Appetize.io as iOS Simulator app

### **For Local Testing**
```bash
# Switch to simulator branch
git checkout simulator-build

# Build locally (requires macOS + Xcode)
flutter build ios --simulator --debug
```

### **Future: Re-enable Full Firebase**
When Apple Developer license is approved:
1. Merge simulator-build improvements to main
2. Replace `firebase_analytics_service_stub.dart` with `firebase_analytics_service.dart`
3. Uncomment analytics dependencies in `pubspec.yaml`
4. Build for device with code signing

## 📊 Technical Decisions

### **Why Keep FCM for Simulator?**
- **Core Business Logic**: Notifications are how users know when to do yoga
- **Server Integration**: App registers with Firebase Cloud Functions backend
- **Testing Value**: Can verify token generation and server registration in simulator
- **Real Functionality**: Even without actual notification display, the registration flow works

### **Why Stub Analytics?**
- **Non-Critical**: Analytics don't affect core app functionality
- **Compilation Blocker**: Firebase Analytics was causing 29,000+ line build errors
- **Easy Restore**: Can re-enable analytics for device builds without code changes
- **Testing Focus**: Simulator testing focuses on UX flow, not analytics data

### **Why Simulator vs Device Build?**
- **No Code Signing**: Simulators don't require Apple Developer account
- **Faster Testing**: Upload to Appetize.io for immediate testing
- **Same UX**: Core user experience identical to device builds
- **Parallel Development**: Can test while waiting for Apple Developer license

## 🎉 Success Metrics

### **Build Performance**
- **Before**: 27,000-29,000 line build logs, exit code 65 failures
- **After**: ~300-500 line build logs, successful Runner.app generation
- **Time**: ~3-5 minutes vs previous timeouts/failures

### **Functionality Preserved**
- **✅ Core App Flow**: Phone verification → Dashboard → Video access
- **✅ Security Features**: Phone encryption with device keys  
- **✅ Firebase Notifications**: FCM token generation and server registration
- **✅ iOS Optimizations**: Proper date handling, UI layout, navigation timing

### **Testing Enablement**
- **Ready for Appetize.io**: Uploadable Runner.app artifact
- **BrowserStack Alternative**: Can test on iOS simulators via web
- **Parallel Development**: Test UX while Apple Developer license processes

---

## 📝 Summary

This simulator-build branch successfully balances functionality and buildability. It maintains all core app features (phone verification, video access, notifications) while removing compilation blockers (Firebase Analytics). The result is a testable iOS simulator build that preserves the user experience and business logic while enabling immediate testing via Appetize.io.

The surgical approach of keeping Firebase FCM (core functionality) while stubbing Firebase Analytics (nice-to-have) allows continued development and testing without waiting for Apple Developer license approval.