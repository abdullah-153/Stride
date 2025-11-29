import 'package:shared_preferences/shared_preferences.dart';

/// Centralized SharedPreferences manager for the entire app.
/// Provides singleton instance and type-safe getter/setter methods.
class SharedPreferencesManager {
  static SharedPreferencesManager? _instance;
  static SharedPreferences? _prefs;

  // Private constructor for singleton pattern
  SharedPreferencesManager._();

  /// Get singleton instance of SharedPreferencesManager
  static Future<SharedPreferencesManager> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesManager._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      // Log error and rethrow
      print('ERROR: Failed to initialize SharedPreferences: $e');
      rethrow;
    }
  }

  /// Ensure preferences are initialized
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
        'SharedPreferencesManager not initialized. Call getInstance() first.',
      );
    }
  }

  // ==================== KEYS ====================
  // All SharedPreferences keys defined in one place

  // Theme
  static const String keyIsDarkMode = 'isDarkMode';

  // User Profile
  static const String keyUserProfile = 'user_profile';
  static const String keyProfileImagePath = 'profile_image_path';

  // App Settings
  static const String keyAppSettings = 'app_settings';

  // Onboarding
  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';

  // ==================== GETTERS ====================

  /// Get string value
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Get int value
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Get double value
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Get bool value
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Get string list value
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  // ==================== SETTERS ====================

  /// Set string value
  Future<bool> setString(String key, String value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setString(key, value);
    } catch (e) {
      print('ERROR: Failed to set string for key "$key": $e');
      return false;
    }
  }

  /// Set int value
  Future<bool> setInt(String key, int value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setInt(key, value);
    } catch (e) {
      print('ERROR: Failed to set int for key "$key": $e');
      return false;
    }
  }

  /// Set double value
  Future<bool> setDouble(String key, double value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      print('ERROR: Failed to set double for key "$key": $e');
      return false;
    }
  }

  /// Set bool value
  Future<bool> setBool(String key, bool value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      print('ERROR: Failed to set bool for key "$key": $e');
      return false;
    }
  }

  /// Set string list value
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      print('ERROR: Failed to set string list for key "$key": $e');
      return false;
    }
  }

  // ==================== UTILITIES ====================

  /// Remove a key
  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Clear all preferences
  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs!.clear();
  }

  /// Get all keys
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }
}
