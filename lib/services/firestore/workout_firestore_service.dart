import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/workout_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class WorkoutFirestoreService extends BaseFirestoreService {
  static final WorkoutFirestoreService _instance = WorkoutFirestoreService._internal();
  factory WorkoutFirestoreService() => _instance;
  WorkoutFirestoreService._internal();

  Future<List<Workout>> getWorkoutLibrary() async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('workoutLibrary')
            .orderBy(FirestoreFields.title)
            .get();
        
        return snapshot.docs
            .map((doc) => Workout.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      },
      errorMessage: 'Failed to fetch workout library',
    );
  }

  Future<List<Workout>> getWorkoutsByCategory(WorkoutCategory category) async {
    return handleFirestoreOperation(
      () async {
        if (category == WorkoutCategory.all) {
          return await getWorkoutLibrary();
        }

        final snapshot = await firestore
            .collection('workoutLibrary')
            .where(FirestoreFields.category, isEqualTo: category.toString().split('.').last)
            .orderBy(FirestoreFields.title)
            .get();
        
        return snapshot.docs
            .map((doc) => Workout.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      },
      errorMessage: 'Failed to fetch workouts by category',
    );
  }

  Future<List<Workout>> getRecommendedWorkouts(String userId) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('workoutLibrary')
            .where(FirestoreFields.isRecommended, isEqualTo: true)
            .limit(5)
            .get();
        
        return snapshot.docs
            .map((doc) => Workout.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      },
      errorMessage: 'Failed to fetch recommended workouts',
    );
  }

  Future<Workout?> getWorkoutById(String workoutId) async {
    return handleFirestoreOperation(
      () async {
        final doc = await firestore
            .collection('workoutLibrary')
            .doc(workoutId)
            .get();
        
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        
        return Workout.fromJson({...doc.data()!, 'id': doc.id});
      },
      errorMessage: 'Failed to fetch workout',
    );
  }

  Future<void> saveCompletedWorkout(
    String userId,
    Workout workout, {
    int? actualDuration,
    String? notes,
  }) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final completionData = {
          FirestoreFields.workoutId: workout.id,
          FirestoreFields.title: workout.title,
          FirestoreFields.category: workout.category.toString().split('.').last,
          FirestoreFields.durationMinutes: workout.durationMinutes,
          FirestoreFields.caloriesBurned: workout.caloriesBurned,
          FirestoreFields.points: workout.points,
          FirestoreFields.difficulty: workout.difficulty.toString().split('.').last,
          FirestoreFields.completedAt: FieldValue.serverTimestamp(),
          FirestoreFields.actualDuration: actualDuration ?? workout.durationMinutes,
          FirestoreFields.notes: notes,
        };
        
        final dataWithTimestamps = addTimestamps(completionData);
        
        await getUserSubcollection(userId, FirestoreCollections.completedWorkouts)
            .add(dataWithTimestamps);
      },
      errorMessage: 'Failed to save completed workout',
    );
  }

  Future<List<Map<String, dynamic>>> getWorkoutHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return handleFirestoreOperation(
      () async {
        Query query = getUserSubcollection(userId, FirestoreCollections.completedWorkouts)
            .orderBy(FirestoreFields.completedAt, descending: true);
        
        if (startDate != null) {
          query = query.where(
            FirestoreFields.completedAt,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          );
        }
        
        if (endDate != null) {
          query = query.where(
            FirestoreFields.completedAt,
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          );
        }
        
        if (limit != null) {
          query = query.limit(limit);
        }
        
        final snapshot = await query.get();
        
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {...data, 'id': doc.id};
        }).toList();
      },
      errorMessage: 'Failed to fetch workout history',
    );
  }

  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await getUserSubcollection(userId, FirestoreCollections.completedWorkouts)
            .get();
        
        int totalWorkouts = snapshot.docs.length;
        int totalCalories = 0;
        int totalMinutes = 0;
        Map<String, int> categoryCount = {};
        
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          
          totalCalories += (data[FirestoreFields.caloriesBurned] as int?) ?? 0;
          totalMinutes += (data[FirestoreFields.actualDuration] as int?) ?? 0;
          
          final category = data[FirestoreFields.category] as String?;
          if (category != null) {
            categoryCount[category] = (categoryCount[category] ?? 0) + 1;
          }
        }
        
        return {
          'totalWorkouts': totalWorkouts,
          'totalCalories': totalCalories,
          'totalMinutes': totalMinutes,
          'categoryBreakdown': categoryCount,
        };
      },
      errorMessage: 'Failed to fetch workout stats',
    );
  }

  Future<int> getTodayWorkoutCount(String userId) async {
    return handleFirestoreOperation(
      () async {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        final snapshot = await getUserSubcollection(userId, FirestoreCollections.completedWorkouts)
            .where(
              FirestoreFields.completedAt,
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where(
              FirestoreFields.completedAt,
              isLessThan: Timestamp.fromDate(endOfDay),
            )
            .get();
        
        return snapshot.docs.length;
      },
      errorMessage: 'Failed to get today workout count',
    );
  }

  Future<void> seedWorkoutLibrary(List<Workout> workouts) async {
    return handleFirestoreOperation(
      () async {
        final batch = firestore.batch();
        
        for (final workout in workouts) {
          final docRef = firestore.collection('workoutLibrary').doc(workout.id);
          batch.set(docRef, workout.toJson());
        }
        
        await batch.commit();
      },
      errorMessage: 'Failed to seed workout library',
    );
  }

  Future<bool> hasWorkoutLibrary() async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('workoutLibrary')
            .limit(1)
            .get();
        
        return snapshot.docs.isNotEmpty;
      },
      errorMessage: 'Failed to check workout library',
    );
  }
}
