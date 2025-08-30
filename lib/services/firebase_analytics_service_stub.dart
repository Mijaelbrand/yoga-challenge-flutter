/**
 * Firebase Analytics Service Stub
 * For simulator builds - prevents compilation errors without Firebase Analytics
 */
class FirebaseAnalyticsService {
  static bool _initialized = false;
  
  /// Initialize Firebase Analytics (stub)
  static Future<void> initialize() async {
    if (_initialized) return;
    print('[FirebaseAnalytics] 🔇 Analytics disabled for simulator build');
    _initialized = true;
  }
  
  /// Log app open event (stub)
  static Future<void> logAppOpen({String source = 'app_launch'}) async {
    // print('[FirebaseAnalytics] 📊 (stub) App open logged');
  }
  
  /// Log screen view (stub)
  static Future<void> logScreenView({
    required String screenName,
    String screenClass = 'Flutter',
  }) async {
    // print('[FirebaseAnalytics] 📱 (stub) Screen view logged: $screenName');
  }
  
  /// Log phone verification attempt (stub)
  static Future<void> logPhoneVerification({
    required bool success,
    String? reason,
    int? daysRemaining,
  }) async {
    // print('[FirebaseAnalytics] 📞 (stub) Phone verification logged: $success');
  }
  
  /// Log FCM notification events (stub)
  static Future<void> logFCMNotification({
    required String action,
    Map<String, Object>? additionalParams,
  }) async {
    // print('[FirebaseAnalytics] 🔔 (stub) FCM notification logged: $action');
  }
  
  /// Set user ID for analytics (stub)
  static Future<void> setUserId(String phoneNumber) async {
    // print('[FirebaseAnalytics] 👤 (stub) User ID set');
  }
  
  /// Log non-fatal error (stub)
  static Future<void> logError(String message, Object error, StackTrace? stackTrace) async {
    print('[FirebaseAnalytics] ⚠️ (stub) Error logged: $message - $error');
  }
  
  /// Log fatal error (stub)
  static Future<void> logFatalError(String message, Object error, StackTrace? stackTrace) async {
    print('[FirebaseAnalytics] 🚨 (stub) Fatal error logged: $message - $error');
  }
  
  /// Set custom user properties (stub)
  static Future<void> setUserProperty(String name, String? value) async {
    // print('[FirebaseAnalytics] 🏷️ (stub) User property set: $name');
  }
}