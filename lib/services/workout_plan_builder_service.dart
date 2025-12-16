import 'package:firebase_auth/firebase_auth.dart';
import 'api/exercisedb_api_service.dart';
import 'firestore/exercise_database_service.dart';
import 'firestore/workout_plan_service.dart';
import 'ai_workout_service.dart';

class WorkoutPlanBuilderService {
  static final WorkoutPlanBuilderService _instance = WorkoutPlanBuilderService._internal();
  factory WorkoutPlanBuilderService() => _instance;
  WorkoutPlanBuilderService._internal();

  final AIWorkoutService _aiService = AIWorkoutService();
  final ExerciseDatabaseService _exerciseDb = ExerciseDatabaseService();
  final WorkoutPlanService _planService = WorkoutPlanService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  /// Generate a workout plan using AI
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String goal,
    required int daysPerWeek,
    required int durationWeeks,
    required List<String> targetMuscles,
    required String fitnessLevel,
    required List<String> equipment,
  }) async {
    try {
      // 1. Generate plan configuration via AI
      final planData = await _aiService.generateWorkoutPlan(
        goal: goal,
        daysPerWeek: daysPerWeek,
        targetMuscles: targetMuscles,
        fitnessLevel: fitnessLevel,
        equipment: equipment,
      );

      // 2. Post-process: Add metadata not returned by AI (or override it)
      // We ensure the AI followed the structure, but we enforce some fields
      planData['goal'] = goal;
      planData['difficulty'] = fitnessLevel;
      planData['daysPerWeek'] = daysPerWeek;
      planData['durationWeeks'] = durationWeeks;
      
      // 3. Cache exercises found in the plan to our local DB? 
      // The AI returns names/details. We might not match them to ExerciseDB IDs perfectly.
      // For now, we trust the AI's output and will store it as a 'custom' plan.
      
      return planData;
    } catch (e) {
      print('Error generating workout plan: $e');
      rethrow;
    }
  }

  /// Save generated plan to Firestore
  Future<String> saveWorkoutPlan(Map<String, dynamic> planData) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to save workout plan');
    }

    try {
      return await _planService.createWorkoutPlan(_currentUserId!, planData);
    } catch (e) {
      print('Error saving workout plan: $e');
      rethrow;
    }
  }

  /// Get user's saved workout plans
  Future<List<Map<String, dynamic>>> getUserPlans() async {
    if (_currentUserId == null) return [];

    try {
      return await _planService.getUserWorkoutPlans(_currentUserId!);
    } catch (e) {
      print('Error getting user plans: $e');
      return [];
    }
  }

  /// Set a plan as active
  Future<void> activatePlan(String planId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated');
    }

    try {
      await _planService.setActiveWorkoutPlan(
        _currentUserId!,
        planId,
        DateTime.now(),
      );
    } catch (e) {
      print('Error activating plan: $e');
      rethrow;
    }
  }

  /// Get active workout plan
  Future<Map<String, dynamic>?> getActivePlan() async {
    if (_currentUserId == null) return null;

    try {
      final activePlan = await _planService.getActiveWorkoutPlan(_currentUserId!);
      if (activePlan == null) return null;

      // Get the full plan details
      final planId = activePlan['planId'] as String;
      final fullPlan = await _planService.getWorkoutPlan(_currentUserId!, planId);
      
      return {
        ...fullPlan!,
        'currentWeek': activePlan['currentWeek'],
        'currentDay': activePlan['currentDay'],
        'startDate': activePlan['startDate'],
        'completedWorkouts': activePlan['completedWorkouts'],
      };
    } catch (e) {
      print('Error getting active plan: $e');
      return null;
    }
  }
}
