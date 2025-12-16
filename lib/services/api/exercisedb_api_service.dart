import 'dart:convert';
import 'package:http/http.dart' as http;

class ExerciseDBService {
  static final ExerciseDBService _instance = ExerciseDBService._internal();
  factory ExerciseDBService() => _instance;
  ExerciseDBService._internal();

  static const String _baseUrl = 'https://exercisedb.p.rapidapi.com';

  static const String _apiKey =
      '062805dc92mshc3188d9b8cb9782p135bcajsn79aaa48cb366';
  static const String _apiHost = 'exercisedb.p.rapidapi.com';

  Map<String, String> get _headers => {
    'X-RapidAPI-Key': _apiKey,
    'X-RapidAPI-Host': _apiHost,
  };

  Future<List<Map<String, dynamic>>> getAllExercises({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises?limit=$limit&offset=$offset'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((exercise) => _parseExercise(exercise as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getExerciseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/exercise/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseExercise(data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get exercise: ${response.statusCode}');
      }
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
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPart/$bodyPart?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((exercise) => _parseExercise(exercise as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to get exercises by body part: ${response.statusCode}',
        );
      }
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
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/equipment/$equipment?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((exercise) => _parseExercise(exercise as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to get exercises by equipment: ${response.statusCode}',
        );
      }
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
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/target/$target?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data
            .map((exercise) => _parseExercise(exercise as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to get exercises by target: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting exercises by target: $e');
      return [];
    }
  }

  Future<List<String>> getBodyPartList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/bodyPartList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to get body part list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting body part list: $e');
      return [];
    }
  }

  Future<List<String>> getEquipmentList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/equipmentList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to get equipment list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting equipment list: $e');
      return [];
    }
  }

  Future<List<String>> getTargetList() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/exercises/targetList'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to get target list: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting target list: $e');
      return [];
    }
  }

  Map<String, dynamic> _parseExercise(Map<String, dynamic> exercise) {
    return {
      'id': exercise['id'],
      'name': exercise['name'],
      'bodyPart': exercise['bodyPart'],
      'equipment': exercise['equipment'],
      'targetMuscle': exercise['target'],
      'secondaryMuscles': exercise['secondaryMuscles'] ?? [],
      'instructions': exercise['instructions'] ?? [],
      'gifUrl': exercise['gifUrl'] ?? '',
      'source': 'exercisedb',
    };
  }
}
