import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore/base_firestore_service.dart';

class WorkoutPlanService extends BaseFirestoreService {
  static final WorkoutPlanService _instance = WorkoutPlanService._internal();
  factory WorkoutPlanService() => _instance;
  WorkoutPlanService._internal();

  Future<String> createWorkoutPlan(
    String userId,
    Map<String, dynamic> planData,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dataWithTimestamps = addTimestamps(planData);

      final docRef = await getUserSubcollection(
        userId,
        'customWorkoutPlans',
      ).add(dataWithTimestamps);

      return docRef.id;
    }, errorMessage: 'Failed to create workout plan');
  }

  Future<List<Map<String, dynamic>>> getUserWorkoutPlans(String userId) async {
    return handleFirestoreOperation(() async {
      final snapshot = await getUserSubcollection(
        userId,
        'customWorkoutPlans',
      ).orderBy('createdAt', descending: true).get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    }, errorMessage: 'Failed to get workout plans');
  }

  Future<Map<String, dynamic>?> getWorkoutPlan(
    String userId,
    String planId,
  ) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserSubcollection(
        userId,
        'customWorkoutPlans',
      ).doc(planId).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return {...doc.data()! as Map<String, dynamic>, 'id': doc.id};
    }, errorMessage: 'Failed to get workout plan');
  }

  Future<void> updateWorkoutPlan(
    String userId,
    String planId,
    Map<String, dynamic> updates,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dataWithTimestamps = addTimestamps(updates, isUpdate: true);

      await getUserSubcollection(
        userId,
        'customWorkoutPlans',
      ).doc(planId).update(dataWithTimestamps);
    }, errorMessage: 'Failed to update workout plan');
  }

  Future<void> deleteWorkoutPlan(String userId, String planId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserSubcollection(
        userId,
        'customWorkoutPlans',
      ).doc(planId).delete();
    }, errorMessage: 'Failed to delete workout plan');
  }

  Future<void> setActiveWorkoutPlan(
    String userId,
    String planId,
    DateTime startDate,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserSubcollection(userId, 'activeWorkoutPlan').doc('data').set({
        'planId': planId,
        'startDate': Timestamp.fromDate(startDate),
        'currentWeek': 1,
        'currentDay': 1,
        'completedWorkouts': [],
        ...addTimestamps({}),
      });
    }, errorMessage: 'Failed to set active workout plan');
  }

  Future<Map<String, dynamic>?> getActiveWorkoutPlan(String userId) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserSubcollection(
        userId,
        'activeWorkoutPlan',
      ).doc('data').get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return doc.data() as Map<String, dynamic>?;
    }, errorMessage: 'Failed to get active workout plan');
  }

  Future<void> markWorkoutCompleted(
    String userId,
    Map<String, dynamic> workoutData,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserSubcollection(
        userId,
        'activeWorkoutPlan',
      ).doc('data').update({
        'completedWorkouts': FieldValue.arrayUnion([
          {'date': FieldValue.serverTimestamp(), ...workoutData},
        ]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to mark workout as completed');
  }

  Future<void> progressPlan(
    String userId,
    int currentWeek,
    int currentDay,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserSubcollection(
        userId,
        'activeWorkoutPlan',
      ).doc('data').update({
        'currentWeek': currentWeek,
        'currentDay': currentDay,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to progress plan');
  }
}
