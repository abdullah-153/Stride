import 'dart:async';
import 'dart:math';
import '../models/workout_model.dart';
import '../models/gamification_model.dart';
import 'gamification_service.dart';

/// Service for managing workout data and operations.
///
/// Provides methods to fetch, filter, and complete workouts.
/// Integrates with [GamificationService] to award XP and track streaks.
/// Uses singleton pattern to ensure single instance across the app.
class WorkoutService {
  // Singleton pattern
  static final WorkoutService _instance = WorkoutService._internal();
  factory WorkoutService() => _instance;
  WorkoutService._internal();

  final Random _random = Random();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
  }

  /// Get today's workouts (3-5 workouts)
  Future<List<Workout>> getTodayWorkouts() async {
    await _simulateDelay();

    final allWorkouts = _generateMockWorkouts();
    final count = 3 + _random.nextInt(3); // 3-5 workouts
    return allWorkouts.take(count).toList();
  }

  /// Get workouts filtered by category
  Future<List<Workout>> getWorkoutsByCategory(WorkoutCategory category) async {
    await _simulateDelay();

    if (category == WorkoutCategory.all) {
      return _generateMockWorkouts();
    }

    final allWorkouts = _generateMockWorkouts();
    return allWorkouts.where((w) => w.category == category).toList();
  }

  /// Get recommended workouts
  Future<List<Workout>> getRecommendedWorkouts() async {
    await _simulateDelay();

    final allWorkouts = _generateMockWorkouts();
    return allWorkouts.where((w) => w.isRecommended).take(3).toList();
  }

  /// Get all available categories
  List<WorkoutCategory> getAllCategories() {
    return WorkoutCategory.values;
  }

  /// Get workout by ID with full details
  Future<Workout?> getWorkoutById(String id) async {
    await _simulateDelay();

    final allWorkouts = _generateMockWorkouts();
    try {
      return allWorkouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> completeWorkout(Workout workout) async {
    // In a real app, this would save to a database
    await _simulateDelay();

    // Gamification Integration
    final gamificationService = GamificationService();
    gamificationService.addXp(workout.points * 10); // Points * 10 XP
    gamificationService.checkStreak(StreakType.workout, DateTime.now());
  }

  /// Generate mock workout data
  List<Workout> _generateMockWorkouts() {
    return [
      // Cardio Workouts
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
        durationMinutes: 1,
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
        durationMinutes: 1,
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

      // Strength Workouts
      Workout(
        id: 'strength_1',
        title: 'Upper Body Power',
        category: WorkoutCategory.strength,
        durationMinutes: 2,
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
        durationMinutes: 3,
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
        durationMinutes: 3,
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

      // Yoga Workouts
      Workout(
        id: 'yoga_1',
        title: 'Morning Flow',
        category: WorkoutCategory.yoga,
        durationMinutes: 1,
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
        durationMinutes: 2,
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

      // Flexibility Workouts
      Workout(
        id: 'flex_1',
        title: 'Full Body Stretch',
        category: WorkoutCategory.flexibility,
        durationMinutes: 1,
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

      // Sports Workouts
      Workout(
        id: 'sports_1',
        title: 'Basketball Drills',
        category: WorkoutCategory.sports,
        durationMinutes: 2,
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
        durationMinutes: 1,
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
