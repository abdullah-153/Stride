import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';
import 'firestore/activity_firestore_service.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final ActivityFirestoreService _firestoreService = ActivityFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<ActivityData> getTodayActivity() async {
    if (_currentUserId == null) {
      return ActivityData(
        workoutsCompleted: 0,
        totalWorkouts: 0,
        caloriesBurned: 0,
        steps: 0,
        maxSteps: 10000,
      );
    }

    try {
      final today = DateTime.now();
      final activity = await _firestoreService.getDailyActivity(_currentUserId!, today);
      
      return activity ?? ActivityData(
        workoutsCompleted: 0,
        totalWorkouts: 0,
        caloriesBurned: 0,
        steps: 0,
        maxSteps: 10000,
      );
    } catch (e) {
      print('Error getting today activity: $e');
      return ActivityData(
        workoutsCompleted: 0,
        totalWorkouts: 0,
        caloriesBurned: 0,
        steps: 0,
        maxSteps: 10000,
      );
    }
  }

  Stream<ActivityData?> streamTodayActivity() {
    if (_currentUserId == null) {
      return Stream.value(null);
    }

    final today = DateTime.now();
    return _firestoreService.streamDailyActivity(_currentUserId!, today);
  }

  Future<void> updateActivity(ActivityData activityData) async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      await _firestoreService.updateDailyActivity(_currentUserId!, today, activityData);
    } catch (e) {
      print('Error updating activity: $e');
      rethrow;
    }
  }

  Future<void> incrementSteps(int steps) async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      await _firestoreService.incrementSteps(_currentUserId!, today, steps);
    } catch (e) {
      print('Error incrementing steps: $e');
    }
  }

  Future<void> addCaloriesBurned(int calories) async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      await _firestoreService.addCaloriesBurned(_currentUserId!, today, calories);
    } catch (e) {
      print('Error adding calories burned: $e');
    }
  }

  Future<void> incrementWorkoutsCompleted() async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      await _firestoreService.incrementWorkoutsCompleted(_currentUserId!, today);
    } catch (e) {
      print('Error incrementing workouts completed: $e');
    }
  }

  Future<List<ActivityData>> getActivityHistory(DateTime startDate, DateTime endDate) async {
    if (_currentUserId == null) return [];

    try {
      return await _firestoreService.getActivityHistory(_currentUserId!, startDate, endDate);
    } catch (e) {
      print('Error getting activity history: $e');
      return [];
    }
  }
}
