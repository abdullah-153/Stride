import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings_model.dart';
import '../services/settings_service.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(AppSettings.defaultSettings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _service.loadSettings();
      state = settings;
    } catch (e) {
      state = AppSettings.defaultSettings();
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _service.saveSettings(state);
    } catch (e) {
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> toggleWorkoutReminders(bool enabled) async {
    state = state.copyWith(workoutReminders: enabled);
    await _saveSettings();
  }

  Future<void> toggleDietReminders(bool enabled) async {
    state = state.copyWith(dietReminders: enabled);
    await _saveSettings();
  }

  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    state = state.copyWith(workoutReminderTime: time);
    await _saveSettings();
  }

  Future<void> setDietReminderTime(TimeOfDay time) async {
    state = state.copyWith(dietReminderTime: time);
    await _saveSettings();
  }

  Future<void> updatePrivacyLevel(String level) async {
    state = state.copyWith(privacyLevel: level);
    await _saveSettings();
  }

  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
    state = AppSettings.defaultSettings();
  }
}
