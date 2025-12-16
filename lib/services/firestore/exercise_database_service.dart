import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore/base_firestore_service.dart';

class ExerciseDatabaseService extends BaseFirestoreService {
  static final ExerciseDatabaseService _instance = ExerciseDatabaseService._internal();
  factory ExerciseDatabaseService() => _instance;
  ExerciseDatabaseService._internal();

  Future<void> cacheExercise(Map<String, dynamic> exerciseData) async {
    return handleFirestoreOperation(
      () async {
        final exerciseId = exerciseData['id'] as String;
        final dataWithTimestamps = addTimestamps(exerciseData);
        
        await firestore
            .collection('exerciseDatabase')
            .doc(exerciseId)
            .set(dataWithTimestamps, SetOptions(merge: true));
      },
      errorMessage: 'Failed to cache exercise',
    );
  }

  Future<Map<String, dynamic>?> getExerciseFromCache(String exerciseId) async {
    return handleFirestoreOperation(
      () async {
        final doc = await firestore
            .collection('exerciseDatabase')
            .doc(exerciseId)
            .get();
        
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        
        return {...doc.data()!, 'id': doc.id};
      },
      errorMessage: 'Failed to get exercise from cache',
    );
  }

  Future<List<Map<String, dynamic>>> getExercisesByBodyPart(String bodyPart) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('exerciseDatabase')
            .where('bodyPart', isEqualTo: bodyPart)
            .limit(20)
            .get();
        
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      },
      errorMessage: 'Failed to get exercises by body part',
    );
  }

  Future<List<Map<String, dynamic>>> getExercisesByEquipment(String equipment) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('exerciseDatabase')
            .where('equipment', isEqualTo: equipment)
            .limit(20)
            .get();
        
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      },
      errorMessage: 'Failed to get exercises by equipment',
    );
  }

  Future<void> saveExerciseToUser(String userId, String exerciseId) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        await getUserSubcollection(userId, 'savedExercises')
            .doc(exerciseId)
            .set({
          'exerciseId': exerciseId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      },
      errorMessage: 'Failed to save exercise',
    );
  }

  Future<void> removeSavedExercise(String userId, String exerciseId) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        await getUserSubcollection(userId, 'savedExercises')
            .doc(exerciseId)
            .delete();
      },
      errorMessage: 'Failed to remove saved exercise',
    );
  }

  Future<List<String>> getUserSavedExerciseIds(String userId) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await getUserSubcollection(userId, 'savedExercises')
            .get();
        
        return snapshot.docs.map((doc) => doc.id).toList();
      },
      errorMessage: 'Failed to get saved exercises',
    );
  }

  Future<void> updatePersonalBest(
    String userId,
    String exerciseId,
    double weight,
    int reps,
  ) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        await getUserSubcollection(userId, 'savedExercises')
            .doc(exerciseId)
            .set({
          'exerciseId': exerciseId,
          'personalBest': {
            'weight': weight,
            'reps': reps,
            'date': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      },
      errorMessage: 'Failed to update personal best',
    );
  }
}
