import 'dart:async';
import 'dart:math';
import '../models/activity_model.dart';

/// Service for managing daily activity data.
///
/// Provides methods to fetch and update activity metrics including
/// workouts completed, calories burned, and step count.
/// Simulates API calls with mock data for demonstration purposes.
/// Uses singleton pattern to ensure single instance across the app.
class ActivityService {
  // Singleton pattern
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
  }

  /// Fetches today's activity data
  /// Returns mock data simulating an API call
  Future<ActivityData> getTodayActivity() async {
    await _simulateDelay();

    // Mock data - in real app, this would be an HTTP request
    final random = Random();
    final workoutsCompleted = 3 + random.nextInt(3); // 3-5
    final totalWorkouts = 5;
    final caloriesBurned = 250 + random.nextInt(300); // 250-550
    final steps = 3000 + random.nextInt(5000); // 3000-8000
    final maxSteps = 10000;

    return ActivityData(
      workoutsCompleted: workoutsCompleted,
      totalWorkouts: totalWorkouts,
      caloriesBurned: caloriesBurned,
      steps: steps,
      maxSteps: maxSteps,
    );
  }

  /// Simulates updating activity data
  Future<ActivityData> updateActivity({
    int? workoutsCompleted,
    int? caloriesBurned,
    int? steps,
  }) async {
    await _simulateDelay();

    // In a real app, this would send data to the server
    return ActivityData(
      workoutsCompleted: workoutsCompleted ?? 3,
      totalWorkouts: 5,
      caloriesBurned: caloriesBurned ?? 320,
      steps: steps ?? 4520,
      maxSteps: 10000,
    );
  }

  /// Stream for real-time updates (e.g., step counter)
  Stream<int> getStepCountStream() async* {
    int currentSteps = 4520;
    while (true) {
      await Future.delayed(const Duration(seconds: 5));
      // Simulate step increments
      currentSteps += Random().nextInt(20);
      yield currentSteps;
    }
  }
}
