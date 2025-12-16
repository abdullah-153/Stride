import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import 'firestore/user_profile_firestore_service.dart';
import '../models/diet_plan_model.dart';

class UserProfileService {
  final UserProfileFirestoreService _firestoreService =
      UserProfileFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<UserProfile> loadProfile() async {
    try {
      if (_currentUserId == null) {
        return UserProfile.defaultProfile();
      }

      final profile = await _firestoreService.getUserProfile(_currentUserId!);

      if (profile == null) {
        return UserProfile.defaultProfile();
      }

      return profile;
    } catch (e) {
      print('Error loading profile: $e');
      return UserProfile.defaultProfile();
    }
  }

  Stream<UserProfile?> streamProfile() {
    if (_currentUserId == null) {
      return Stream.value(null);
    }

    return _firestoreService.streamUserProfile(_currentUserId!);
  }

  Future<void> saveProfile(UserProfile profile) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to save profile');
    }

    try {
      final exists = await _firestoreService.profileExists(_currentUserId!);

      if (exists) {
        await _firestoreService.updateUserProfile(_currentUserId!, profile);
      } else {
        await _firestoreService.createUserProfile(_currentUserId!, profile);
      }
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }

  Future<void> createProfile(UserProfile profile) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to create profile');
    }

    try {
      await _firestoreService.createUserProfile(_currentUserId!, profile);
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update profile');
    }

    try {
      await _firestoreService.updateUserProfile(_currentUserId!, profile);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to upload profile image');
    }

    try {
      return await _firestoreService.uploadProfileImage(
        _currentUserId!,
        imageFile,
      );
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<void> deleteProfileImage() async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to delete profile image');
    }

    try {
      await _firestoreService.deleteProfileImage(_currentUserId!);
    } catch (e) {
      throw Exception('Failed to delete profile image: $e');
    }
  }

  Future<void> updateWeight(double weight) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update weight');
    }

    try {
      await _firestoreService.updateWeight(_currentUserId!, weight);
    } catch (e) {
      throw Exception('Failed to update weight: $e');
    }
  }

  Future<void> updateGoals({
    int? weeklyWorkoutGoal,
    int? dailyCalorieGoal,
    double? weightGoal,
  }) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update goals');
    }

    try {
      await _firestoreService.updateGoals(
        _currentUserId!,
        weeklyWorkoutGoal: weeklyWorkoutGoal,
        dailyCalorieGoal: dailyCalorieGoal,
        weightGoal: weightGoal,
      );
    } catch (e) {
      throw Exception('Failed to update goals: $e');
    }
  }

  Future<void> updateActiveDietPlan(DietPlan? plan) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update diet plan');
    }

    try {
      await _firestoreService.updateActiveDietPlan(_currentUserId!, plan);
    } catch (e) {
      throw Exception('Failed to update active diet plan: $e');
    }
  }

  Future<void> incrementWorkoutsCompleted() async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.incrementWorkoutsCompleted(_currentUserId!);
    } catch (e) {
      print('Failed to increment workouts completed: $e');
    }
  }

  Future<void> incrementMealsLogged() async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.incrementMealsLogged(_currentUserId!);
    } catch (e) {
      print('Failed to increment meals logged: $e');
    }
  }

  Future<void> incrementDaysActive() async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.incrementDaysActive(_currentUserId!);
    } catch (e) {
      print('Failed to increment days active: $e');
    }
  }

  Future<bool> profileExists() async {
    if (_currentUserId == null) return false;

    try {
      return await _firestoreService.profileExists(_currentUserId!);
    } catch (e) {
      print('Error checking if profile exists: $e');
      return false;
    }
  }

  Future<void> clearProfile() async {
    if (_currentUserId == null) return;

    try {
      await deleteProfileImage();
    } catch (e) {
      print('Failed to clear profile: $e');
    }
  }
}
