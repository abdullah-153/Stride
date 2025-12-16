import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api/themealdb_api_service.dart';
import 'api/usda_api_service.dart';
import 'firestore/meal_database_service.dart';

class MealService {
  static final MealService _instance = MealService._internal();
  factory MealService() => _instance;
  MealService._internal();

  // final TheMealDBService _apiService = TheMealDBService(); // REMOVED
  final MealDatabaseService _dbService = MealDatabaseService();
  final USDAApiService _usdaService = USDAApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Search for foods (USDA)
  Future<List<Map<String, dynamic>>> searchMeals(String query) async {
    try {
      // Try cache first
      final cachedMeals = await _dbService.searchCachedMeals(query);
      if (cachedMeals.isNotEmpty) {
        return cachedMeals;
      }

      // Fetch from USDA API
      final apiMeals = await _usdaService.searchFoods(query);
      
      // Cache the results
      for (final meal in apiMeals) {
        await _dbService.cacheMeal(meal);
      }

      return apiMeals;
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  /// Get autocomplete suggestions (USDA - No explicit endpoint, return empty or implement basic)
  Future<List<String>> getAutocompleteSuggestions(String query) async {
      // USDA API doesn't have a lightweight autocomplete endpoint.
      // We could call searchFoods but it's heavier. 
      // For now, return empty to disable autocomplete or rely on local history if we implemented it.
      return [];
  }

  /// Get meal by ID (USDA)
  Future<Map<String, dynamic>?> getMealById(String id) async {
    try {
      // Try cache first
      final cachedMeal = await _dbService.getMealFromCache(id);
      if (cachedMeal != null) {
        return cachedMeal;
      }

      // Fetch from USDA API
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

  // --- Disable MealDB specific methods ---

  /// Get a random meal suggestion (Stub)
  Future<Map<String, dynamic>?> getRandomMeal() async {
     // FatSecret doesn't support random meal. 
     // Could implement a random search later.
     return null; 
  }

  /// Get meals by category (Stub)
  Future<List<Map<String, dynamic>>> getMealsByCategory(String category) async {
    // FatSecret is food-based, not recipe category based in the same way.
    return [];
  }

  /// Get available meal categories (Stub)
  Future<List<String>> getCategories() async {
    return [];
  }

  /// Save meal to user's favorites
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

  /// Remove meal from user's favorites
  Future<void> removeSavedMeal(String mealId) async {
    if (_currentUserId == null) return;

    try {
      await _dbService.removeSavedMeal(_currentUserId!, mealId);
    } catch (e) {
      print('Error removing saved meal: $e');
    }
  }

  /// Get user's saved meal IDs
  Future<List<String>> getSavedMealIds() async {
    if (_currentUserId == null) return [];

    try {
      return await _dbService.getUserSavedMealIds(_currentUserId!);
    } catch (e) {
      print('Error getting saved meals: $e');
      return [];
    }
  }

  /// Get user's saved meals with full details
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

  /// Get recently added meals (last 7 days)
  Future<List<Map<String, dynamic>>> getRecentMeals() async {
    if (_currentUserId == null) return [];

    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      // Get recent meal IDs from nutrition service
      final recentMealIds = await _getRecentMealIdsFromNutrition(sevenDaysAgo);
      
      // Get unique meal details
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

  /// Helper to get recent meal IDs from nutrition logs
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
          // If meal has an external ID (from API), add it
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

  /// Quick add a recent meal (logs it again)
  Future<void> quickAddMeal(String mealId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      final meal = await getMealById(mealId);
      if (meal == null) {
        throw Exception('Meal not found');
      }

      // Log the meal using nutrition service
      // You'll need to convert the meal data to your Meal model
      // This is a simplified version - adjust based on your Meal model
      print('Quick adding meal: ${meal['name']}');
      
      // TODO: Integrate with NutritionService to log the meal
      // await nutritionService.logMeal(convertedMeal);
      
    } catch (e) {
      print('Error quick adding meal: $e');
      rethrow;
    }
  }
}
