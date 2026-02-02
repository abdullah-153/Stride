import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_model.dart';
import 'firestore/activity_firestore_service.dart';
import 'recording_api_service.dart';

class ActivityService {
  static ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  
  final ActivityFirestoreService _firestoreService;
  final FirebaseAuth _auth;
  final RecordingApiService _recordingApiService;
  
  ActivityService._internal({
    ActivityFirestoreService? firestoreService,
    FirebaseAuth? auth,
    RecordingApiService? recordingApiService,
  }) : _firestoreService = firestoreService ?? ActivityFirestoreService(),
       _auth = auth ?? FirebaseAuth.instance,
       _recordingApiService = recordingApiService ?? RecordingApiService() {
    _initRecordingApi();
  }

  @visibleForTesting
  static void reset({
    ActivityFirestoreService? firestoreService,
    FirebaseAuth? auth,
    RecordingApiService? recordingApiService,
  }) {
    _instance = ActivityService._internal(
      firestoreService: firestoreService,
      auth: auth,
      recordingApiService: recordingApiService,
    );
  }

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<void> _initRecordingApi() async {
     
    bool permissionGranted = await _recordingApiService.requestPermission();
    
    if (permissionGranted) {
       
      bool available = await _recordingApiService.checkPlayServices();
      if (available) {
        await _recordingApiService.subscribe();
      }
    } else {
      print("Activity Recognition permission denied.");
    }
  }

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
      ActivityData? activity = await _firestoreService.getDailyActivity(
        _currentUserId!,
        today,
      );

       
      activity ??= ActivityData(
            workoutsCompleted: 0,
            totalWorkouts: 0,
            caloriesBurned: 0,
            steps: 0,
            maxSteps: 10000,
          );

       
      try {
        int localSteps = await _recordingApiService.readSteps();
        if (localSteps > activity.steps) {
           ActivityData updatedActivity = ActivityData(
             workoutsCompleted: activity.workoutsCompleted,
             totalWorkouts: activity.totalWorkouts,
             caloriesBurned: activity.caloriesBurned,
             steps: localSteps,
             maxSteps: activity.maxSteps,
           );
           
            
           _firestoreService.updateDailyActivity(_currentUserId!, today, updatedActivity);
           
           return updatedActivity;
        }
      } catch (e) {
        print("Error syncing local steps: $e");
      }

      return activity;
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
      await _firestoreService.updateDailyActivity(
        _currentUserId!,
        today,
        activityData,
      );
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
      await _firestoreService.addCaloriesBurned(
        _currentUserId!,
        today,
        calories,
      );
    } catch (e) {
      print('Error adding calories burned: $e');
    }
  }

  Future<void> incrementWorkoutsCompleted() async {
    if (_currentUserId == null) return;

    try {
      final today = DateTime.now();
      await _firestoreService.incrementWorkoutsCompleted(
        _currentUserId!,
        today,
        );
    } catch (e) {
      print('Error incrementing workouts completed: $e');
    }
  }

  Future<List<ActivityData>> getActivityHistory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_currentUserId == null) return [];

    try {
      return await _firestoreService.getActivityHistory(
        _currentUserId!,
        startDate,
        endDate,
      );
    } catch (e) {
      print('Error getting activity history: $e');
      return [];
    }
  }
}
