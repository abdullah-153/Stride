import 'dart:convert';
import '../models/app_settings_model.dart';
import '../utils/shared_preferences_manager.dart';

/// Service for managing app settings persistence
class SettingsService {
  // Load app settings from shared preferences
  Future<AppSettings> loadSettings() async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      final settingsJson = prefsManager.getString(
        SharedPreferencesManager.keyAppSettings,
      );

      if (settingsJson != null) {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        return AppSettings.fromJson(json);
      }

      // Return default settings if none exist
      return AppSettings.defaultSettings();
    } catch (e) {
      // On error, return default settings
      return AppSettings.defaultSettings();
    }
  }

  // Save app settings to shared preferences
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefsManager.setString(
        SharedPreferencesManager.keyAppSettings,
        settingsJson,
      );
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  // Reset to default settings
  Future<void> resetToDefaults() async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      await prefsManager.remove(SharedPreferencesManager.keyAppSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }
}
