import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/yoga_message.dart';
import '../utils/constants.dart';

class NotificationProvider extends ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    _initialized = true;
  }
  
  // Schedule notification for a specific yoga message
  Future<void> scheduleYogaNotification(YogaMessage message) async {
    if (!_initialized) await initialize();
    
    final androidDetails = AndroidNotificationDetails(
      'yoga_challenge',
      'Yoga Challenge',
      channelDescription: 'Notificaciones del desafío de yoga',
      importance: Importance.high,
      priority: Priority.high,
      color: AppColors.primary,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.zonedSchedule(
      message.messageNumber,
      message.notificationTitle,
      message.notificationText,
      tz.TZDateTime.from(message.scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  // Schedule multiple notifications for user's schedule
  Future<void> scheduleUserNotifications(List<YogaMessage> messages) async {
    for (final message in messages) {
      await scheduleYogaNotification(message);
    }
  }
  
  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_initialized) await initialize();
    
    const androidDetails = AndroidNotificationDetails(
      'yoga_challenge',
      'Yoga Challenge',
      channelDescription: 'Notificaciones del desafío de yoga',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      0,
      '¡Es hora de tu práctica!',
      'Tu sesión de yoga te está esperando',
      details,
    );
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
  
  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidEnabled = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled();
    return androidEnabled ?? false;
  }
  
  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    return androidGranted ?? false;
  }
}




