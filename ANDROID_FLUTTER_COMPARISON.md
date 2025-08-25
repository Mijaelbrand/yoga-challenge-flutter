# Android vs Flutter App Comparison & Fixes Needed

## ✅ Verified Components (Working Correctly)

### 1. Navigation Flow
Both apps follow the same screen flow:
- Welcome → Phone Entry → Intro Video → Welcome Journey → Day Selection → Dashboard → Challenge Complete
- Screen enum names match (with minor casing differences)

### 2. Data Models
- Both have YogaMessage class with same fields
- PhoneVerificationResult structure matches
- UserSchedule concept is present in both

### 3. State Management
- Android: SharedPreferences + in-memory state
- Flutter: Provider pattern + SharedPreferences
- Both track same data: phone, start date, schedule, frequency, streak, etc.

## ⚠️ Issues Found & Fixes Required

### 1. API Endpoint Version Mismatch
**Issue**: Flutter uses different API endpoint version
- Android: `check-phone.php`
- Flutter: `check-phone-v2.php`

**Fix Required**:
```dart
// In lib/utils/constants.dart, line 89
// Change from:
static const String checkPhoneUrl = "https://akilainstitute.com/api/yoga/check-phone-v2.php";
// To:
static const String checkPhoneUrl = "https://akilainstitute.com/api/yoga/check-phone.php";
```

### 2. Phone Verification Request Method
**Issue**: Different HTTP methods
- Android: GET request with phone as query parameter
- Flutter: POST request with JSON body

**Fix Required**:
```dart
// In lib/providers/auth_provider.dart, modify verifyPhone method
Future<PhoneVerificationResult> verifyPhone(String phone) async {
  setLoading(true);
  setError(null);
  
  try {
    // Change from POST to GET to match Android
    final encodedPhone = Uri.encodeComponent(phone);
    final response = await http.get(
      Uri.parse('${AppConfig.checkPhoneUrl}?phone=$encodedPhone'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    // Rest of the code remains the same
  }
}
```

### 3. Video Token Generation Missing
**Issue**: Android has video token generation for secure video access
- Android: `getVideoToken()` method in ManyChatIntegration
- Flutter: Missing video token implementation

**Fix Required**: Add video token generation to AuthProvider

### 4. Notification Scheduling
**Issue**: Flutter has notification provider but missing actual scheduling logic
- Android: Has NotificationScheduler and MessageScheduler classes
- Flutter: NotificationProvider exists but incomplete

**Fix Required**: Implement proper notification scheduling

### 5. Permission Handling
**Issue**: Android handles notification permissions explicitly
- Android: Requests POST_NOTIFICATIONS permission for Android 13+
- Flutter: permission_handler package included but not used

**Fix Required**: Add permission request flow in Flutter

### 6. ManyChat Registration Link
**Issue**: Different registration flow
- Android: Opens Instagram with specific message
- Flutter: Has the link but might need adjustment

**Verify**: The Instagram link format matches

### 7. Video Player Integration
**Issue**: Different video player implementations
- Android: Custom VideoPlayerActivity with Vimeo integration
- Flutter: Uses video_player and chewie packages

**Verify**: Video URLs and token authentication work correctly

### 8. Access Expiration Calculation
**Issue**: Need to verify date calculation consistency
- Both use 40-day limit
- Date parsing might differ between platforms

**Verify**: Date calculations are consistent

## 📋 Action Items

### High Priority Fixes:

1. **Fix API endpoint** - Change to use check-phone.php instead of check-phone-v2.php
2. **Fix HTTP method** - Change from POST to GET for phone verification
3. **Add video token generation** - Implement secure video access

### Medium Priority:

4. **Complete notification scheduling** - Implement actual scheduling logic
5. **Add permission handling** - Request notification permissions properly
6. **Test video playback** - Ensure Vimeo videos play correctly

### Low Priority:

7. **Verify date calculations** - Ensure 40-day limit works correctly
8. **Test ManyChat registration flow** - Verify Instagram link works
9. **Add missing UI polish** - Match Android app's visual design

## 🔧 Implementation Notes

### For Phone Verification:
The Android app uses a simpler GET request approach which is more reliable. The Flutter app should match this exactly to ensure compatibility with the existing backend.

### For Video Access:
The Android app's token-based video access provides better security. This should be implemented in Flutter to prevent unauthorized video access.

### For Notifications:
The notification scheduling is critical for the yoga challenge experience. The Flutter implementation needs to match the Android scheduling logic exactly.

## 📝 Testing Checklist

After making fixes:
- [ ] Phone verification works with real phone numbers
- [ ] Access expiration is calculated correctly (40 days)
- [ ] Video playback works with proper authentication
- [ ] Notifications are scheduled correctly
- [ ] ManyChat registration link opens Instagram
- [ ] Data persists correctly between app launches
- [ ] Navigation flow matches Android exactly
- [ ] UI/UX is consistent with Android version