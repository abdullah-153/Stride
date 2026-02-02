import '../../utils/secrets.dart';

class USDAApiService {
  static final USDAApiService _instance = USDAApiService._internal();
  factory USDAApiService() => _instance;
  USDAApiService._internal();

  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = ApiSecrets.usdaApiKey;

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/foods/search?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&pageSize=50',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final foods = data['foods'] as List?;

        if (foods == null || foods.isEmpty) return [];

        final parsedFoods = foods
            .map((food) => _parseFood(food as Map<String, dynamic>))
            .where((food) {
              final hasName = (food['name'] as String?)?.isNotEmpty ?? false;
              final calories = (food['calories'] as num?) ?? -1;
              final protein = (food['protein'] as num?) ?? -1;
              final carbs = (food['carbs'] as num?) ?? -1;
              final fats = (food['fats'] as num?) ?? -1;

              final hasMacros =
                  calories >= 0 &&
                  (calories > 0 || protein > 0 || carbs > 0 || fats > 0);
              return hasName && hasMacros;
            })
            .toList();

        parsedFoods.sort((a, b) {
          final aBranded = (a['brandOwner'] as String).isNotEmpty;
          final bBranded = (b['brandOwner'] as String).isNotEmpty;
          if (aBranded && !bBranded) return -1;
          if (!aBranded && bBranded) return 1;

          final aComplete =
              (a['calories'] as int) +
              (a['protein'] as int) +
              (a['carbs'] as int) +
              (a['fats'] as int);
          final bComplete =
              (b['calories'] as int) +
              (b['protein'] as int) +
              (b['carbs'] as int) +
              (b['fats'] as int);
          return bComplete.compareTo(aComplete);
        });

        return parsedFoods.take(25).toList();
      } else {
        print('USDA API error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error searching USDA foods: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFoodById(String fdcId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/$fdcId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return _parseFood(data);
      } else {
        print('USDA API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting USDA food by ID: $e');
      return null;
    }
  }

  Map<String, dynamic> _parseFood(Map<String, dynamic> food) {
    final nutrients = food['foodNutrients'] as List? ?? [];

    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;

    for (final nutrient in nutrients) {
      final nutrientNumber = nutrient['nutrientNumber']?.toString() ?? '';
      final value = (nutrient['value'] ?? 0).toDouble();

      switch (nutrientNumber) {
        case '208':
          calories = value;
          break;
        case '203':
          protein = value;
          break;
        case '205':
          carbs = value;
          break;
        case '204':
          fats = value;
          break;
      }
    }

    final servingSize = food['servingSize']?.toDouble() ?? 100.0;
    final servingSizeUnit = food['servingSizeUnit']?.toString() ?? 'g';

    return {
      'id': food['fdcId']?.toString() ?? '',
      'name': food['description'] ?? 'Unknown Food',
      'calories': calories.round(),
      'protein': protein.round(),
      'carbs': carbs.round(),
      'fats': fats.round(),
      'servingSize': servingSize,
      'servingSizeUnit': servingSizeUnit,
      'brandOwner': food['brandOwner'] ?? '',
      'dataType': food['dataType'] ?? '',
      'source': 'usda',
    };
  }
}
