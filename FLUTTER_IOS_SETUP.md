# Flutter iOS Development Setup Guide

## Prerequisites for iOS Development

### 1. Install Flutter SDK

1. **Download Flutter SDK**:
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the latest Flutter SDK for Windows
   - Extract to `C:\flutter` (or your preferred location)

2. **Add Flutter to PATH**:
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\flutter\bin` to your PATH variable
   - Restart your terminal/PowerShell

3. **Verify Installation**:
   ```bash
   flutter doctor
   ```

### 2. Install Xcode (for iOS development)

**Note**: Xcode is only available on macOS. For iOS development, you'll need:
- A Mac computer, OR
- A cloud-based Mac service (like MacStadium, Codemagic, or GitHub Actions)

#### Option A: Local Mac Development
1. **Install Xcode** from the Mac App Store
2. **Install Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```
3. **Accept Xcode license**:
   ```bash
   sudo xcodebuild -license accept
   ```

#### Option B: Cloud-based iOS Building
- **Codemagic**: https://codemagic.io/
- **GitHub Actions**: Use macOS runners
- **MacStadium**: https://www.macstadium.com/

### 3. Install CocoaPods (iOS dependency manager)

On macOS:
```bash
sudo gem install cocoapods
```

### 4. Configure iOS Development

1. **Open iOS Simulator** (on Mac):
   ```bash
   open -a Simulator
   ```

2. **Check iOS setup**:
   ```bash
   flutter doctor
   ```

## Building for iOS

### 1. Run on iOS Simulator
```bash
flutter run -d ios
```

### 2. Build iOS App Bundle
```bash
flutter build ios
```

### 3. Build iOS App Store Package
```bash
flutter build ipa
```

## iOS-Specific Configuration

### 1. iOS App Icon
- Place your app icon in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Use the `flutter_launcher_icons` package to generate all sizes

### 2. iOS Permissions
Add required permissions to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video features</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for video features</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access for saving content</string>
```

### 3. iOS Bundle Identifier
Update in `ios/Runner.xcodeproj/project.pbxproj`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.akila.yogachallenge;
```

## Troubleshooting

### Common Issues:

1. **Flutter not found**:
   - Ensure Flutter is in your PATH
   - Restart terminal after adding to PATH

2. **iOS Simulator not found**:
   - Install Xcode and iOS Simulator
   - Run `flutter doctor` to verify setup

3. **CocoaPods issues**:
   ```bash
   cd ios
   pod install
   ```

4. **Build errors**:
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

## Next Steps

1. Install Flutter SDK
2. Set up a Mac environment (local or cloud)
3. Install Xcode and CocoaPods
4. Run `flutter doctor` to verify setup
5. Test with `flutter run -d ios`

## Alternative: Cross-Platform Testing

If you don't have access to a Mac, you can:
1. Test the app on Android first
2. Use cloud-based iOS building services
3. Use Flutter Web for testing UI components

## Cloud iOS Building Services

### Codemagic
- Free tier available
- Automatic iOS builds
- Easy integration with GitHub

### GitHub Actions
- Free for public repositories
- Use macOS runners
- Automated builds and testing

### MacStadium
- Paid service
- Dedicated Mac infrastructure
- Professional support

