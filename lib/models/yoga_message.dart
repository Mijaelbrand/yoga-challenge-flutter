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
  final bool isRegistered;
  final bool isAccessExpired;
  final DateTime? registrationDate;
  final int daysSinceRegistration;
  final int remainingDays;
  final String? error;

  PhoneVerificationResult({
    required this.isRegistered,
    required this.isAccessExpired,
    this.registrationDate,
    required this.daysSinceRegistration,
    required this.remainingDays,
    this.error,
  });

  factory PhoneVerificationResult.fromJson(Map<String, dynamic> json) => _$PhoneVerificationResultFromJson(json);
  Map<String, dynamic> toJson() => _$PhoneVerificationResultToJson(this);
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
