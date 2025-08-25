import 'package:json_annotation/json_annotation.dart';

part 'yoga_message.g.dart';

@JsonSerializable()
class YogaMessage {
  final int messageNumber;
  final String notificationTitle;
  final String notificationText;
  final String fullMessage;
  final String videoUrl;
  final String videoButtonText;
  final DateTime scheduledDate;
  final String? hybridToken;

  YogaMessage({
    required this.messageNumber,
    required this.notificationTitle,
    required this.notificationText,
    required this.fullMessage,
    required this.videoUrl,
    required this.videoButtonText,
    required this.scheduledDate,
    this.hybridToken,
  });

  factory YogaMessage.fromJson(Map<String, dynamic> json) => _$YogaMessageFromJson(json);
  Map<String, dynamic> toJson() => _$YogaMessageToJson(this);

  YogaMessage copyWith({
    int? messageNumber,
    String? notificationTitle,
    String? notificationText,
    String? fullMessage,
    String? videoUrl,
    String? videoButtonText,
    DateTime? scheduledDate,
    String? hybridToken,
  }) {
    return YogaMessage(
      messageNumber: messageNumber ?? this.messageNumber,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationText: notificationText ?? this.notificationText,
      fullMessage: fullMessage ?? this.fullMessage,
      videoUrl: videoUrl ?? this.videoUrl,
      videoButtonText: videoButtonText ?? this.videoButtonText,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      hybridToken: hybridToken ?? this.hybridToken,
    );
  }

  @override
  String toString() {
    return 'YogaMessage(messageNumber: $messageNumber, title: $notificationTitle, scheduledDate: $scheduledDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is YogaMessage && other.messageNumber == messageNumber;
  }

  @override
  int get hashCode => messageNumber.hashCode;
}

@JsonSerializable()
class PhoneVerificationResult {
  final bool registered;
  final bool? isAccessExpired;  // Make optional since server doesn't always provide
  final String? registrationDate;  // Server sends as string
  final int? daysSinceRegistration;  // Make optional
  final int daysRemaining;  // Match server field name
  final String? phone;
  final String? name;
  final String? email;
  final String? source;
  final String? language;
  final String? error;

  PhoneVerificationResult({
    required this.registered,
    this.isAccessExpired,
    this.registrationDate,
    this.daysSinceRegistration,
    required this.daysRemaining,
    this.phone,
    this.name,
    this.email,
    this.source,
    this.language,
    this.error,
  });

  // Custom fromJson to handle server response format
  factory PhoneVerificationResult.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationResult(
      registered: json['registered'] ?? false,
      isAccessExpired: json['access_expires'] != null ? _isAccessExpired(json['access_expires']) : null,
      registrationDate: json['registration_date'],
      daysSinceRegistration: json['days_since_registration'],
      daysRemaining: json['days_remaining'] ?? 0,
      phone: json['phone']?.toString(),
      name: json['name'],
      email: json['email'],
      source: json['source'],
      language: json['language'],
      error: json['error'],
    );
  }

  // Helper to determine if access is expired
  static bool _isAccessExpired(String? accessExpires) {
    if (accessExpires == null) return true;
    try {
      // Parse date and check if it's in the past
      // Server format appears to be MM/dd/yyyy
      final parts = accessExpires.split('/');
      if (parts.length == 3) {
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final expireDate = DateTime(year, month, day);
        return DateTime.now().isAfter(expireDate);
      }
    } catch (e) {
      // If parsing fails, assume expired
      return true;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'registered': registered,
      'is_access_expired': isAccessExpired,
      'registration_date': registrationDate,
      'days_since_registration': daysSinceRegistration,
      'days_remaining': daysRemaining,
      'phone': phone,
      'name': name,
      'email': email,
      'source': source,
      'language': language,
      'error': error,
    };
  }

  // Convenience getters for backward compatibility
  bool get isRegistered => registered;
  int get remainingDays => daysRemaining;
}

@JsonSerializable()
class UserSchedule {
  final String phoneNumber;
  final List<int> selectedDays;
  final Map<String, String> dayTimes;
  final int frequency;
  final DateTime startDate;
  final List<YogaMessage> scheduledMessages;

  UserSchedule({
    required this.phoneNumber,
    required this.selectedDays,
    required this.dayTimes,
    required this.frequency,
    required this.startDate,
    required this.scheduledMessages,
  });

  factory UserSchedule.fromJson(Map<String, dynamic> json) => _$UserScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$UserScheduleToJson(this);
}


