import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static SharedPreferencesManager? _instance;
  static SharedPreferences? _prefs;

  SharedPreferencesManager._();

  static Future<SharedPreferencesManager> getInstance() async {
    if (_instance == null) {
      _instance = SharedPreferencesManager._();
      await _instance!._init();
    }
    return _instance!;
  }

  Future<void> _init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      print('ERROR: Failed to initialize SharedPreferences: $e');
      rethrow;
    }
  }

  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
        'SharedPreferencesManager not initialized. Call getInstance() first.',
      );
    }
  }


  static const String keyIsDarkMode = 'isDarkMode';

  static const String keyUserProfile = 'user_profile';
  static const String keyProfileImagePath = 'profile_image_path';

  static const String keyAppSettings = 'app_settings';

  static const String keyHasCompletedOnboarding = 'has_completed_onboarding';


  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }


  Future<bool> setString(String key, String value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setString(key, value);
    } catch (e) {
      print('ERROR: Failed to set string for key "$key": $e');
      return false;
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setInt(key, value);
    } catch (e) {
      print('ERROR: Failed to set int for key "$key": $e');
      return false;
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setDouble(key, value);
    } catch (e) {
      print('ERROR: Failed to set double for key "$key": $e');
      return false;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setBool(key, value);
    } catch (e) {
      print('ERROR: Failed to set bool for key "$key": $e');
      return false;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      _ensureInitialized();
      return await _prefs!.setStringList(key, value);
    } catch (e) {
      print('ERROR: Failed to set string list for key "$key": $e');
      return false;
    }
  }


  Future<bool> remove(String key) async {
    _ensureInitialized();
    return await _prefs!.remove(key);
  }

  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  Future<bool> clear() async {
    _ensureInitialized();
    return await _prefs!.clear();
  }

  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }
}
