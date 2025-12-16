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

  /// Get exercises with caching
  Future<List<Map<String, dynamic>>> getExercises({int limit = 10, int offset = 0}) async {
    try {
      final exercises = await _apiService.getAllExercises(limit: limit, offset: offset);
      
      // Cache exercises
      for (final exercise in exercises) {
        await _dbService.cacheExercise(exercise);
      }

      return exercises;
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  /// Get exercise by ID (checks cache first)
  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    try {
      // Try cache first
      final cachedExercise = await _dbService.getExerciseFromCache(id);
      if (cachedExercise != null) {
        return cachedExercise;
      }

      // Fetch from API
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

  /// Get exercises by body part
  Future<List<Map<String, dynamic>>> getExercisesByBodyPart(String bodyPart, {int limit = 10}) async {
    try {
      // Try cache first
      final cachedExercises = await _dbService.getExercisesByBodyPart(bodyPart);
      if (cachedExercises.isNotEmpty) {
        return cachedExercises;
      }

      // Fetch from API
      final apiExercises = await _apiService.getExercisesByBodyPart(bodyPart, limit: limit);
      
      // Cache exercises
      for (final exercise in apiExercises) {
        await _dbService.cacheExercise(exercise);
      }

      return apiExercises;
    } catch (e) {
      print('Error getting exercises by body part: $e');
      return [];
    }
  }

  /// Get exercises by equipment
  Future<List<Map<String, dynamic>>> getExercisesByEquipment(String equipment, {int limit = 10}) async {
    try {
      // Try cache first
      final cachedExercises = await _dbService.getExercisesByEquipment(equipment);
      if (cachedExercises.isNotEmpty) {
        return cachedExercises;
      }

      // Fetch from API
      final apiExercises = await _apiService.getExercisesByEquipment(equipment, limit: limit);
      
      // Cache exercises
      for (final exercise in apiExercises) {
        await _dbService.cacheExercise(exercise);
      }

      return apiExercises;
    } catch (e) {
      print('Error getting exercises by equipment: $e');
      return [];
    }
  }

  /// Get exercises by target muscle
  Future<List<Map<String, dynamic>>> getExercisesByTarget(String target, {int limit = 10}) async {
    try {
      final exercises = await _apiService.getExercisesByTarget(target, limit: limit);
      
      // Cache exercises
      for (final exercise in exercises) {
        await _dbService.cacheExercise(exercise);
      }

      return exercises;
    } catch (e) {
      print('Error getting exercises by target: $e');
      return [];
    }
  }

  /// Get available body parts
  Future<List<String>> getBodyPartList() async {
    try {
      return await _apiService.getBodyPartList();
    } catch (e) {
      print('Error getting body part list: $e');
      return [];
    }
  }

  /// Get available equipment types
  Future<List<String>> getEquipmentList() async {
    try {
      return await _apiService.getEquipmentList();
    } catch (e) {
      print('Error getting equipment list: $e');
      return [];
    }
  }

  /// Get available target muscles
  Future<List<String>> getTargetList() async {
    try {
      return await _apiService.getTargetList();
    } catch (e) {
      print('Error getting target list: $e');
      return [];
    }
  }

  /// Save exercise to user's favorites
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

  /// Remove exercise from user's favorites
  Future<void> removeSavedExercise(String exerciseId) async {
    if (_currentUserId == null) return;

    try {
      await _dbService.removeSavedExercise(_currentUserId!, exerciseId);
    } catch (e) {
      print('Error removing saved exercise: $e');
    }
  }

  /// Update personal best for an exercise
  Future<void> updatePersonalBest(String exerciseId, double weight, int reps) async {
    if (_currentUserId == null) {
      throw Exception('User must be authenticated to update personal best');
    }

    try {
      await _dbService.updatePersonalBest(_currentUserId!, exerciseId, weight, reps);
    } catch (e) {
      print('Error updating personal best: $e');
      rethrow;
    }
  }

  /// Get user's saved exercise IDs
  Future<List<String>> getSavedExerciseIds() async {
    if (_currentUserId == null) return [];

    try {
      return await _dbService.getUserSavedExerciseIds(_currentUserId!);
    } catch (e) {
      print('Error getting saved exercises: $e');
      return [];
    }
  }

  /// Get user's saved exercises with full details
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
