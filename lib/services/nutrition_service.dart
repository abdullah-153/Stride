import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_model.dart';
import '../models/gamification_model.dart';
import 'package:fitness_tracker_frontend/models/nutrition_model.dart';
import 'package:fitness_tracker_frontend/models/diet_plan_model.dart';
import 'gamification_service.dart';
import 'firestore/nutrition_firestore_service.dart';
import 'user_profile_service.dart';

class NutritionService {
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  final NutritionFirestoreService _firestoreService = NutritionFirestoreService();
  final GamificationService _gamificationService = GamificationService();
  final UserProfileService _userProfileService = UserProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<NutritionGoal> getNutritionGoal() async {
    if (_currentUserId == null) {
      return NutritionGoal(
        dailyCalories: 2000,
        protein: 150,
        carbs: 250,
        fats: 45,
        waterGoal: 2500,
      );
    }

    try {
      // First try to get from user profile (Single Source of Truth)
      final profile = await _userProfileService.loadProfile();
      if (profile.nutritionGoal != null) {
        return profile.nutritionGoal!;
      }

      // Fallback to legacy behavior
      return await _firestoreService.getNutritionGoals(_currentUserId!);
    } catch (e) {
      print('Error getting nutrition goal: $e');
      return NutritionGoal(
        dailyCalories: 2000,
        protein: 150,
        carbs: 250,
        fats: 45,
        waterGoal: 2500,
      );
    }
  }

  Future<DailyNutrition?> getDailyNutrition(DateTime date) async {
    if (_currentUserId == null) return null;

    try {
      return await _firestoreService.getDailyNutrition(_currentUserId!, date);
    } catch (e) {
      print('Error getting daily nutrition: $e');
      return null;
    }
  }

  Stream<DailyNutrition?> streamDailyNutrition(DateTime date) {
    if (_currentUserId == null) {
      return Stream.value(null);
    }

    return _firestoreService.streamDailyNutrition(_currentUserId!, date);
  }

  Future<void> logMeal(Meal meal) async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      
      // Get current goals from profile to ensure new day creation uses correct goals
      final profile = await _userProfileService.loadProfile();
      
      await _firestoreService.addMeal(_currentUserId!, today, meal, currentGoals: profile.nutritionGoal);

      await _gamificationService.addXp(10);
      await _gamificationService.checkStreak(StreakType.diet, today);

      await _userProfileService.incrementMealsLogged();

      final dailyNutrition = await _firestoreService.getDailyNutrition(_currentUserId!, today);
      if (dailyNutrition != null && dailyNutrition.proteinGoalMet) {
        await _gamificationService.unlockAchievement('protein_pro');
        await _gamificationService.addXp(50);
      }
    } catch (e) {
      print('Error logging meal: $e');
      rethrow;
    }
  }

  Future<void> updateMeal(DateTime date, Meal meal) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateMeal(_currentUserId!, date, meal);
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }

  Future<void> deleteMeal(DateTime date, String mealId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.deleteMeal(_currentUserId!, date, mealId);
    } catch (e) {
      print('Error deleting meal: $e');
      rethrow;
    }
  }

  Future<String> uploadMealImage(String mealId, File imageFile) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to upload meal image');
    }

    try {
      return await _firestoreService.uploadMealImage(_currentUserId!, mealId, imageFile);
    } catch (e) {
      print('Error uploading meal image: $e');
      rethrow;
    }
  }

  Future<void> logWater(int amount) async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      
      // Get current goals from profile to ensure new day creation uses correct goals
      final profile = await _userProfileService.loadProfile();
      
      final current = await _firestoreService.getDailyNutrition(_currentUserId!, today);
      final newAmount = (current?.waterIntake ?? 0) + amount;

      await _firestoreService.updateWaterIntake(_currentUserId!, today, newAmount, currentGoals: profile.nutritionGoal);

      await _gamificationService.addXp(10); // Increased XP
      await _gamificationService.checkStreak(StreakType.diet, today); // Water counts for diet streak!

      final dailyNutrition = await _firestoreService.getDailyNutrition(_currentUserId!, today);
      if (dailyNutrition != null && dailyNutrition.waterGoalMet) {
        await _gamificationService.unlockAchievement('hydration_hero');
        await _gamificationService.addXp(30);
      }
    } catch (e) {
      print('Error logging water: $e');
      rethrow;
    }
  }

  Future<void> saveDietPlan(DietPlan plan) async {
    if (_currentUserId == null) return;

    try {
      // 1. Update Profile (Active Plan & Default Goals)
      await _userProfileService.updateActiveDietPlan(plan);

      // 2. Update Today's Goals (so UI reflects change immediately)
      final goals = NutritionGoal(
        dailyCalories: plan.dailyCalories,
        protein: plan.macros.protein,
        carbs: plan.macros.carbs,
        fats: plan.macros.fats,
        waterGoal: (plan.waterIntakeLiters * 1000).round(), // Convert L to mL
      );
      
      await _firestoreService.updateNutritionGoals(_currentUserId!, goals);

      // 3. Update Today's Daily Entry Goal
      final today = DateTime.now();
      await _firestoreService.updateDailyGoal(_currentUserId!, today, goals);
      
    } catch (e) {
      print('Error saving diet plan: $e');
      rethrow;
    }
  }

  Future<void> updateNutritionGoals(NutritionGoal goals) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateNutritionGoals(_currentUserId!, goals);
    } catch (e) {
      print('Error updating nutrition goals: $e');
      rethrow;
    }
  }

  Future<List<DailyNutrition>> getNutritionHistory(DateTime startDate, DateTime endDate) async {
    if (_currentUserId == null) return [];

    try {
      return await _firestoreService.getNutritionHistory(_currentUserId!, startDate, endDate);
    } catch (e) {
      print('Error getting nutrition history: $e');
      return [];
    }
  }
}
