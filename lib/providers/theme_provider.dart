import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/shared_preferences_manager.dart';
import 'package:flutter/services.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefsManager = await SharedPreferencesManager.getInstance();
    state =
        prefsManager.getBool(SharedPreferencesManager.keyIsDarkMode) ?? false;
  }

  Future<void> toggleTheme() async {
    HapticFeedback.selectionClick();
    state = !state;
    final prefsManager = await SharedPreferencesManager.getInstance();
    await prefsManager.setBool(SharedPreferencesManager.keyIsDarkMode, state);
  }

  Future<void> setTheme(bool isDark) async {
    state = isDark;
    final prefsManager = await SharedPreferencesManager.getInstance();
    await prefsManager.setBool(SharedPreferencesManager.keyIsDarkMode, isDark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});
