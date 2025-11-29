import 'dart:convert';
import '../models/user_profile_model.dart';
import '../utils/shared_preferences_manager.dart';

/// Service for managing user profile persistence
class UserProfileService {
  // Load user profile from shared preferences
  Future<UserProfile> loadProfile() async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      final profileJson = prefsManager.getString(
        SharedPreferencesManager.keyUserProfile,
      );

      if (profileJson != null) {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        return UserProfile.fromJson(json);
      }

      // Return default profile if none exists
      return UserProfile.defaultProfile();
    } catch (e) {
      // On error, return default profile
      return UserProfile.defaultProfile();
    }
  }

  // Save user profile to shared preferences
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefsManager.setString(
        SharedPreferencesManager.keyUserProfile,
        profileJson,
      );
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  // Save profile image path
  Future<void> saveProfileImage(String path) async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      await prefsManager.setString(
        SharedPreferencesManager.keyProfileImagePath,
        path,
      );
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  // Clear all profile data
  Future<void> clearProfile() async {
    try {
      final prefsManager = await SharedPreferencesManager.getInstance();
      await prefsManager.remove(SharedPreferencesManager.keyUserProfile);
      await prefsManager.remove(SharedPreferencesManager.keyProfileImagePath);
    } catch (e) {
      throw Exception('Failed to clear profile: $e');
    }
  }
}
