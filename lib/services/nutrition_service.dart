import '../models/nutrition_model.dart';
import '../models/gamification_model.dart';
import 'gamification_service.dart';

/// Service for managing nutrition tracking and meal logging.
///
/// Handles daily nutrition data, meal management, water intake tracking,
/// and favorite meals. Integrates with [GamificationService] to award XP
/// for logging meals and achieving nutrition goals.
/// Uses singleton pattern to ensure single instance across the app.
class NutritionService {
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  final NutritionGoal _defaultGoal = NutritionGoal(
    dailyCalories: 2000,
    protein: 150,
    carbs: 250,
    fats: 45,
    waterGoal: 2500,
  );

  final Map<DateTime, DailyNutrition> _nutritionData = {};
  final List<Meal> _favoriteMeals = [];
  final GamificationService _gamificationService = GamificationService();

  Future<NutritionGoal> getNutritionGoal() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _defaultGoal;
  }

  Future<DailyNutrition> getDailyNutrition(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final dateKey = DateTime(date.year, date.month, date.day);

    if (_nutritionData.containsKey(dateKey)) {
      return _nutritionData[dateKey]!;
    }

    final isToday = _isSameDay(date, DateTime.now());
    final meals = isToday ? _getTodayMockMeals() : _getRandomMockMeals(date);
    final waterIntake = isToday ? 1500 : (date.day * 100) % 2500;

    final dailyNutrition = DailyNutrition(
      date: dateKey,
      meals: meals,
      waterIntake: waterIntake,
      goal: _defaultGoal,
    );

    _nutritionData[dateKey] = dailyNutrition;
    return dailyNutrition;
  }

  Future<void> logMeal(Meal meal) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    if (_nutritionData.containsKey(dateKey)) {
      _nutritionData[dateKey]!.meals.add(meal);
    } else {
      _nutritionData[dateKey] = DailyNutrition(
        date: dateKey,
        meals: [meal],
        waterIntake: 0,
        goal: _defaultGoal,
      );
    }

    // Gamification Integration
    _gamificationService.addXp(10); // 10 XP per meal
    _gamificationService.checkStreak(StreakType.diet, today);

    // Check for protein goal
    final currentDay = _nutritionData[dateKey]!;
    if (currentDay.proteinGoalMet) {
      _gamificationService.unlockAchievement('protein_pro');
      _gamificationService.addXp(50); // Bonus for hitting protein goal
    }
  }

  Future<void> deleteMeal(String mealId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    if (_nutritionData.containsKey(dateKey)) {
      _nutritionData[dateKey]!.meals.removeWhere((m) => m.id == mealId);
    }
  }

  Future<void> logWater(int amount) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final today = DateTime.now();
    final dateKey = DateTime(today.year, today.month, today.day);

    if (_nutritionData.containsKey(dateKey)) {
      final current = _nutritionData[dateKey]!;
      _nutritionData[dateKey] = DailyNutrition(
        date: current.date,
        meals: current.meals,
        waterIntake: current.waterIntake + amount,
        goal: current.goal,
      );
    } else {
      _nutritionData[dateKey] = DailyNutrition(
        date: dateKey,
        meals: [],
        waterIntake: amount,
        goal: _defaultGoal,
      );
    }

    // Gamification Integration
    _gamificationService.addXp(5); // 5 XP per water log

    final currentDay = _nutritionData[dateKey]!;
    if (currentDay.waterGoalMet) {
      _gamificationService.unlockAchievement('hydration_hero');
      _gamificationService.addXp(30); // Bonus for hitting water goal
    }
  }

  Future<List<Meal>> getRecentMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final recentMeals = <Meal>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      if (_nutritionData.containsKey(dateKey)) {
        recentMeals.addAll(_nutritionData[dateKey]!.meals);
      }
    }

    final uniqueMeals = <String, Meal>{};
    for (var meal in recentMeals) {
      if (!uniqueMeals.containsKey(meal.name)) {
        uniqueMeals[meal.name] = meal;
      }
    }

    return uniqueMeals.values.take(10).toList();
  }

  Future<List<Meal>> getFavoriteMeals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_favoriteMeals);
  }

  Future<void> toggleFavorite(String mealId) async {
    await Future.delayed(const Duration(milliseconds: 100));

    for (var dailyData in _nutritionData.values) {
      for (var meal in dailyData.meals) {
        if (meal.id == mealId) {
          final updatedMeal = meal.copyWith(isFavorite: !meal.isFavorite);
          final index = dailyData.meals.indexOf(meal);
          dailyData.meals[index] = updatedMeal;

          if (updatedMeal.isFavorite) {
            if (!_favoriteMeals.any((m) => m.name == updatedMeal.name)) {
              _favoriteMeals.add(updatedMeal);
            }
          } else {
            _favoriteMeals.removeWhere((m) => m.name == updatedMeal.name);
          }
          return;
        }
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Meal> _getTodayMockMeals() {
    final now = DateTime.now();
    return [
      Meal(
        id: 'today_1',
        name: 'Oatmeal with Berries',
        type: MealType.breakfast,
        calories: 350,
        macros: MacroNutrients(protein: 12, carbs: 60, fats: 8),
        timestamp: DateTime(now.year, now.month, now.day, 8, 30),
        isFavorite: true,
      ),
      Meal(
        id: 'today_2',
        name: 'Grilled Chicken Salad',
        type: MealType.lunch,
        calories: 450,
        macros: MacroNutrients(protein: 45, carbs: 30, fats: 15),
        timestamp: DateTime(now.year, now.month, now.day, 13, 0),
        isFavorite: true,
      ),
      Meal(
        id: 'today_3',
        name: 'Protein Shake',
        type: MealType.snack,
        calories: 200,
        macros: MacroNutrients(protein: 30, carbs: 15, fats: 3),
        timestamp: DateTime(now.year, now.month, now.day, 16, 0),
        isFavorite: false,
      ),
    ];
  }

  List<Meal> _getRandomMockMeals(DateTime date) {
    final meals = <Meal>[];
    final random = date.day % 3;

    if (random >= 0) {
      meals.add(
        Meal(
          id: 'past_${date.day}_1',
          name: 'Scrambled Eggs & Toast',
          type: MealType.breakfast,
          calories: 400,
          macros: MacroNutrients(protein: 25, carbs: 35, fats: 18),
          timestamp: DateTime(date.year, date.month, date.day, 8, 0),
          isFavorite: false,
        ),
      );
    }

    if (random >= 1) {
      meals.add(
        Meal(
          id: 'past_${date.day}_2',
          name: 'Turkey Sandwich',
          type: MealType.lunch,
          calories: 500,
          macros: MacroNutrients(protein: 35, carbs: 50, fats: 15),
          timestamp: DateTime(date.year, date.month, date.day, 12, 30),
          isFavorite: false,
        ),
      );
    }

    if (random >= 2) {
      meals.add(
        Meal(
          id: 'past_${date.day}_3',
          name: 'Salmon with Rice',
          type: MealType.dinner,
          calories: 600,
          macros: MacroNutrients(protein: 40, carbs: 55, fats: 20),
          timestamp: DateTime(date.year, date.month, date.day, 19, 0),
          isFavorite: false,
        ),
      );
    }

    return meals;
  }
}
