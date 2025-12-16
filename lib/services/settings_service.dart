import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_settings_model.dart';
import 'firestore/settings_firestore_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  final SettingsFirestoreService _firestoreService = SettingsFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<AppSettings> getSettings() async {
    if (_currentUserId == null) {
      return AppSettings.defaultSettings();
    }

    try {
      return await _firestoreService.getSettings(_currentUserId!);
    } catch (e) {
      print('Error getting settings: $e');
      return AppSettings.defaultSettings();
    }
  }

  // Alias for getSettings to match expected interface
  Future<AppSettings> loadSettings() => getSettings();

  Stream<AppSettings> streamSettings() {
    if (_currentUserId == null) {
      return Stream.value(AppSettings.defaultSettings());
    }

    return _firestoreService.streamSettings(_currentUserId!);
  }

  Future<void> updateSettings(AppSettings settings) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateSettings(_currentUserId!, settings);
    } catch (e) {
      print('Error updating settings: $e');
      rethrow;
    }
  }

  // Alias for updateSettings to match expected interface
  Future<void> saveSettings(AppSettings settings) => updateSettings(settings);

  Future<void> updateNotificationPreferences({
    bool? notificationsEnabled,
    bool? workoutReminders,
    bool? dietReminders,
  }) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateNotificationPreferences(
        _currentUserId!,
        notificationsEnabled: notificationsEnabled,
        workoutReminders: workoutReminders,
        dietReminders: dietReminders,
      );
    } catch (e) {
      print('Error updating notification preferences: $e');
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    if (_currentUserId == null) return;
    
    try {
      await updateSettings(AppSettings.defaultSettings());
    } catch (e) {
      print('Error resetting settings to defaults: $e');
      rethrow;
    }
  }
}
