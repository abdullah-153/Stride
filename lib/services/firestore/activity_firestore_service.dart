import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class ActivityFirestoreService extends BaseFirestoreService {
  static final ActivityFirestoreService _instance = ActivityFirestoreService._internal();
  factory ActivityFirestoreService() => _instance;
  ActivityFirestoreService._internal();

  Future<ActivityData?> getDailyActivity(String userId, DateTime date) async {
    return handleFirestoreOperation(
      () async {
        final dateKey = getDateKey(date);
        final doc = await getUserSubcollection(userId, FirestoreCollections.activity)
            .doc(dateKey)
            .get();
        
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        
        return ActivityData.fromJson(doc.data()! as Map<String, dynamic>);
      },
      errorMessage: 'Failed to fetch daily activity',
    );
  }

  Stream<ActivityData?> streamDailyActivity(String userId, DateTime date) {
    final dateKey = getDateKey(date);
    final docRef = getUserSubcollection(userId, FirestoreCollections.activity).doc(dateKey);
    
    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return ActivityData.fromJson(snapshot.data()! as Map<String, dynamic>);
    });
  }

  Future<void> updateDailyActivity(String userId, DateTime date, ActivityData activityData) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final dateKey = getDateKey(date);
        final data = activityData.toJson();
        data[FirestoreFields.date] = Timestamp.fromDate(date);
        final dataWithTimestamps = addTimestamps(data, isUpdate: true);
        
        await getUserSubcollection(userId, FirestoreCollections.activity)
            .doc(dateKey)
            .set(dataWithTimestamps, SetOptions(merge: true));
      },
      errorMessage: 'Failed to update daily activity',
    );
  }

  Future<void> incrementSteps(String userId, DateTime date, int steps) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final dateKey = getDateKey(date);
        final docRef = getUserSubcollection(userId, FirestoreCollections.activity).doc(dateKey);
        
        final exists = await documentExists(docRef);
        if (!exists) {
          await _initializeDailyActivity(userId, date);
        }
        
        await docRef.update({
          FirestoreFields.steps: FieldValue.increment(steps),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      },
      errorMessage: 'Failed to increment steps',
    );
  }

  Future<void> addCaloriesBurned(String userId, DateTime date, int calories) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final dateKey = getDateKey(date);
        final docRef = getUserSubcollection(userId, FirestoreCollections.activity).doc(dateKey);
        
        final exists = await documentExists(docRef);
        if (!exists) {
          await _initializeDailyActivity(userId, date);
        }
        
        await docRef.update({
          FirestoreFields.caloriesBurned: FieldValue.increment(calories),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      },
      errorMessage: 'Failed to add calories burned',
    );
  }

  Future<void> incrementWorkoutsCompleted(String userId, DateTime date) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final dateKey = getDateKey(date);
        final docRef = getUserSubcollection(userId, FirestoreCollections.activity).doc(dateKey);
        
        final exists = await documentExists(docRef);
        if (!exists) {
          await _initializeDailyActivity(userId, date);
        }
        
        await docRef.update({
          FirestoreFields.workoutsCompleted: FieldValue.increment(1),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      },
      errorMessage: 'Failed to increment workouts completed',
    );
  }

  Future<List<ActivityData>> getActivityHistory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await getUserSubcollection(userId, FirestoreCollections.activity)
            .where(
              FirestoreFields.date,
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .where(
              FirestoreFields.date,
              isLessThanOrEqualTo: Timestamp.fromDate(endDate),
            )
            .orderBy(FirestoreFields.date, descending: true)
            .get();
        
        return snapshot.docs
            .map((doc) => ActivityData.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      },
      errorMessage: 'Failed to fetch activity history',
    );
  }

  Future<void> _initializeDailyActivity(String userId, DateTime date) async {
    final dateKey = getDateKey(date);
    
    await getUserSubcollection(userId, FirestoreCollections.activity)
        .doc(dateKey)
        .set({
      FirestoreFields.date: Timestamp.fromDate(date),
      FirestoreFields.workoutsCompleted: 0,
      FirestoreFields.totalWorkouts: 0,
      FirestoreFields.caloriesBurned: 0,
      FirestoreFields.steps: 0,
      FirestoreFields.maxSteps: 10000,
      ...addTimestamps({}),
    });
  }
}
