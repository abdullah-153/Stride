import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import '../models/gamification_model.dart';
import 'gamification_service.dart';
import 'firestore/workout_firestore_service.dart';
import 'firestore/workout_plan_service.dart';
import 'user_profile_service.dart';

class WorkoutService {
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal() {
    _initializeWorkoutLibrary();
  }

  final WorkoutFirestoreService _firestoreService = WorkoutFirestoreService();
  final WorkoutPlanService _planService = WorkoutPlanService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> _initializeWorkoutLibrary() async {
    try {
      final hasLibrary = await _firestoreService.hasWorkoutLibrary();
      if (!hasLibrary) {
        final mockWorkouts = _generateMockWorkouts();
        await _firestoreService.seedWorkoutLibrary(mockWorkouts);
        print('Workout library seeded successfully');
      }
    } catch (e) {
      print('Error initializing workout library: $e');
    }
  }

  Future<List<Workout>> getTodayWorkouts() async {
    try {
      // Check for active plan first
      if (_currentUserId != null) {
        final activePlanData = await _planService.getActiveWorkoutPlan(_currentUserId!);
        if (activePlanData != null) {
           final planId = activePlanData['planId'];
           final currentDay = activePlanData['currentDay'] as int;
           
           final plan = await _planService.getWorkoutPlan(_currentUserId!, planId);
           if (plan != null) {
              final weeklyPlan = plan['weeklyPlan'] as List;
              var dayData = weeklyPlan.firstWhere(
                  (day) => day['day'] == currentDay, 
                  orElse: () => null
              );
              
               if (dayData != null) {
                  final exercisesList = dayData['exercises'] as List;
                  List<Workout> workouts = [];
                  
                  for (var i = 0; i < exercisesList.length; i++) {
                     final ex = exercisesList[i];
                     
                     // Parse reps
                     int? repsInt;
                     var repsVal = ex['reps'];
                     if (repsVal is int) {
                        repsInt = repsVal;
                     } else if (repsVal is String) {
                        final parts = repsVal.split('-');
                        if (parts.isNotEmpty) {
                           repsInt = int.tryParse(parts[0]);
                        }
                     }
                     
                     // Get exercise duration
                     final exerciseMinutes = ex['estimatedMinutes'] as int? ?? 5;
                     
                     // Create single exercise
                     final exercise = Exercise(
                        name: (ex['name'] as String?) ?? 'Exercise',
                        sets: ex['sets'] as int?,
                        reps: repsInt,
                        muscleGroups: ex['targetMuscle'] != null ? [(ex['targetMuscle'] as String)] : const <String>[], 
                     );

                     // Create individual workout for this exercise
                     final workout = Workout(
                       id: 'plan_${planId}_day_${currentDay}_ex_$i',
                       title: ex['name'] ?? 'Exercise ${i + 1}',
                       category: WorkoutCategory.strength,
                       durationMinutes: exerciseMinutes,
                       caloriesBurned: (exerciseMinutes * 6.5).round(),
                       points: 10,
                       difficulty: DifficultyLevel.intermediate,
                       exercises: [exercise],
                       description: '${ex['sets']} sets × ${ex['reps']} reps',
                       isRecommended: false,
                     );
                     
                     workouts.add(workout);
                  }
                  
                  return workouts;
               }
           }
        }
      }

      final allWorkouts = await _firestoreService.getWorkoutLibrary();
      final count = 3 + _random.nextInt(3);
      allWorkouts.shuffle(_random);
      return allWorkouts.take(count).toList();
    } catch (e) {
      print('Error getting today workouts: $e');
      return [];
    }
  }

  Future<List<Workout>> getWorkoutsByCategory(WorkoutCategory category) async {
    try {
      return await _firestoreService.getWorkoutsByCategory(category);
    } catch (e) {
      print('Error getting workouts by category: $e');
      return [];
    }
  }

  Future<List<Workout>> getRecommendedWorkouts() async {
    // Removed placeholder workouts - only show active plan workouts
    return [];
  }

  List<WorkoutCategory> getAllCategories() {
    return WorkoutCategory.values;
  }

  Future<Workout?> getWorkoutById(String id) async {
    try {
      return await _firestoreService.getWorkoutById(id);
    } catch (e) {
      print('Error getting workout by id: $e');
      return null;
    }
  }

  Future<void> completeWorkout(
    Workout workout, {
    int? actualDuration,
    String? notes,
  }) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.saveCompletedWorkout(
        _currentUserId!,
        workout,
        actualDuration: actualDuration,
        notes: notes,
      );

      final gamificationService = GamificationService();
      await gamificationService.addXp(workout.points * 10);
      await gamificationService.checkStreak(StreakType.workout, DateTime.now());

      final profileService = UserProfileService();
      await profileService.incrementWorkoutsCompleted();
    } catch (e) {
      print('Error completing workout (offline mode): $e');
      
      // Offline Store Logic
      try {
        final prefs = await SharedPreferences.getInstance();
        final pendingWorkouts = prefs.getStringList('pending_workouts') ?? [];
        
        final offlineData = {
          'userId': _currentUserId,
          'workout': workout.toJson(),
          'actualDuration': actualDuration,
          'notes': notes,
          'completedAt': DateTime.now().toIso8601String(),
        };
        
        pendingWorkouts.add(jsonEncode(offlineData));
        await prefs.setStringList('pending_workouts', pendingWorkouts);
        print('Workout saved locally for later sync');
        
        // Optimistically treat as success for the UI
        return; 
      } catch (innerE) {
        print('Error saving locally: $innerE');
        // If even local save fails, then we might want to rethrow or just fail silently
        // But rethrow is probably better here to let UI know something is really wrong
        rethrow;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (_currentUserId == null) return [];

    try {
      return await _firestoreService.getWorkoutHistory(
        _currentUserId!,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } catch (e) {
      print('Error getting workout history: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getWorkoutStats() async {
    if (_currentUserId == null) {
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'categoryBreakdown': {},
      };
    }

    try {
      return await _firestoreService.getWorkoutStats(_currentUserId!);
    } catch (e) {
      print('Error getting workout stats: $e');
      return {
        'totalWorkouts': 0,
        'totalCalories': 0,
        'totalMinutes': 0,
        'categoryBreakdown': {},
      };
    }
  }

  Future<int> getTodayWorkoutCount() async {
    if (_currentUserId == null) return 0;

    try {
      return await _firestoreService.getTodayWorkoutCount(_currentUserId!);
    } catch (e) {
      print('Error getting today workout count: $e');
      return 0;
    }
  }

  List<Workout> _generateMockWorkouts() {
    return [
      Workout(
        id: 'cardio_1',
        title: 'Morning Run',
        category: WorkoutCategory.cardio,
        durationMinutes: 30,
        caloriesBurned: 350,
        points: 2,
        difficulty: DifficultyLevel.beginner,
        description: 'Start your day with an energizing run',
        isRecommended: true,
        exercises: [
          Exercise(
            name: 'Warm-up Walk',
            durationSeconds: 300,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Steady Run',
            durationSeconds: 1200,
            muscleGroups: ['Legs', 'Core'],
          ),
          Exercise(
            name: 'Cool-down Walk',
            durationSeconds: 300,
            muscleGroups: ['Legs'],
          ),
        ],
      ),
      Workout(
        id: 'cardio_2',
        title: 'HIIT Cardio Blast',
        category: WorkoutCategory.hiit,
        durationMinutes: 20,
        caloriesBurned: 280,
        points: 3,
        difficulty: DifficultyLevel.advanced,
        description: 'High-intensity interval training for maximum burn',
        isRecommended: true,
        exercises: [
          Exercise(
            name: 'Jumping Jacks',
            sets: 3,
            durationSeconds: 30,
            muscleGroups: ['Full Body'],
          ),
          Exercise(
            name: 'Burpees',
            sets: 3,
            reps: 10,
            muscleGroups: ['Full Body'],
          ),
          Exercise(
            name: 'Mountain Climbers',
            sets: 3,
            durationSeconds: 30,
            muscleGroups: ['Core', 'Arms'],
          ),
          Exercise(
            name: 'High Knees',
            sets: 3,
            durationSeconds: 30,
            muscleGroups: ['Legs'],
          ),
        ],
      ),
      Workout(
        id: 'cardio_3',
        title: 'Cycling Session',
        category: WorkoutCategory.cardio,
        durationMinutes: 45,
        caloriesBurned: 420,
        points: 3,
        difficulty: DifficultyLevel.intermediate,
        description: 'Endurance cycling workout',
        exercises: [
          Exercise(
            name: 'Warm-up Cycle',
            durationSeconds: 300,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Steady Pace',
            durationSeconds: 1800,
            muscleGroups: ['Legs', 'Glutes'],
          ),
          Exercise(
            name: 'Sprint Intervals',
            sets: 5,
            durationSeconds: 60,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Cool-down',
            durationSeconds: 300,
            muscleGroups: ['Legs'],
          ),
        ],
      ),
      Workout(
        id: 'strength_1',
        title: 'Upper Body Power',
        category: WorkoutCategory.strength,
        durationMinutes: 40,
        caloriesBurned: 250,
        points: 2,
        difficulty: DifficultyLevel.intermediate,
        description: 'Build upper body strength',
        isRecommended: true,
        exercises: [
          Exercise(
            name: 'Push-ups',
            sets: 4,
            reps: 12,
            muscleGroups: ['Chest', 'Arms'],
          ),
          Exercise(
            name: 'Dumbbell Rows',
            sets: 4,
            reps: 10,
            muscleGroups: ['Back'],
          ),
          Exercise(
            name: 'Shoulder Press',
            sets: 3,
            reps: 12,
            muscleGroups: ['Shoulders'],
          ),
          Exercise(
            name: 'Bicep Curls',
            sets: 3,
            reps: 15,
            muscleGroups: ['Arms'],
          ),
          Exercise(
            name: 'Tricep Dips',
            sets: 3,
            reps: 12,
            muscleGroups: ['Arms'],
          ),
        ],
      ),
      Workout(
        id: 'strength_2',
        title: 'Leg Day',
        category: WorkoutCategory.strength,
        durationMinutes: 50,
        caloriesBurned: 320,
        points: 3,
        difficulty: DifficultyLevel.advanced,
        description: 'Complete lower body workout',
        exercises: [
          Exercise(
            name: 'Squats',
            sets: 4,
            reps: 15,
            muscleGroups: ['Legs', 'Glutes'],
          ),
          Exercise(name: 'Lunges', sets: 3, reps: 12, muscleGroups: ['Legs']),
          Exercise(
            name: 'Deadlifts',
            sets: 4,
            reps: 10,
            muscleGroups: ['Legs', 'Back'],
          ),
          Exercise(
            name: 'Calf Raises',
            sets: 3,
            reps: 20,
            muscleGroups: ['Calves'],
          ),
          Exercise(
            name: 'Leg Press',
            sets: 3,
            reps: 12,
            muscleGroups: ['Legs'],
          ),
        ],
      ),
      Workout(
        id: 'strength_3',
        title: 'Core Crusher',
        category: WorkoutCategory.strength,
        durationMinutes: 25,
        caloriesBurned: 180,
        points: 2,
        difficulty: DifficultyLevel.beginner,
        description: 'Strengthen your core muscles',
        exercises: [
          Exercise(
            name: 'Plank',
            sets: 3,
            durationSeconds: 60,
            muscleGroups: ['Core'],
          ),
          Exercise(name: 'Crunches', sets: 3, reps: 20, muscleGroups: ['Abs']),
          Exercise(
            name: 'Russian Twists',
            sets: 3,
            reps: 30,
            muscleGroups: ['Obliques'],
          ),
          Exercise(
            name: 'Leg Raises',
            sets: 3,
            reps: 15,
            muscleGroups: ['Lower Abs'],
          ),
          Exercise(
            name: 'Bicycle Crunches',
            sets: 3,
            reps: 20,
            muscleGroups: ['Abs'],
          ),
        ],
      ),
      Workout(
        id: 'yoga_1',
        title: 'Morning Flow',
        category: WorkoutCategory.yoga,
        durationMinutes: 30,
        caloriesBurned: 120,
        points: 1,
        difficulty: DifficultyLevel.beginner,
        description: 'Gentle yoga flow to start your day',
        exercises: [
          Exercise(
            name: 'Sun Salutation',
            sets: 3,
            durationSeconds: 120,
            muscleGroups: ['Full Body'],
          ),
          Exercise(
            name: 'Warrior Poses',
            durationSeconds: 180,
            muscleGroups: ['Legs', 'Core'],
          ),
          Exercise(
            name: 'Tree Pose',
            durationSeconds: 60,
            muscleGroups: ['Legs', 'Core'],
          ),
          Exercise(
            name: 'Child\'s Pose',
            durationSeconds: 120,
            muscleGroups: ['Back'],
          ),
          Exercise(
            name: 'Savasana',
            durationSeconds: 300,
            muscleGroups: ['Full Body'],
          ),
        ],
      ),
      Workout(
        id: 'yoga_2',
        title: 'Power Yoga',
        category: WorkoutCategory.yoga,
        durationMinutes: 45,
        caloriesBurned: 200,
        points: 2,
        difficulty: DifficultyLevel.intermediate,
        description: 'Dynamic and challenging yoga practice',
        exercises: [
          Exercise(
            name: 'Vinyasa Flow',
            sets: 5,
            durationSeconds: 180,
            muscleGroups: ['Full Body'],
          ),
          Exercise(
            name: 'Chair Pose Hold',
            sets: 3,
            durationSeconds: 45,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Chaturanga',
            sets: 10,
            reps: 1,
            muscleGroups: ['Arms', 'Core'],
          ),
          Exercise(
            name: 'Pigeon Pose',
            durationSeconds: 120,
            muscleGroups: ['Hips'],
          ),
        ],
      ),
      Workout(
        id: 'flex_1',
        title: 'Full Body Stretch',
        category: WorkoutCategory.flexibility,
        durationMinutes: 20,
        caloriesBurned: 80,
        points: 1,
        difficulty: DifficultyLevel.beginner,
        description: 'Improve flexibility and reduce tension',
        exercises: [
          Exercise(
            name: 'Hamstring Stretch',
            durationSeconds: 60,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Quad Stretch',
            durationSeconds: 60,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Shoulder Stretch',
            durationSeconds: 45,
            muscleGroups: ['Shoulders'],
          ),
          Exercise(
            name: 'Hip Flexor Stretch',
            durationSeconds: 60,
            muscleGroups: ['Hips'],
          ),
          Exercise(
            name: 'Spinal Twist',
            durationSeconds: 90,
            muscleGroups: ['Back'],
          ),
        ],
      ),
      Workout(
        id: 'sports_1',
        title: 'Basketball Drills',
        category: WorkoutCategory.sports,
        durationMinutes: 40,
        caloriesBurned: 380,
        points: 3,
        difficulty: DifficultyLevel.intermediate,
        description: 'Improve your basketball skills',
        exercises: [
          Exercise(
            name: 'Dribbling Drills',
            durationSeconds: 600,
            muscleGroups: ['Arms', 'Legs'],
          ),
          Exercise(
            name: 'Shooting Practice',
            reps: 50,
            muscleGroups: ['Arms', 'Core'],
          ),
          Exercise(
            name: 'Defensive Slides',
            sets: 5,
            durationSeconds: 30,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Layup Drills',
            reps: 20,
            muscleGroups: ['Legs', 'Core'],
          ),
        ],
      ),
      Workout(
        id: 'sports_2',
        title: 'Soccer Training',
        category: WorkoutCategory.sports,
        durationMinutes: 50,
        caloriesBurned: 450,
        points: 3,
        difficulty: DifficultyLevel.advanced,
        description: 'Soccer-specific conditioning',
        exercises: [
          Exercise(
            name: 'Dribbling Course',
            durationSeconds: 600,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Passing Drills',
            durationSeconds: 480,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Sprint Training',
            sets: 10,
            durationSeconds: 20,
            muscleGroups: ['Legs'],
          ),
          Exercise(
            name: 'Shooting Practice',
            reps: 30,
            muscleGroups: ['Legs', 'Core'],
          ),
        ],
      ),
    ];
  }
}
