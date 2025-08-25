# Yoga Challenge Flutter App

**Version: 1.1.5** - *Complete iOS Implementation*

A Flutter version of the Yoga Challenge app with ManyChat integration and video streaming capabilities.

## 🎉 Version 1.1.5 - All Core Features Complete

### ✅ Fully Implemented Features:
- **Phone Verification**: Complete ManyChat/API integration with proper JSON parsing
- **Intro Video**: Vimeo integration with optimized UI (button moved to top for better UX)
- **User Onboarding**: Seamless welcome journey flow (celebration icon removed, no scrolling needed)
- **Schedule Selection**: Day/time picker with proper validation and error handling
- **Message Generation**: Automatic creation of personalized 31-day yoga schedule
- **Dashboard**: Clean Android-matching design (no header bar, proper content layout)
- **Video Integration**: External browser launch for daily videos (matches Android exactly)
- **Error Handling**: Comprehensive network debugging and graceful failure handling
- **iOS Compatibility**: All network issues resolved with Dio HTTP client

### 🔧 Technical Achievements:
- **BrowserStack Compatible**: Full cloud testing capability on real iOS devices
- **Android Parity**: UI/UX matches Android app exactly per requirements
- **Network Stability**: Resolved all iOS-specific connection issues
- **Clean Architecture**: Proper state management and error handling throughout
- **Build Pipeline**: Automated GitHub Actions iOS builds working perfectly

## 📋 Development Progress History

### Version 1.1.5 (August 25, 2025) - Complete Implementation
- ✅ Fixed blank screen after schedule confirmation  
- ✅ Enhanced intro video screen with top-positioned continue button
- ✅ Removed unnecessary celebration icon from welcome journey
- ✅ Updated dashboard to match Android design (removed header bar)
- ✅ Added proper user message generation system
- ✅ Improved error handling throughout the app

### Version 1.1.4 (August 25, 2025) - JSON & Network Fixes
- ✅ Fixed JSON parsing to match server response format
- ✅ Resolved type casting errors in phone verification
- ✅ Updated field names (registered, daysRemaining, etc.)
- ✅ Fixed compilation errors and updated version references

### Version 1.1.3 (August 25, 2025) - Network & Debugging
- ✅ Implemented Dio HTTP client for iOS network compatibility
- ✅ Added comprehensive network debugging and connectivity tests
- ✅ Fixed Info.plist network security configuration
- ✅ Enhanced error messages with detailed debugging information
- ✅ Resolved BrowserStack upload and installation issues

### Earlier Versions (v1.0.x - v1.1.2)
- ✅ Established core Flutter architecture and state management
- ✅ Implemented all UI screens matching Android layouts exactly
- ✅ Set up GitHub Actions automated iOS builds
- ✅ Synchronized text content with Android JSON files
- ✅ Fixed video implementation to use external browser like Android
- ✅ Resolved various build and lint issues

## 🚨 CRITICAL: Android Parity Requirement 🚨

**THIS FLUTTER APP MUST BE AN EXACT REPLICA OF THE ANDROID APP**

### Mandatory Parity Rules:

1. **ALL TEXT MUST MATCH ANDROID EXACTLY**
   - Use the Android JSON files as the ONLY source of truth: `E:\Akila Challenge APP\app\src\main\res\raw\yoga_messages_with_notifications.json`
   - All UI strings must match: `E:\Akila Challenge APP\app\src\main\res\values\strings.xml`
   - Button texts, labels, messages, titles - EVERYTHING must be identical

2. **UI/UX MUST BE IDENTICAL**
   - Same screens in the same order
   - Same navigation flow
   - Same visual elements and layouts
   - Same colors (already defined in AppColors to match Android)
   - Same functionality and behavior

3. **BEFORE MAKING ANY CHANGES**
   - ✅ Check the Android version FIRST
   - ✅ Compare with Android implementation
   - ✅ Use Android files as reference:
     - Java/Kotlin files: `E:\Akila Challenge APP\app\src\main\java\com\akila\yogachallenge\`
     - Layouts: `E:\Akila Challenge APP\app\src\main\res\layout\`
     - Resources: `E:\Akila Challenge APP\app\src\main\res\`
   - ❌ DO NOT make decisions to change anything without checking Android first
   - ❌ DO NOT add new features or text that don't exist in Android

4. **iOS PLATFORM CONFLICTS**
   - If something conflicts with iOS development requirements, DO NOT change it
   - Instead, ASK THE USER for guidance on how to proceed
   - Document the conflict and proposed solutions

5. **TESTING CHECKLIST**
   - [ ] Text matches Android exactly (all 31 messages, all UI strings)
   - [ ] Button labels match Android
   - [ ] Screen titles match Android  
   - [ ] Navigation flow matches Android
   - [ ] Error messages match Android
   - [ ] Dialog texts match Android
   - [ ] Challenge is 31 days (not 30)
   - [ ] All features present in Android exist in Flutter

### Development Workflow:

```
1. Need to add/change something?
   ↓
2. Check Android version first
   ↓
3. Is it exactly the same in Android?
   → YES: Implement exactly as in Android
   → NO: STOP and ask user for guidance
   ↓
4. Test that it matches Android
   ↓
5. Document any platform-specific adjustments needed
```

### Key Android Source Files for Reference:

- **Messages & Content**: `/app/src/main/res/raw/yoga_messages_with_notifications.json`
- **UI Strings**: `/app/src/main/res/values/strings.xml`
- **Main Logic**: `/app/src/main/java/com/akila/yogachallenge/MainActivity.kt`
- **Layouts**: `/app/src/main/res/layout/screen_*.xml`

### Current Parity Status (Last Updated: August 25, 2025):

✅ **SYNCHRONIZED:**
- All 31 yoga messages and button texts from Android JSON
- All UI strings from strings.xml
- Welcome journey full message with benefits list
- Day selection subtitle with expiration notice
- All dialog texts (Verificación, Registro Requerido, etc.)
- Challenge duration: 31 days
- Error messages match exactly
- Removed Flutter-only UI elements (journey steps, quotes)
- **Video system matches Android exactly:**
  - Intro video: WebView in-app (Vimeo embed)
  - Daily videos: External browser launch (tokenized URLs)

⚠️ **REQUIRES VERIFICATION:**
- Screen layouts visual matching
- Navigation flow exact matching
- Animation and transition matching
- Loading states and progress indicators

❌ **KNOWN DIFFERENCES (Platform-Specific):**
- iOS requires different permission handling for notifications

## 🎥 Video Implementation Details

**CRITICAL: Video behavior must match Android exactly:**

### Intro Video (One-time only):
- **Location**: Shown once in app after phone verification
- **Implementation**: WebView inside the app showing Vimeo embed
- **Video ID**: `1112594299`
- **User Experience**: Plays directly in the app

### Daily Practice Videos:
- **Location**: Accessed from dashboard "video button" 
- **Implementation**: Opens tokenized URLs in **EXTERNAL BROWSER**
- **Flow**: App → Get token → Build URL → Launch default browser
- **User Experience**: Leaves app, opens Chrome/Safari with your Divi pages
- **URLs**: `https://akilainstitute.com/watch/video.php?video=day1&token=ABC&phone=123`
- **Validation**: Token validates → redirects to Divi pages with actual video

**NEVER open daily videos inside the app - they must open in external browser like Android**

---

## Features

- **User Authentication**: Phone number verification with ManyChat integration
- **Personalized Schedule**: Users can select practice days and times
- **Daily Yoga Content**: 31 days of curated yoga videos and messages
- **Progress Tracking**: Streak counting and practice completion tracking
- **Local Notifications**: Scheduled reminders for practice sessions
- **Video Player**: Integrated video streaming with Vimeo support
- **Modern UI**: Beautiful, responsive design with Material Design 3
- **Cross-platform**: Works on both Android and iOS

## Screens

1. **Splash Screen**: App initialization and loading
2. **Welcome Screen**: Introduction to the yoga challenge
3. **Phone Entry Screen**: User authentication and verification
4. **Intro Video Screen**: Introduction video with Vimeo integration
5. **Welcome Journey Screen**: Onboarding flow continuation
6. **Day Selection Screen**: Schedule customization
7. **Dashboard Screen**: Main app interface with progress tracking
8. **Challenge Complete Screen**: End-of-challenge celebration

## Architecture

The app follows a clean architecture pattern with:

- **Providers**: State management using Provider pattern
- **Models**: Data models with JSON serialization
- **Services**: API integration and local storage
- **Widgets**: Reusable UI components
- **Utils**: Constants and helper functions

## Dependencies

### Core Dependencies
- `flutter`: SDK
- `provider`: State management
- `http` & `dio`: HTTP requests
- `shared_preferences`: Local storage
- `sqflite`: Database operations

### UI Dependencies
- `google_fonts`: Typography
- `flutter_svg`: SVG support
- `cached_network_image`: Image caching

### Video & Media
- `video_player`: Video playback
- `chewie`: Video player UI
- `webview_flutter`: Web content display

### Notifications & Permissions
- `flutter_local_notifications`: Local notifications
- `permission_handler`: Permission management
- `timezone`: Timezone handling

### Utilities
- `url_launcher`: External link handling
- `intl`: Internationalization
- `json_annotation`: JSON serialization
- `workmanager`: Background tasks
- `connectivity_plus`: Network connectivity
- `flutter_spinkit`: Loading animations

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd yoga_challenge_flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate JSON models**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

1. **Update API endpoints** in `lib/utils/constants.dart`:
   ```dart
   static const String apiBaseUrl = "https://your-api-domain.com/api/yoga";
   static const String manyChatWebhookUrl = "https://your-api-domain.com/api/yoga/manychat-webhook.php";
   ```

2. **Configure ManyChat integration** in `lib/providers/auth_provider.dart`

3. **Update video IDs** in `lib/utils/constants.dart`:
   ```dart
   static const String introVideoId = "your-vimeo-video-id";
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── yoga_message.dart     # Yoga message model
├── providers/                # State management
│   ├── app_state.dart        # Main app state
│   ├── auth_provider.dart    # Authentication
│   └── notification_provider.dart # Notifications
├── screens/                  # App screens
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── phone_entry_screen.dart
│   ├── intro_video_screen.dart
│   ├── welcome_journey_screen.dart
│   ├── day_selection_screen.dart
│   ├── dashboard_screen.dart
│   └── challenge_complete_screen.dart
├── widgets/                  # Reusable widgets
│   └── video_player_widget.dart
├── utils/                    # Utilities
│   └── constants.dart        # App constants
└── assets/                   # Assets
    ├── data/
    │   └── yoga_messages.json
    ├── images/
    └── icons/
```

## Key Features Implementation

### Phone Verification
- Integrates with ManyChat API for user verification
- Handles registration flow for new users
- Manages 40-day access period

### Schedule Management
- Users select practice days (2-7 days per week)
- Time picker for each selected day
- Local storage of user preferences

### Video Integration
- Vimeo video player integration
- Hybrid video system for secure content delivery
- WebView-based video playback

### Notifications
- Local notification scheduling
- Permission handling for Android 13+
- Daily practice reminders

### Progress Tracking
- Streak counting system
- Practice completion tracking
- Progress percentage calculation

## Backend Integration

The app integrates with the existing PHP backend:

- **Phone Verification**: `check-phone-v2.php`
- **ManyChat Webhooks**: `manychat-webhook.php`
- **Video System**: `video.php` and related endpoints

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is proprietary software. All rights reserved.

## Support

For support and questions, contact the development team or refer to the original Android app documentation.


