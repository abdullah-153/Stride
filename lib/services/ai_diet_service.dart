import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/diet_plan_model.dart';
import '../utils/secrets.dart';

class AIDietService {
  static const List<String> _apiKeys = ApiSecrets.geminiApiKeys;

  GenerativeModel _getModel(String apiKey) {
    return GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  AIDietService();

  Future<DietPlan> generateDietPlan({
    required int currentWeight,
    required int targetWeight,
    required int height,
    required int age,
    required String gender,
    required String goal,
    required String activityLevel,
    required String region,
    required List<String> dietaryRestrictions,
    required List<String> allergies,
    required int mealsPerDay,
  }) async {
    final prompt =
        """
      Generate a detailed 7-day diet plan json based on the following user profile:
      - Current Weight: ${currentWeight}kg
      - Target Weight: ${targetWeight}kg
      - Height: ${height}cm
      - Age: $age
      - Gender: $gender
      - Goal: $goal
      - Activity Level: $activityLevel
      - Preferred Region/Cuisine: $region
      - Dietary Restrictions: ${dietaryRestrictions.join(', ')}
      - Allergies: ${allergies.join(', ')}
      - Meals per day: $mealsPerDay

      The output MUST be a valid JSON object matching this structure:
      {
        "tdee": 2500.0,
        "dailyCalories": 2200,
        "macros": { "protein": 180, "carbs": 200, "fats": 70 },
        "waterIntakeLiters": 3.5,
        "dietType": "High Protein Asian Balanced",
        "region": "$region",
        "weeklyPlan": [
          {
            "day": "Monday",
            "meals": [
              {
                "type": "Breakfast",
                "name": "Meal Name",
                "description": "Brief description of ingredients",
                "calories": 500,
                "macros": { "protein": 30, "carbs": 40, "fats": 15 },
                "instructions": "Brief cooking prep"
              }
              ... (repeat for $mealsPerDay meals)
            ]
          }
          ... (repeat for 7 days)
        ]
      }
      
      Ensure the plan is practical, uses accessible ingredients for the specified region for regions like Pakistan, give commonly used and available meals, and strictly adheres to allergies and restrictions.
    """;

    final content = [Content.text(prompt)];

    int currentKeyIndex =
        DateTime.now().millisecondsSinceEpoch % _apiKeys.length;

    for (int i = 0; i < _apiKeys.length; i++) {
      final apiKey = _apiKeys[(currentKeyIndex + i) % _apiKeys.length];
      try {
        final model = _getModel(apiKey);
        if (kDebugMode) {
          print(
            "Generating diet plan with key ending in ...${apiKey.substring(apiKey.length - 6)}",
          );
        }

        final response = await model.generateContent(content);

        if (response.text == null) {
          throw Exception('AI returned empty response');
        }

        String cleanJson = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);

        return DietPlan.fromJson(jsonMap);
      } catch (e) {
        if (kDebugMode) {
          print(
            'AI Diet Generation Error with key ...${apiKey.substring(apiKey.length - 6)}: $e',
          );
        }

        if (i == _apiKeys.length - 1) {
          print('All API keys failed for diet generation.');
          rethrow;
        }
        print('Switching to next API key...');
        continue;
      }
    }
    throw Exception('Failed to generate diet plan after trying all API keys');
  }
}
