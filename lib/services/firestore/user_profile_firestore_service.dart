import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile_model.dart';
import '../../models/diet_plan_model.dart';
import '../../models/nutrition_model.dart';
import '../local_image_storage_service.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class UserProfileFirestoreService extends BaseFirestoreService {
  static final UserProfileFirestoreService _instance =
      UserProfileFirestoreService._internal();
  factory UserProfileFirestoreService() => _instance;
  UserProfileFirestoreService._internal();

  final LocalImageStorageService _imageStorage = LocalImageStorageService();

  Future<void> createUserProfile(String userId, UserProfile profile) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final profileData = profile.toJson();
      final dataWithTimestamps = addTimestamps(profileData);

      await getUserDocument(userId)
          .collection(FirestoreCollections.profile)
          .doc('data')
          .set(dataWithTimestamps);
    }, errorMessage: 'Failed to create user profile');
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserProfile.fromJson(doc.data()!);
    }, errorMessage: 'Failed to fetch user profile');
  }

  Stream<UserProfile?> streamUserProfile(String userId) {
    final docRef = getUserDocument(
      userId,
    ).collection(FirestoreCollections.profile).doc('data');

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserProfile.fromJson(snapshot.data()!);
    });
  }

  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final profileData = profile.toJson();
      final dataWithTimestamps = addTimestamps(profileData, isUpdate: true);

      await getUserDocument(userId)
          .collection(FirestoreCollections.profile)
          .doc('data')
          .update(dataWithTimestamps);
    }, errorMessage: 'Failed to update user profile');
  }

  Future<void> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update({
        field: value,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to update profile field');
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final currentProfile = await getUserProfile(userId);
      if (currentProfile?.profileImagePath != null) {
        await _imageStorage.deleteImage(currentProfile!.profileImagePath!);
      }

      final localPath = await _imageStorage.saveImage(
        imageFile,
        userId,
        'profile',
      );

      await updateProfileField(
        userId,
        FirestoreFields.profileImagePath,
        localPath,
      );

      return localPath;
    }, errorMessage: 'Failed to upload profile image');
  }

  Future<void> deleteProfileImage(String userId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final profile = await getUserProfile(userId);
      if (profile?.profileImagePath != null) {
        await _imageStorage.deleteImage(profile!.profileImagePath!);
        await updateProfileField(
          userId,
          FirestoreFields.profileImagePath,
          null,
        );
      }
    }, errorMessage: 'Failed to delete profile image');
  }

  Future<void> incrementWorkoutsCompleted(String userId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update({
        FirestoreFields.totalWorkoutsCompleted: FieldValue.increment(1),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to increment workouts completed');
  }

  Future<void> incrementMealsLogged(String userId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update({
        FirestoreFields.totalMealsLogged: FieldValue.increment(1),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to increment meals logged');
  }

  Future<void> incrementDaysActive(String userId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update({
        FirestoreFields.daysActive: FieldValue.increment(1),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to increment days active');
  }

  Future<void> updateWeight(String userId, double weight) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await updateProfileField(userId, FirestoreFields.weight, weight);
    }, errorMessage: 'Failed to update weight');
  }

  Future<void> updateGoals(
    String userId, {
    int? weeklyWorkoutGoal,
    int? dailyCalorieGoal,
    double? weightGoal,
  }) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final updates = <String, dynamic>{
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      };

      if (weeklyWorkoutGoal != null) {
        updates[FirestoreFields.weeklyWorkoutGoal] = weeklyWorkoutGoal;
      }
      if (dailyCalorieGoal != null) {
        updates[FirestoreFields.dailyCalorieGoal] = dailyCalorieGoal;
      }
      if (weightGoal != null) {
        updates[FirestoreFields.weightGoal] = weightGoal;
      }

      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update(updates);
    }, errorMessage: 'Failed to update goals');
  }

  Future<void> updateActiveDietPlan(String userId, DietPlan? plan) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final updates = <String, dynamic>{
        'activeDietPlan': plan?.toJson(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      };

      if (plan != null) {
        updates['nutritionGoal'] = NutritionGoal(
          dailyCalories: plan.dailyCalories,
          protein: plan.macros.protein,
          carbs: plan.macros.carbs,
          fats: plan.macros.fats,
          waterGoal: plan.waterIntakeLiters.round(),
        ).toJson();

        updates[FirestoreFields.dailyCalorieGoal] = plan.dailyCalories;
      }

      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').update(updates);
    }, errorMessage: 'Failed to update active diet plan');
  }

  Future<bool> profileExists(String userId) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserDocument(
        userId,
      ).collection(FirestoreCollections.profile).doc('data').get();

      return doc.exists;
    }, errorMessage: 'Failed to check if profile exists');
  }
}
