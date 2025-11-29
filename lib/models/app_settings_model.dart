import 'package:flutter/material.dart';

class AppSettings {
  final bool notificationsEnabled;
  final bool workoutReminders;
  final bool dietReminders;
  final TimeOfDay? workoutReminderTime;
  final TimeOfDay? dietReminderTime;
  final String privacyLevel; // 'public', 'friends', 'private'

  const AppSettings({
    this.notificationsEnabled = true,
    this.workoutReminders = false,
    this.dietReminders = false,
    this.workoutReminderTime,
    this.dietReminderTime,
    this.privacyLevel = 'private',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? workoutReminders,
    bool? dietReminders,
    TimeOfDay? workoutReminderTime,
    TimeOfDay? dietReminderTime,
    String? privacyLevel,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      dietReminders: dietReminders ?? this.dietReminders,
      workoutReminderTime: workoutReminderTime ?? this.workoutReminderTime,
      dietReminderTime: dietReminderTime ?? this.dietReminderTime,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'workoutReminders': workoutReminders,
      'dietReminders': dietReminders,
      'workoutReminderTime': workoutReminderTime != null
          ? {
              'hour': workoutReminderTime!.hour,
              'minute': workoutReminderTime!.minute,
            }
          : null,
      'dietReminderTime': dietReminderTime != null
          ? {'hour': dietReminderTime!.hour, 'minute': dietReminderTime!.minute}
          : null,
      'privacyLevel': privacyLevel,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      workoutReminders: json['workoutReminders'] as bool? ?? false,
      dietReminders: json['dietReminders'] as bool? ?? false,
      workoutReminderTime: json['workoutReminderTime'] != null
          ? TimeOfDay(
              hour: json['workoutReminderTime']['hour'] as int,
              minute: json['workoutReminderTime']['minute'] as int,
            )
          : null,
      dietReminderTime: json['dietReminderTime'] != null
          ? TimeOfDay(
              hour: json['dietReminderTime']['hour'] as int,
              minute: json['dietReminderTime']['minute'] as int,
            )
          : null,
      privacyLevel: json['privacyLevel'] as String? ?? 'private',
    );
  }

  factory AppSettings.defaultSettings() {
    return const AppSettings();
  }
}
