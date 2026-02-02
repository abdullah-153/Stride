import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker_frontend/services/activity_service.dart';
import 'package:fitness_tracker_frontend/models/activity_model.dart';
import 'package:fitness_tracker_frontend/services/firestore/activity_firestore_service.dart';
import 'package:fitness_tracker_frontend/services/recording_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockActivityFirestoreService implements ActivityFirestoreService {
  @override
  Future<ActivityData?> getDailyActivity(String userId, DateTime date) async {
    return ActivityData(
      workoutsCompleted: 1,
      totalWorkouts: 5,
      caloriesBurned: 300,
      steps: 5000,
      maxSteps: 10000,
    );
  }

  @override
  Future<void> updateDailyActivity(
    String userId,
    DateTime date,
    ActivityData activityData,
  ) async {}

  // Implement other methods as stubs or throw UnimplementedError if not used in test
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRecordingApiService implements RecordingApiService {
  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> checkPlayServices() async => true;

  @override
  Future<bool> subscribe() async => true;

  @override
  Future<int> readSteps() async => 6000;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUser implements User {
  @override
  String get uid => 'test_user_id';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ActivityService Tests', () {
    test('getTodayActivity returns valid data', () async {
      final mockFirestore = MockActivityFirestoreService();
      final mockRecording = MockRecordingApiService();
      final mockAuth = MockFirebaseAuth();

      // Reset singleton with mocks
      ActivityService.reset(
        firestoreService: mockFirestore,
        recordingApiService: mockRecording,
        auth: mockAuth,
      );

      final service = ActivityService();
      final data = await service.getTodayActivity();

      // Should prefer local steps (6000) over firestore (5000)
      expect(data.steps, 6000);
      expect(data.caloriesBurned, 300);
    });
  });
}
