import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api/usda_api_service.dart';
import 'firestore/meal_database_service.dart';

class MealService {
  static final MealService _instance = MealService._internal();
  factory MealService() => _instance;
  MealService._internal();

  final MealDatabaseService _dbService = MealDatabaseService();
  final USDAApiService _usdaService = USDAApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<List<Map<String, dynamic>>> searchMeals(String query) async {
    try {
      final cachedMeals = await _dbService.searchCachedMeals(query);
      if (cachedMeals.isNotEmpty) {
        return cachedMeals;
      }

      final apiMeals = await _usdaService.searchFoods(query);

      for (final meal in apiMeals) {
        await _dbService.cacheMeal(meal);
      }

      return apiMeals;
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  Future<List<String>> getAutocompleteSuggestions(String query) async {
    return [];
  }

  Future<Map<String, dynamic>?> getMealById(String id) async {
    try {
      final cachedMeal = await _dbService.getMealFromCache(id);
      if (cachedMeal != null) {
        return cachedMeal;
      }

      final apiMeal = await _usdaService.getFoodById(id);

      if (apiMeal != null) {
        await _dbService.cacheMeal(apiMeal);
      }

      return apiMeal;
    } catch (e) {
      print('Error getting meal by ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRandomMeal() async {
    return null;
  }

  Future<List<Map<String, dynamic>>> getMealsByCategory(String category) async {
    return [];
  }

  Future<List<String>> getCategories() async {
    return [];
  }

  Future<void> saveMeal(String mealId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to save meals');
    }

    try {
      await _dbService.saveMealToUser(_currentUserId!, mealId);
    } catch (e) {
      print('Error saving meal: $e');
      rethrow;
    }
  }

  Future<void> removeSavedMeal(String mealId) async {
    if (_currentUserId == null) return;

    try {
      await _dbService.removeSavedMeal(_currentUserId!, mealId);
    } catch (e) {
      print('Error removing saved meal: $e');
    }
  }

  Future<List<String>> getSavedMealIds() async {
    if (_currentUserId == null) return [];

    try {
      return await _dbService.getUserSavedMealIds(_currentUserId!);
    } catch (e) {
      print('Error getting saved meals: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSavedMeals() async {
    if (_currentUserId == null) return [];

    try {
      final mealIds = await getSavedMealIds();
      final meals = <Map<String, dynamic>>[];

      for (final id in mealIds) {
        final meal = await getMealById(id);
        if (meal != null) {
          meals.add(meal);
        }
      }

      return meals;
    } catch (e) {
      print('Error getting saved meals: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentMeals() async {
    if (_currentUserId == null) return [];

    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final recentMealIds = await _getRecentMealIdsFromNutrition(sevenDaysAgo);

      final uniqueMeals = <String, Map<String, dynamic>>{};

      for (final mealId in recentMealIds) {
        if (!uniqueMeals.containsKey(mealId)) {
          final meal = await getMealById(mealId);
          if (meal != null) {
            uniqueMeals[mealId] = meal;
          }
        }
      }

      return uniqueMeals.values.toList();
    } catch (e) {
      print('Error getting recent meals: $e');
      return [];
    }
  }

  Future<List<String>> _getRecentMealIdsFromNutrition(DateTime since) async {
    if (_currentUserId == null) return [];

    try {
      final snapshot = await _dbService.firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('nutrition')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .get();

      final mealIds = <String>[];

      for (final doc in snapshot.docs) {
        final mealsSnapshot = await doc.reference
            .collection('meals')
            .orderBy('timestamp', descending: true)
            .get();

        for (final mealDoc in mealsSnapshot.docs) {
          final mealData = mealDoc.data();
          if (mealData['id'] != null) {
            mealIds.add(mealData['id'] as String);
          }
        }
      }

      return mealIds;
    } catch (e) {
      print('Error getting recent meal IDs: $e');
      return [];
    }
  }

  Future<void> quickAddMeal(String mealId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      final meal = await getMealById(mealId);
      if (meal == null) {
        throw Exception('Meal not found');
      }

      print('Quick adding meal: ${meal['name']}');
    } catch (e) {
      print('Error quick adding meal: $e');
      rethrow;
    }
  }
}
