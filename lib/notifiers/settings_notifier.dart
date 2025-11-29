import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings_model.dart';
import '../services/settings_service.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(AppSettings.defaultSettings()) {
    loadSettings();
  }

  // Load settings from storage
  Future<void> loadSettings() async {
    try {
      final settings = await _service.loadSettings();
      state = settings;
    } catch (e) {
      // Keep default settings on error
      state = AppSettings.defaultSettings();
    }
  }

  // Save current settings
  Future<void> _saveSettings() async {
    try {
      await _service.saveSettings(state);
    } catch (e) {
      // Handle error silently or show notification
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  // Toggle workout reminders
  Future<void> toggleWorkoutReminders(bool enabled) async {
    state = state.copyWith(workoutReminders: enabled);
    await _saveSettings();
  }

  // Toggle diet reminders
  Future<void> toggleDietReminders(bool enabled) async {
    state = state.copyWith(dietReminders: enabled);
    await _saveSettings();
  }

  // Set workout reminder time
  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    state = state.copyWith(workoutReminderTime: time);
    await _saveSettings();
  }

  // Set diet reminder time
  Future<void> setDietReminderTime(TimeOfDay time) async {
    state = state.copyWith(dietReminderTime: time);
    await _saveSettings();
  }

  // Update privacy level
  Future<void> updatePrivacyLevel(String level) async {
    state = state.copyWith(privacyLevel: level);
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
    state = AppSettings.defaultSettings();
  }
}
