import 'dart:convert';
import 'package:http/http.dart' as http;

class TheMealDBService {
  static final TheMealDBService _instance = TheMealDBService._internal();
  factory TheMealDBService() => _instance;
  TheMealDBService._internal();

  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Map<String, dynamic>>> searchMealsByName(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null) return [];

        return meals
            .map((meal) => _parseMeal(meal as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to search meals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching meals: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRandomMeal() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null || meals.isEmpty) return null;

        return _parseMeal(meals[0] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get random meal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting random meal: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMealById(String id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/lookup.php?i=$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null || meals.isEmpty) return null;

        return _parseMeal(meals[0] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get meal: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting meal by ID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMealsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;

        if (meals == null) return [];

        return meals
            .map(
              (meal) => {
                'id': meal['idMeal'],
                'name': meal['strMeal'],
                'imageUrl': meal['strMealThumb'],
              },
            )
            .toList();
      } else {
        throw Exception(
          'Failed to get meals by category: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting meals by category: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final categories = data['categories'] as List?;

        if (categories == null) return [];

        return categories.map((cat) => cat['strCategory'] as String).toList();
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  Map<String, dynamic> _parseMeal(Map<String, dynamic> meal) {
    final ingredients = <Map<String, String>>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];

      if (ingredient != null && ingredient.toString().isNotEmpty) {
        ingredients.add({
          'name': ingredient.toString(),
          'measure': measure?.toString() ?? '',
        });
      }
    }

    return {
      'id': meal['idMeal'],
      'name': meal['strMeal'],
      'category': meal['strCategory'] ?? '',
      'area': meal['strArea'] ?? '',
      'instructions': meal['strInstructions'] ?? '',
      'imageUrl': meal['strMealThumb'] ?? '',
      'videoUrl': meal['strYoutube'] ?? '',
      'ingredients': ingredients,
      'tags': (meal['strTags'] as String?)?.split(',') ?? [],
      'source': 'themealdb',
    };
  }
}
