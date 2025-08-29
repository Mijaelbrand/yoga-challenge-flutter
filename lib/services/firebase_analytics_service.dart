import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/**
 * Firebase Analytics Service
 * Flutter equivalent of Android's Firebase Analytics integration
 * 
 * Tracks user interactions, screen views, and custom events
 * Provides crash reporting via Firebase Crashlytics
 */
class FirebaseAnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;
  static FirebaseCrashlytics? _crashlytics;
  static bool _initialized = false;
  
  /// Initialize Firebase Analytics
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('[FirebaseAnalytics] 🔄 Initializing Firebase Analytics for BrowserStack testing...');
      
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      _crashlytics = FirebaseCrashlytics.instance;
      
      // Force enable analytics collection (overrides GoogleService-Info.plist setting)
      await _analytics!.setAnalyticsCollectionEnabled(true);
      print('[FirebaseAnalytics] 📊 Analytics collection enabled: true');
      
      // Set user properties with debugging info
      await _analytics!.setUserProperty(
        name: 'app_version',
        value: '1.1.43_firebase_deploy_fix',
      );
      
      await _analytics!.setUserProperty(
        name: 'platform',
        value: 'flutter_ios_browserstack',
      );
      
      await _analytics!.setUserProperty(
        name: 'test_environment',
        value: 'browserstack_firebase',
      );
      
      // Test analytics with initialization event
      await logFirebaseInitialization();
      
      print('[FirebaseAnalytics] ✅ Firebase Analytics initialized successfully for BrowserStack');
      _initialized = true;
    } catch (e) {
      print('[FirebaseAnalytics] ❌ CRITICAL: Firebase Analytics initialization failed: $e');
      print('[FirebaseAnalytics] Stack trace: ${StackTrace.current}');
    }
  }
  
  /// Log Firebase initialization for BrowserStack testing
  static Future<void> logFirebaseInitialization() async {
    try {
      await _analytics?.logEvent(
        name: 'firebase_initialized',
        parameters: {
          'initialization_time': DateTime.now().millisecondsSinceEpoch,
          'flutter_version': '3.35.1',
          'firebase_core_version': '2.32.0',
          'test_platform': 'browserstack_ios',
        },
      );
      print('[FirebaseAnalytics] 🧪 Firebase initialization event logged for BrowserStack');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Failed to log initialization event: $e');
    }
  }
  
  /// Get the analytics observer for navigation tracking
  static FirebaseAnalyticsObserver? get observer => _observer;
  
  /// Log app open event (equivalent to Android's APP_OPEN)
  static Future<void> logAppOpen({String source = 'app_launch'}) async {
    try {
      await _analytics?.logAppOpen(parameters: {
        'source': source,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      print('[FirebaseAnalytics] 📊 App open logged');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging app open: $e');
    }
  }
  
  /// Log screen view (equivalent to Android's SCREEN_VIEW)
  static Future<void> logScreenView({
    required String screenName,
    String screenClass = 'Flutter',
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      print('[FirebaseAnalytics] 📱 Screen view logged: $screenName');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging screen view: $e');
    }
  }
  
  /// Log phone verification attempt
  static Future<void> logPhoneVerification({
    required bool success,
    String? reason,
    int? daysRemaining,
  }) async {
    try {
      final parameters = <String, Object>{
        'success': success.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (reason != null) {
        parameters['reason'] = reason;
      }
      
      if (daysRemaining != null) {
        parameters['days_remaining'] = daysRemaining;
      }
      
      await _analytics?.logEvent(
        name: 'phone_verification',
        parameters: parameters,
      );
      
      print('[FirebaseAnalytics] 📞 Phone verification logged: $success');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging phone verification: $e');
    }
  }
  
  /// Log registration attempt
  static Future<void> logRegistrationAttempt({
    required String method,
    required String source,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'registration_attempt',
        parameters: {
          'method': method,
          'source': source,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      print('[FirebaseAnalytics] 📝 Registration attempt logged: $method');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging registration attempt: $e');
    }
  }
  
  /// Log link click (key metric requested)
  static Future<void> logLinkClick({
    required String linkType,
    required String destination,
    required String sourceScreen,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'link_click',
        parameters: {
          'link_type': linkType,
          'destination': destination,
          'source_screen': sourceScreen,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      print('[FirebaseAnalytics] 🔗 Link click logged: $linkType');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging link click: $e');
    }
  }
  
  /// Log schedule selection (key metric requested)
  static Future<void> logScheduleSelection({
    required int daysCount,
    required List<String> timesSelected,
    required List<String> selectedDays,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'schedule_selection',
        parameters: {
          'days_count': daysCount,
          'times_selected': timesSelected.join(','),
          'selected_days': selectedDays.join(','),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      print('[FirebaseAnalytics] 📅 Schedule selection logged: $daysCount days');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging schedule selection: $e');
    }
  }
  
  /// Log FCM notification events
  static Future<void> logFCMNotification({
    required String action, // 'registered', 'received', 'opened'
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (additionalParams != null) {
        parameters.addAll(additionalParams);
      }
      
      await _analytics?.logEvent(
        name: 'fcm_notification',
        parameters: parameters,
      );
      
      print('[FirebaseAnalytics] 🔔 FCM notification logged: $action');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging FCM notification: $e');
    }
  }
  
  /// Log video access event
  static Future<void> logVideoAccess({
    required String videoId,
    required String accessMethod, // 'token', 'direct', 'fallback'
    int? practiceDay,
  }) async {
    try {
      final parameters = <String, Object>{
        'video_id': videoId,
        'access_method': accessMethod,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (practiceDay != null) {
        parameters['practice_day'] = practiceDay;
      }
      
      await _analytics?.logEvent(
        name: 'video_access',
        parameters: parameters,
      );
      
      print('[FirebaseAnalytics] 🎥 Video access logged: $videoId');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging video access: $e');
    }
  }
  
  /// Log user engagement events
  static Future<void> logUserEngagement({
    required String action, // 'practice_completed', 'streak_updated', etc.
    Map<String, Object>? additionalParams,
  }) async {
    try {
      final parameters = <String, Object>{
        'action': action,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (additionalParams != null) {
        parameters.addAll(additionalParams);
      }
      
      await _analytics?.logEvent(
        name: 'user_engagement',
        parameters: parameters,
      );
      
      print('[FirebaseAnalytics] 👤 User engagement logged: $action');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging user engagement: $e');
    }
  }
  
  /// Set user ID for analytics (hashed phone number)
  static Future<void> setUserId(String phoneNumber) async {
    try {
      // Create a hashed version of phone number for privacy
      final hashedId = phoneNumber.hashCode.toString();
      await _analytics?.setUserId(id: hashedId);
      print('[FirebaseAnalytics] 👤 User ID set');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error setting user ID: $e');
    }
  }
  
  /// Log non-fatal error to Crashlytics
  static Future<void> logError(String message, Object error, StackTrace? stackTrace) async {
    try {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: false,
      );
      print('[FirebaseAnalytics] ⚠️ Error logged to Crashlytics: $message');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging to Crashlytics: $e');
    }
  }
  
  /// Log fatal error to Crashlytics
  static Future<void> logFatalError(String message, Object error, StackTrace? stackTrace) async {
    try {
      await _crashlytics?.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: true,
      );
      print('[FirebaseAnalytics] 🚨 Fatal error logged to Crashlytics: $message');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error logging fatal error to Crashlytics: $e');
    }
  }
  
  /// Set custom user properties
  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
      print('[FirebaseAnalytics] 🏷️ User property set: $name');
    } catch (e) {
      print('[FirebaseAnalytics] ❌ Error setting user property: $e');
    }
  }
}