import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings_model.dart';
import '../services/settings_service.dart';
import '../notifiers/settings_notifier.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final appSettingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
      final service = ref.watch(settingsServiceProvider);
      return SettingsNotifier(service);
    });

final notificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).notificationsEnabled;
});

final workoutRemindersProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).workoutReminders;
});

final dietRemindersProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).dietReminders;
});

final privacyLevelProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider).privacyLevel;
});
