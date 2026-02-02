import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/nutrition_model.dart';
import '../services/nutrition_service.dart';

final dietProvider =
    StateNotifierProvider<DietNotifier, AsyncValue<DailyNutrition?>>((ref) {
      return DietNotifier(NutritionService());
    });

class DietNotifier extends StateNotifier<AsyncValue<DailyNutrition?>> {
  final NutritionService _nutritionService;
  DateTime? _currentDate;

  DietNotifier(this._nutritionService) : super(const AsyncValue.loading());

  Future<void> loadDailyNutrition(DateTime date) async {
    _currentDate = date;
    state = const AsyncValue.loading();
    try {
      final data = await _nutritionService.getDailyNutrition(date);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logWater(int amount) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedNutrition = DailyNutrition(
      date: currentState.date,
      meals: currentState.meals,
      waterIntake: currentState.waterIntake + amount,
      goal: currentState.goal,
    );
    state = AsyncValue.data(updatedNutrition);

    try {
      await _nutritionService.logWater(amount);
    } catch (e) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> logMeal(Meal meal) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedMeals = List<Meal>.from(currentState.meals)..add(meal);
    final updatedNutrition = DailyNutrition(
      date: currentState.date,
      meals: updatedMeals,
      waterIntake: currentState.waterIntake,
      goal: currentState.goal,
    );
    state = AsyncValue.data(updatedNutrition);

    try {
      await _nutritionService.logMeal(meal);
    } catch (e) {
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> deleteMeal(String mealId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedMeals = currentState.meals
        .where((m) => m.id != mealId)
        .toList();
    final updatedNutrition = DailyNutrition(
      date: currentState.date,
      meals: updatedMeals,
      waterIntake: currentState.waterIntake,
      goal: currentState.goal,
    );
    state = AsyncValue.data(updatedNutrition);

    try {
      await _nutritionService.deleteMeal(currentState.date, mealId);
    } catch (e) {
      state = AsyncValue.data(currentState);
    }
  }
}
