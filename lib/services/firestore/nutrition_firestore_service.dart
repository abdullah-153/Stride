import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nutrition_model.dart';
import '../local_image_storage_service.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class NutritionFirestoreService extends BaseFirestoreService {
  static final NutritionFirestoreService _instance =
      NutritionFirestoreService._internal();
  factory NutritionFirestoreService() => _instance;
  NutritionFirestoreService._internal();

  final LocalImageStorageService _imageStorage = LocalImageStorageService();

  Future<DailyNutrition?> getDailyNutrition(
    String userId,
    DateTime date,
  ) async {
    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final doc = await getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()! as Map<String, dynamic>;
      final mealsSnapshot =
          await getUserSubcollection(userId, FirestoreCollections.nutrition)
              .doc(dateKey)
              .collection(FirestoreCollections.meals)
              .orderBy(FirestoreFields.timestamp)
              .get();

      final meals = mealsSnapshot.docs
          .map((doc) => Meal.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return DailyNutrition(
        date: timestampToDateTime(data[FirestoreFields.date]) ?? date,
        meals: meals,
        waterIntake: data[FirestoreFields.waterIntake] as int? ?? 0,
        goal: NutritionGoal.fromJson(
          data[FirestoreFields.goal] as Map<String, dynamic>,
        ),
      );
    }, errorMessage: 'Failed to fetch daily nutrition');
  }

  Stream<DailyNutrition?> streamDailyNutrition(String userId, DateTime date) {
    final dateKey = getDateKey(date);
    final docRef = getUserSubcollection(
      userId,
      FirestoreCollections.nutrition,
    ).doc(dateKey);

    return docRef.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }

      final data = snapshot.data()! as Map<String, dynamic>;
      final mealsSnapshot = await docRef
          .collection(FirestoreCollections.meals)
          .orderBy(FirestoreFields.timestamp)
          .get();

      final meals = mealsSnapshot.docs
          .map((doc) => Meal.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return DailyNutrition(
        date: timestampToDateTime(data[FirestoreFields.date]) ?? date,
        meals: meals,
        waterIntake: data[FirestoreFields.waterIntake] as int? ?? 0,
        goal: NutritionGoal.fromJson(
          data[FirestoreFields.goal] as Map<String, dynamic>,
        ),
      );
    });
  }

  Future<void> addMeal(
    String userId,
    DateTime date,
    Meal meal, {
    NutritionGoal? currentGoals,
  }) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      final exists = await documentExists(nutritionRef);
      if (!exists) {
        await _initializeDailyNutrition(userId, date, goals: currentGoals);
      }

      final mealData = meal.toJson();
      final dataWithTimestamps = addTimestamps(mealData);

      await nutritionRef
          .collection(FirestoreCollections.meals)
          .doc(meal.id)
          .set(dataWithTimestamps);

      await nutritionRef.update({
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to add meal');
  }

  Future<void> updateMeal(String userId, DateTime date, Meal meal) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      final exists = await documentExists(nutritionRef);
      if (!exists) {
        await _initializeDailyNutrition(userId, date);
      }

      final mealData = meal.toJson();
      final dataWithTimestamps = addTimestamps(mealData);

      await nutritionRef
          .collection(FirestoreCollections.meals)
          .doc(meal.id)
          .set(dataWithTimestamps);

      await nutritionRef.update({
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to update meal');
  }

  Future<void> deleteMeal(String userId, DateTime date, String mealId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      await nutritionRef
          .collection(FirestoreCollections.meals)
          .doc(mealId)
          .delete();

      await nutritionRef.update({
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to delete meal');
  }

  Future<String> uploadMealImage(
    String userId,
    String mealId,
    File imageFile,
  ) async {
    ensureAuthenticated();
    return _imageStorage.saveImage(imageFile, userId, 'meals');
  }

  Future<void> updateWaterIntake(
    String userId,
    DateTime date,
    int amount, {
    NutritionGoal? currentGoals,
  }) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      final exists = await documentExists(nutritionRef);
      if (!exists) {
        await _initializeDailyNutrition(userId, date, goals: currentGoals);
      }

      await nutritionRef.update({
        FirestoreFields.waterIntake: amount,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to update water intake');
  }

  Future<void> updateDailyGoal(
    String userId,
    DateTime date,
    NutritionGoal goal,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      final exists = await documentExists(nutritionRef);
      if (!exists) {
        await _initializeDailyNutrition(userId, date, goals: goal);
      } else {
        await nutritionRef.update({
          FirestoreFields.goal: goal.toJson(),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }, errorMessage: 'Failed to update daily goal');
  }

  Future<NutritionGoal> getNutritionGoals(String userId) async {
    return handleFirestoreOperation(() async {
      final today = DateTime.now();
      final dateKey = getDateKey(today);
      final doc = await getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()! as Map<String, dynamic>;
        if (data[FirestoreFields.goal] != null) {
          return NutritionGoal.fromJson(
            data[FirestoreFields.goal] as Map<String, dynamic>,
          );
        }
      }

      return NutritionGoal(
        dailyCalories: 2000,
        protein: 150,
        carbs: 200,
        fats: 65,
        waterGoal: 8,
      );
    }, errorMessage: 'Failed to fetch nutrition goals');
  }

  Future<void> updateNutritionGoals(String userId, NutritionGoal goals) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final today = DateTime.now();
      final dateKey = getDateKey(today);
      final nutritionRef = getUserSubcollection(
        userId,
        FirestoreCollections.nutrition,
      ).doc(dateKey);

      final exists = await documentExists(nutritionRef);
      if (!exists) {
        await _initializeDailyNutrition(userId, today, goals: goals);
      } else {
        await nutritionRef.update({
          FirestoreFields.goal: goals.toJson(),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    }, errorMessage: 'Failed to update nutrition goals');
  }

  Future<List<DailyNutrition>> getNutritionHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return handleFirestoreOperation(() async {
      final snapshot =
          await getUserSubcollection(userId, FirestoreCollections.nutrition)
              .where(
                FirestoreFields.date,
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                FirestoreFields.date,
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy(FirestoreFields.date, descending: true)
              .get();

      final nutritionList = <DailyNutrition>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final mealsSnapshot = await doc.reference
            .collection(FirestoreCollections.meals)
            .orderBy(FirestoreFields.timestamp)
            .get();

        final meals = mealsSnapshot.docs
            .map(
              (mealDoc) => Meal.fromJson({...mealDoc.data(), 'id': mealDoc.id}),
            )
            .toList();

        nutritionList.add(
          DailyNutrition(
            date: timestampToDateTime(data[FirestoreFields.date])!,
            meals: meals,
            waterIntake: data[FirestoreFields.waterIntake] as int? ?? 0,
            goal: NutritionGoal.fromJson(
              data[FirestoreFields.goal] as Map<String, dynamic>,
            ),
          ),
        );
      }

      return nutritionList;
    }, errorMessage: 'Failed to fetch nutrition history');
  }

  Future<void> _initializeDailyNutrition(
    String userId,
    DateTime date, {
    NutritionGoal? goals,
  }) async {
    final dateKey = getDateKey(date);
    final defaultGoals =
        goals ??
        NutritionGoal(
          dailyCalories: 2000,
          protein: 150,
          carbs: 200,
          fats: 65,
          waterGoal: 8,
        );

    await getUserSubcollection(
      userId,
      FirestoreCollections.nutrition,
    ).doc(dateKey).set({
      FirestoreFields.date: Timestamp.fromDate(date),
      FirestoreFields.waterIntake: 0,
      FirestoreFields.goal: defaultGoals.toJson(),
      ...addTimestamps({}),
    });
  }
}
