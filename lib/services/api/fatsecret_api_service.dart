import 'dart:convert';
import 'package:http/http.dart' as http;

class FatSecretApiService {
  static const String _tokenUrl = 'https://oauth.fatsecret.com/connect/token';
  static const String _autocompleteUrl =
      'https://platform.fatsecret.com/rest/food/autocomplete/v2';

  final String _clientId;
  final String _clientSecret;

  String? _accessToken;
  DateTime? _tokenExpiry;

  FatSecretApiService({required String clientId, required String clientSecret})
    : _clientId = clientId,
      _clientSecret = clientSecret;

  Future<String> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}',
        },
        body: {
          'grant_type': 'client_credentials',
          'scope': 'premier', // As per documentation
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: expiresIn - 60),
        ); // Buffer
        return _accessToken!;
      } else {
        throw Exception(
          'Failed to get access token: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('Error authenticating with FatSecret: $e');
      rethrow;
    }
  }

  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse(
          '$_autocompleteUrl?expression=${Uri.encodeComponent(query)}&format=json&max_results=10',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['suggestions'] != null &&
            data['suggestions']['suggestion'] != null) {
          final suggestionData = data['suggestions']['suggestion'];
          if (suggestionData is List) {
            return suggestionData.map((e) => e.toString()).toList();
          } else {
            return [suggestionData.toString()];
          }
        }
        return [];
      } else {
        print(
          'FatSecret Autocomplete Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('FatSecret Exception: $e');
      return [];
    }
  }

  static const String _searchUrl =
      'https://platform.fatsecret.com/rest/foods/search/v1';
  static const String _foodGetUrl =
      'https://platform.fatsecret.com/rest/food/v2';

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    if (query.isEmpty) return [];

    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse(
          '$_searchUrl?search_expression=${Uri.encodeComponent(query)}&format=json&max_results=20',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['foods'] != null && data['foods']['food'] != null) {
          final foodData = data['foods']['food'];
          final List foods = foodData is List ? foodData : [foodData];

          return foods.map((food) => _parseFoodSummary(food)).toList();
        }
        return [];
      } else {
        print(
          'FatSecret Search Error: ${response.statusCode} ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('FatSecret Exception: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFoodById(String foodId) async {
    try {
      final token = await _getAccessToken();

      final response = await http.get(
        Uri.parse('$_foodGetUrl?food_id=$foodId&format=json'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['food'] != null) {
          return _parseFoodDetails(data['food']);
        }
        return null;
      } else {
        print(
          'FatSecret Get Food Error: ${response.statusCode} ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('FatSecret Exception: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseFoodSummary(Map<String, dynamic> food) {
    final description = food['food_description'] as String? ?? '';
    final macros = _parseMacrosFromDescription(description);

    return {
      'id': food['food_id'],
      'name': food['food_name'],
      'calories': macros['calories'],
      'protein': macros['protein'],
      'carbs': macros['carbs'],
      'fats': macros['fats'],
      'servingSize': 100.0, // Default/Unknown from summary
      'servingUnit': 'g', // Default/Unknown
      'brandName': food['brand_name'] ?? '', // Sometimes present
    };
  }

  Map<String, dynamic> _parseMacrosFromDescription(String desc) {
    double getVal(String key) {
      final regex = RegExp('$key:\\s*([0-9.]+)');
      final match = regex.firstMatch(desc);
      return match != null ? double.tryParse(match.group(1)!) ?? 0.0 : 0.0;
    }

    return {
      'calories': getVal('Calories').toInt(),
      'protein': getVal('Protein'),
      'carbs': getVal('Carbs'),
      'fats': getVal('Fat'),
    };
  }

  Map<String, dynamic> _parseFoodDetails(Map<String, dynamic> food) {
    Map<String, dynamic> defaultServing = {};

    if (food['servings'] != null && food['servings']['serving'] != null) {
      final servings = food['servings']['serving'];
      final list = servings is List ? servings : [servings];
      defaultServing = list.first; // Naive: take first
    }

    return {
      'id': food['food_id'],
      'name': food['food_name'],
      'brandName': food['brand_name'] ?? '',
      'calories':
          double.tryParse(defaultServing['calories'] ?? '0')?.toInt() ?? 0,
      'protein': double.tryParse(defaultServing['protein'] ?? '0') ?? 0.0,
      'carbs': double.tryParse(defaultServing['carbohydrate'] ?? '0') ?? 0.0,
      'fats': double.tryParse(defaultServing['fat'] ?? '0') ?? 0.0,
      'servingSize':
          double.tryParse(defaultServing['metric_serving_amount'] ?? '100') ??
          100.0,
      'servingUnit': defaultServing['metric_serving_unit'] ?? 'g',
    };
  }
}
