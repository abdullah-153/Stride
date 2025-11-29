import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final UserProfileService _service;

  UserProfileNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  // Load profile from storage
  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.loadProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update entire profile
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _service.saveProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update individual fields
  Future<void> updateName(String name) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(name: name);
    await updateProfile(updatedProfile);
  }

  Future<void> updateBio(String bio) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(bio: bio);
    await updateProfile(updatedProfile);
  }

  Future<void> updateWeight(double weight) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(weight: weight);
    await updateProfile(updatedProfile);
  }

  Future<void> updateHeight(double height) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(height: height);
    await updateProfile(updatedProfile);
  }

  Future<void> updateAge(int age) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(age: age);
    await updateProfile(updatedProfile);
  }

  Future<void> updateDateOfBirth(DateTime dateOfBirth) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(dateOfBirth: dateOfBirth);
    await updateProfile(updatedProfile);
  }

  Future<void> updateProfileImage(String imagePath) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    await _service.saveProfileImage(imagePath);
    final updatedProfile = currentProfile.copyWith(profileImagePath: imagePath);
    state = AsyncValue.data(updatedProfile);
  }

  // Clear profile data
  Future<void> clearProfile() async {
    try {
      await _service.clearProfile();
      state = AsyncValue.data(UserProfile.defaultProfile());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
