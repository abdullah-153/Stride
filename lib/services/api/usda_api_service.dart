import 'dart:convert';
import 'package:http/http.dart' as http;

class USDAApiService {
  static final USDAApiService _instance = USDAApiService._internal();
  factory USDAApiService() => _instance;
  USDAApiService._internal();

  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = 'g3uMZHhZ3o9TnJuB0fnPahNroIWoiv6YzrGkdSxo';

  /// Search for foods by name
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/foods/search?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&pageSize=50'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List?;
        
        if (foods == null || foods.isEmpty) return [];
        
        // Parse all foods
        final parsedFoods = foods
            .map((food) => _parseFood(food as Map<String, dynamic>))
            .where((food) {
               // Strict filter: Must have a name AND at least some nutritional value
               final hasName = (food['name'] as String?)?.isNotEmpty ?? false;
               final calories = (food['calories'] as num?) ?? -1; 
               final protein = (food['protein'] as num?) ?? -1;
               final carbs = (food['carbs'] as num?) ?? -1;
               final fats = (food['fats'] as num?) ?? -1;
               
               // User asked to stricten criteria to ensure results have macros
               final hasMacros = calories >= 0 && (calories > 0 || protein > 0 || carbs > 0 || fats > 0);
               return hasName && hasMacros;
            })
            .toList();

        // Sort by relevance: prioritize branded foods and those with complete data
        parsedFoods.sort((a, b) {
          // Prioritize foods with brand names (more specific)
          final aBranded = (a['brandOwner'] as String).isNotEmpty;
          final bBranded = (b['brandOwner'] as String).isNotEmpty;
          if (aBranded && !bBranded) return -1;
          if (!aBranded && bBranded) return 1;
          
          // Then prioritize by completeness of nutrition data
          final aComplete = (a['calories'] as int) + (a['protein'] as int) + (a['carbs'] as int) + (a['fats'] as int);
          final bComplete = (b['calories'] as int) + (b['protein'] as int) + (b['carbs'] as int) + (b['fats'] as int);
          return bComplete.compareTo(aComplete);
        });
        
        // Return top 25 results
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

  /// Get food details by FDC ID
  Future<Map<String, dynamic>?> getFoodById(String fdcId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/food/$fdcId?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
    // Extract nutrients
    final nutrients = food['foodNutrients'] as List? ?? [];
    
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;

    for (final nutrient in nutrients) {
      final nutrientNumber = nutrient['nutrientNumber']?.toString() ?? '';
      final value = (nutrient['value'] ?? 0).toDouble();

      switch (nutrientNumber) {
        case '208': // Energy (kcal)
          calories = value;
          break;
        case '203': // Protein
          protein = value;
          break;
        case '205': // Carbohydrates
          carbs = value;
          break;
        case '204': // Total lipid (fat)
          fats = value;
          break;
      }
    }

    // Get serving size info
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
