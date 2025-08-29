// Build Information File
// This file helps track which version is actually compiled into the app

class BuildInfo {
  static const String version = 'v1.1.42';
  static const String buildDate = '2025-08-29';
  static const String tokenEndpoint = 'ios-get-video-token.php';
  
  // Diagnostic method to generate unique build identifier
  static String getBuildIdentifier() {
    return 'BUILD_1_1_42_FIREBASE_BROWSERSTACK_TEST';
  }
  
  // Method to generate token with correct format
  static String generateTokenPrefix() {
    // CRITICAL: Should return 'token_' NOT 'ios_token_'
    return 'token_';
  }
  
  // Method to verify endpoints
  static Map<String, String> getEndpoints() {
    return {
      'checkPhone': 'https://akilainstitute.com/api/yoga/ios-check-phone.php',
      'getVideoToken': 'https://akilainstitute.com/api/yoga/ios-get-video-token.php',
    };
  }
}