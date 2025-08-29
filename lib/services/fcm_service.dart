import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/build_info.dart';
import 'firebase_analytics_service.dart';
import 'secure_storage.dart';

/**
 * Firebase Cloud Messaging Service
 * Flutter equivalent of Android's FCM implementation
 * 
 * Handles server-side notifications, token management, and user registration
 * Replaces local notifications with precise server-sent notifications
 */
class FCMService {
  static const String _serverBaseUrl = 'https://southamerica-west1-akila-challenge.cloudfunctions.net/api/';
  static const String _apiKey = 'akila-secure-api-key-2025';
  
  static const String _fcmTokenKey = 'fcm_token';
  static const String _tokenSentKey = 'fcm_token_sent_to_server';
  static const String _lastTokenUpdateKey = 'fcm_last_token_update';
  static const String _notificationsReceivedKey = 'fcm_notifications_received';
  
  static FirebaseMessaging? _messaging;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static bool _initialized = false;
  
  /// Initialize FCM service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('[FCMService] 🔄 Initializing FCM service for BrowserStack testing...');
      print('[FCMService] 🧪 Test Environment: BrowserStack iOS Real Devices');
      
      _messaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      // Request notification permissions
      await _requestNotificationPermissions();
      
      // Initialize local notifications for foreground handling
      await _initializeLocalNotifications();
      
      // Set up message handlers
      _setupMessageHandlers();
      
      // Get and log FCM token for BrowserStack testing
      await _logFCMTokenForTesting();
      
      print('[FCMService] ✅ FCM service initialized successfully for BrowserStack');
      _initialized = true;
    } catch (e) {
      print('[FCMService] ❌ CRITICAL: FCM initialization failed: $e');
      print('[FCMService] Stack trace: ${StackTrace.current}');
      FirebaseAnalyticsService.logError('FCM initialization failed', e, StackTrace.current);
    }
  }
  
  /// Log FCM token for BrowserStack testing verification
  static Future<void> _logFCMTokenForTesting() async {
    try {
      final token = await _messaging?.getToken();
      if (token != null) {
        print('[FCMService] 🧪 BrowserStack FCM Token (first 20 chars): ${token.substring(0, 20)}...');
        print('[FCMService] 🧪 Token length: ${token.length} characters');
        print('[FCMService] 🧪 Server endpoint: $_serverBaseUrl');
        
        // Log to Firebase Analytics for verification
        await FirebaseAnalyticsService.logEvent(
          name: 'fcm_token_generated',
          parameters: {
            'token_length': token.length,
            'test_platform': 'browserstack_ios',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      } else {
        print('[FCMService] ❌ BrowserStack Test: FCM token is null!');
      }
    } catch (e) {
      print('[FCMService] ❌ Error logging FCM token for testing: $e');
    }
  }
  
  /// Request notification permissions
  static Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      print('[FCMService] 🔔 Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('[FCMService] ✅ Notification permissions granted');
        await FirebaseAnalyticsService.logFCMNotification(
          action: 'permission_granted',
        );
      } else {
        print('[FCMService] ⚠️ Notification permissions denied');
        await FirebaseAnalyticsService.logFCMNotification(
          action: 'permission_denied',
        );
      }
    } catch (e) {
      print('[FCMService] ❌ Error requesting notification permissions: $e');
    }
  }
  
  /// Initialize local notifications for foreground handling
  static Future<void> _initializeLocalNotifications() async {
    try {
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );
      
      const initializationSettings = InitializationSettings(
        iOS: initializationSettingsIOS,
      );
      
      await _localNotifications!.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Note: iOS doesn't require notification channels like Android
      
      print('[FCMService] ✅ Local notifications initialized');
    } catch (e) {
      print('[FCMService] ❌ Error initializing local notifications: $e');
    }
  }
  
  /// Set up FCM message handlers
  static void _setupMessageHandlers() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCMService] 📩 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });
    
    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[FCMService] 📱 App opened from background notification');
      _handleNotificationTap(message);
    });
    
    // Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('[FCMService] 🔄 FCM token refreshed');
      _onTokenRefresh(token);
    });
  }
  
  /// Handle messages when app is in foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      // Record statistics
      await _recordNotificationDelivery(message);
      
      // Show local notification
      await _showLocalNotification(message);
      
      // Log analytics
      await FirebaseAnalyticsService.logFCMNotification(
        action: 'received_foreground',
        additionalParams: {
          'notification_type': message.data['type'] ?? 'unknown',
        },
      );
    } catch (e) {
      print('[FCMService] ❌ Error handling foreground message: $e');
    }
  }
  
  /// Handle notification tap
  static Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      print('[FCMService] 👆 Notification tapped: ${message.data}');
      
      // Log analytics
      await FirebaseAnalyticsService.logFCMNotification(
        action: 'opened',
        additionalParams: {
          'notification_type': message.data['type'] ?? 'unknown',
        },
      );
      
      // TODO: Navigate to appropriate screen based on message data
      // This would typically involve using a navigation service or global navigator
    } catch (e) {
      print('[FCMService] ❌ Error handling notification tap: $e');
    }
  }
  
  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('[FCMService] 👆 Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }
  
  /// Show local notification for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final title = message.notification?.title ?? '🌿 Yoga Practice';
      final body = message.notification?.body ?? 'Your yoga moment awaits!';
      
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'yoga_reminder',
          sound: 'default',
          badgeNumber: 1,
        ),
      );
      
      await _localNotifications!.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      
      print('[FCMService] 🔔 Local notification shown: $title');
    } catch (e) {
      print('[FCMService] ❌ Error showing local notification: $e');
    }
  }
  
  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _messaging?.getToken();
      
      if (token != null) {
        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_fcmTokenKey, token);
        await prefs.setInt(_lastTokenUpdateKey, DateTime.now().millisecondsSinceEpoch);
        
        print('[FCMService] ✅ FCM token obtained: ${token.substring(0, 20)}...');
      }
      
      return token;
    } catch (e) {
      print('[FCMService] ❌ Error getting FCM token: $e');
      return null;
    }
  }
  
  /// Register device with server
  static Future<bool> registerWithServer() async {
    try {
      print('[FCMService] 🔄 Registering device with server...');
      
      // Get FCM token
      final token = await getToken();
      if (token == null) {
        print('[FCMService] ❌ Cannot register without FCM token');
        return false;
      }
      
      // Get user data
      final secureStorage = SecureStorage.instance;
      final phoneNumber = await secureStorage.getPhoneNumber();
      if (phoneNumber == null) {
        print('[FCMService] ❌ Cannot register without phone number');
        return false;
      }
      
      // Get schedule data
      final prefs = await SharedPreferences.getInstance();
      final scheduleJson = prefs.getString('selected_days');
      if (scheduleJson == null) {
        print('[FCMService] ❌ Cannot register without schedule');
        return false;
      }
      
      final frequency = prefs.getInt('selected_frequency') ?? 2;
      final startDate = prefs.getInt('challenge_start_date') ?? DateTime.now().millisecondsSinceEpoch;
      
      // Prepare registration data
      final registrationData = {
        'fcmToken': token,
        'phoneNumber': phoneNumber,
        'schedule': scheduleJson,
        'frequency': frequency,
        'startDate': startDate,
        'timezone': DateTime.now().timeZoneName,
        'appVersion': BuildInfo.version,
        'deviceInfo': 'Flutter iOS ${BuildInfo.version}',
      };
      
      print('[FCMService] 📤 Sending registration data...');
      print('[FCMService] Phone: $phoneNumber');
      print('[FCMService] Schedule: $scheduleJson');
      print('[FCMService] Frequency: $frequency');
      
      // Send to server
      final success = await _sendToServer('/register-device', registrationData);
      
      if (success) {
        // Mark as sent
        await prefs.setBool(_tokenSentKey, true);
        await prefs.setInt('token_sent_timestamp', DateTime.now().millisecondsSinceEpoch);
        
        print('[FCMService] ✅ Device registered successfully');
        
        await FirebaseAnalyticsService.logFCMNotification(
          action: 'registered',
          additionalParams: {
            'schedule_days': frequency.toString(),
          },
        );
        
        return true;
      } else {
        print('[FCMService] ❌ Failed to register device');
        return false;
      }
    } catch (e) {
      print('[FCMService] ❌ Error registering with server: $e');
      FirebaseAnalyticsService.logError('FCM registration failed', e, StackTrace.current);
      return false;
    }
  }
  
  /// Send HTTP request to server
  static Future<bool> _sendToServer(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_serverBaseUrl$endpoint');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': _apiKey,
          'User-Agent': 'AkilaYogaFlutter/${BuildInfo.version}',
        },
        body: jsonEncode(data),
      );
      
      print('[FCMService] 📡 Server response: ${response.statusCode}');
      print('[FCMService] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('[FCMService] ✅ Server request successful: ${responseData['message']}');
          return true;
        } else {
          print('[FCMService] ❌ Server request failed: ${responseData['message']}');
          return false;
        }
      } else {
        print('[FCMService] ❌ Server error: ${response.statusCode} - ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      print('[FCMService] ❌ Network error: $e');
      return false;
    }
  }
  
  /// Handle token refresh
  static Future<void> _onTokenRefresh(String newToken) async {
    try {
      print('[FCMService] 🔄 Token refreshed, re-registering with server...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, newToken);
      await prefs.setInt(_lastTokenUpdateKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool(_tokenSentKey, false); // Mark as not sent
      
      // Re-register with new token
      await registerWithServer();
    } catch (e) {
      print('[FCMService] ❌ Error handling token refresh: $e');
    }
  }
  
  /// Record notification delivery statistics
  static Future<void> _recordNotificationDelivery(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Increment counter
      final currentCount = prefs.getInt(_notificationsReceivedKey) ?? 0;
      await prefs.setInt(_notificationsReceivedKey, currentCount + 1);
      await prefs.setInt('last_fcm_notification_time', DateTime.now().millisecondsSinceEpoch);
      await prefs.setString('last_fcm_notification_from', message.from ?? 'unknown');
      
      print('[FCMService] 📊 Statistics updated: ${currentCount + 1} notifications received');
    } catch (e) {
      print('[FCMService] ❌ Error recording notification delivery: $e');
    }
  }
  
  /// Check if token is sent to server
  static Future<bool> isTokenSentToServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sent = prefs.getBool(_tokenSentKey) ?? false;
      final lastUpdate = prefs.getInt(_lastTokenUpdateKey) ?? 0;
      final lastSent = prefs.getInt('token_sent_timestamp') ?? 0;
      
      // Token is current if it was sent after the last update
      return sent && lastSent >= lastUpdate;
    } catch (e) {
      print('[FCMService] ❌ Error checking token status: $e');
      return false;
    }
  }
  
  /// Force sync with server if needed
  static Future<void> forceSyncIfNeeded() async {
    try {
      final isTokenSent = await isTokenSentToServer();
      if (!isTokenSent) {
        print('[FCMService] 🔄 Token not synced, forcing registration...');
        await registerWithServer();
      } else {
        print('[FCMService] ✅ Token already synced with server');
      }
    } catch (e) {
      print('[FCMService] ❌ Error in force sync: $e');
    }
  }
  
  /// Unregister from server (for logout/uninstall)
  static Future<void> unregisterFromServer() async {
    try {
      final secureStorage = SecureStorage.instance;
      final phoneNumber = await secureStorage.getPhoneNumber();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_fcmTokenKey);
      
      if (phoneNumber != null && token != null) {
        final unregisterData = {
          'phoneNumber': phoneNumber,
          'fcmToken': token,
        };
        
        await _sendToServer('/unregister-device', unregisterData);
        print('[FCMService] ✅ Device unregistered from server');
      }
      
      // Clear local data
      await prefs.remove(_fcmTokenKey);
      await prefs.remove(_tokenSentKey);
      await prefs.remove(_lastTokenUpdateKey);
      await prefs.remove('server_user_id');
      await prefs.remove('server_scheduled_count');
    } catch (e) {
      print('[FCMService] ❌ Error unregistering from server: $e');
    }
  }
  
  /// Handle background messages (static method required)
  @pragma('vm:entry-point')
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('[FCMService] 🔄 Background message received: ${message.notification?.title}');
    
    try {
      // Initialize minimal services for background processing
      final prefs = await SharedPreferences.getInstance();
      
      // Record statistics
      final currentCount = prefs.getInt(_notificationsReceivedKey) ?? 0;
      await prefs.setInt(_notificationsReceivedKey, currentCount + 1);
      await prefs.setInt('last_fcm_notification_time', DateTime.now().millisecondsSinceEpoch);
      
      print('[FCMService] 📊 Background notification processed');
    } catch (e) {
      print('[FCMService] ❌ Error processing background message: $e');
    }
  }
}