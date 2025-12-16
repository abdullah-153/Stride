import 'package:firebase_auth/firebase_auth.dart';
import 'api/exercisedb_api_service.dart';
import 'firestore/exercise_database_service.dart';

class ExerciseService {
  static final ExerciseService _instance = ExerciseService._internal();
  factory ExerciseService() => _instance;
  ExerciseService._internal();

  final ExerciseDBService _apiService = ExerciseDBService();
  final ExerciseDatabaseService _dbService = ExerciseDatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<List<Map<String, dynamic>>> getExercises({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final exercises = await _apiService.getAllExercises(
        limit: limit,
        offset: offset,
      );

      for (final exercise in exercises) {
        await _dbService.cacheExercise(exercise);
      }

      return exercises;
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    try {
      final cachedExercise = await _dbService.getExerciseFromCache(id);
      if (cachedExercise != null) {
        return cachedExercise;
      }

      final apiExercise = await _apiService.getExerciseById(id);

      if (apiExercise != null) {
        await _dbService.cacheExercise(apiExercise);
      }

      return apiExercise;
    } catch (e) {
      print('Error getting exercise by ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByBodyPart(
    String bodyPart, {
    int limit = 10,
  }) async {
    try {
      final cachedExercises = await _dbService.getExercisesByBodyPart(bodyPart);
      if (cachedExercises.isNotEmpty) {
        return cachedExercises;
      }

      final apiExercises = await _apiService.getExercisesByBodyPart(
        bodyPart,
        limit: limit,
      );

      for (final exercise in apiExercises) {
        await _dbService.cacheExercise(exercise);
      }

      return apiExercises;
    } catch (e) {
      print('Error getting exercises by body part: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByEquipment(
    String equipment, {
    int limit = 10,
  }) async {
    try {
      final cachedExercises = await _dbService.getExercisesByEquipment(
        equipment,
      );
      if (cachedExercises.isNotEmpty) {
        return cachedExercises;
      }

      final apiExercises = await _apiService.getExercisesByEquipment(
        equipment,
        limit: limit,
      );

      for (final exercise in apiExercises) {
        await _dbService.cacheExercise(exercise);
      }

      return apiExercises;
    } catch (e) {
      print('Error getting exercises by equipment: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByTarget(
    String target, {
    int limit = 10,
  }) async {
    try {
      final exercises = await _apiService.getExercisesByTarget(
        target,
        limit: limit,
      );

      for (final exercise in exercises) {
        await _dbService.cacheExercise(exercise);
      }

      return exercises;
    } catch (e) {
      print('Error getting exercises by target: $e');
      return [];
    }
  }

  Future<List<String>> getBodyPartList() async {
    try {
      return await _apiService.getBodyPartList();
    } catch (e) {
      print('Error getting body part list: $e');
      return [];
    }
  }

  Future<List<String>> getEquipmentList() async {
    try {
      return await _apiService.getEquipmentList();
    } catch (e) {
      print('Error getting equipment list: $e');
      return [];
    }
  }

  Future<List<String>> getTargetList() async {
    try {
      return await _apiService.getTargetList();
    } catch (e) {
      print('Error getting target list: $e');
      return [];
    }
  }

  Future<void> saveExercise(String exerciseId) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to save exercises');
    }

    try {
      await _dbService.saveExerciseToUser(_currentUserId!, exerciseId);
    } catch (e) {
      print('Error saving exercise: $e');
      rethrow;
    }
  }

  Future<void> removeSavedExercise(String exerciseId) async {
    if (_currentUserId == null) return;

    try {
      await _dbService.removeSavedExercise(_currentUserId!, exerciseId);
    } catch (e) {
      print('Error removing saved exercise: $e');
    }
  }

  Future<void> updatePersonalBest(
    String exerciseId,
    double weight,
    int reps,
  ) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update personal best');
    }

    try {
      await _dbService.updatePersonalBest(
        _currentUserId!,
        exerciseId,
        weight,
        reps,
      );
    } catch (e) {
      print('Error updating personal best: $e');
      rethrow;
    }
  }

  Future<List<String>> getSavedExerciseIds() async {
    if (_currentUserId == null) return [];

    try {
      return await _dbService.getUserSavedExerciseIds(_currentUserId!);
    } catch (e) {
      print('Error getting saved exercises: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSavedExercises() async {
    if (_currentUserId == null) return [];

    try {
      final exerciseIds = await getSavedExerciseIds();
      final exercises = <Map<String, dynamic>>[];

      for (final id in exerciseIds) {
        final exercise = await getExerciseById(id);
        if (exercise != null) {
          exercises.add(exercise);
        }
      }

      return exercises;
    } catch (e) {
      print('Error getting saved exercises: $e');
      return [];
    }
  }
}
