import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../notifiers/user_profile_notifier.dart';
import '../services/auth_service.dart'; // Import auth service for authStateProvider

// Service provider
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

// Main user profile state provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile>>((ref) {
      final service = ref.watch(userProfileServiceProvider);
      // Watch auth state to trigger reload on login/logout
      final authState = ref.watch(authStateProvider);
      
      return UserProfileNotifier(service);
    });

// Derived providers for individual fields (for convenience)
final userNameProvider = Provider<String>((ref) {
  final profileName = ref.watch(userProfileProvider).value?.name;
  if (profileName != null && profileName.isNotEmpty && profileName != 'User') {
    return profileName;
  }
  return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
});

final userBioProvider = Provider<String>((ref) {
  return ref.watch(userProfileProvider).value?.bio ?? '';
});

final userWeightProvider = Provider<double>((ref) {
  return ref.watch(userProfileProvider).value?.weight ?? 70.0;
});

final userHeightProvider = Provider<double>((ref) {
  return ref.watch(userProfileProvider).value?.height ?? 170.0;
});

final userAgeProvider = Provider<int>((ref) {
  return ref.watch(userProfileProvider).value?.age ?? 25;
});

final userBMIProvider = Provider<double>((ref) {
  return ref.watch(userProfileProvider).value?.bmi ?? 0.0;
});

final profileImageProvider = Provider<String?>((ref) {
  return ref.watch(userProfileProvider).value?.profileImagePath;
});
