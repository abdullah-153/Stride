import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIWorkoutService {
  static const List<String> _apiKeys = [
    'AIzaSyDCBjX5WeMdX-ZlW_Ap9JV0H0tQx8JiTJ0', // Current key
    'AIzaSyAL54y5K_etp88QxrTM56BJt5_lQsG_CUA',
    'AIzaSyAvHrGeUdRR0Qq6HXFf2MQriGbbgUfsA98',
    'AIzaSyALUEk3_qkW4bMtDKPLbYdAlZ0pQ1UZRrU',
    'AIzaSyDxO-t2YxQTQKETJe6xd7-k5ZtOWoOz69c',
    'AIzaSyBNgDhqR-SkhTvwwmuC3ZmfvWOx8p5rTPo',
  ];

  GenerativeModel _getModel(String apiKey) {
    return GenerativeModel(
      model: 'gemini-2.5-flash-lite', // Changed model as per instruction
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  AIWorkoutService(); // Empty constructor as model is now created dynamically

  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String goal,
    required int daysPerWeek,
    required List<String> targetMuscles,
    required String fitnessLevel,
    required List<String> equipment,
  }) async {
    final equipmentDesc = equipment.isEmpty
        ? 'Full gym access'
        : equipment.join(', ');
    final prompt =
        '''
      Act as an elite fitness coach. Create a customized $daysPerWeek-day workout split for a $fitnessLevel level user.
      
      User Profile:
      - Goal: $goal
      - Target Muscles: ${targetMuscles.join(', ')} (CRITICAL: The workout MUST primarily focus on these. If "Triceps" is selected, 70% of exercises must be triceps focused. Do not give a generic full body workout if a specific muscle is targeted.)
      - Equipment Available: $equipmentDesc
      
      CRITICAL Equipment Constraints:
      ${equipment.contains('bodyweight') && equipment.length == 1 ? '- User has NO equipment. Use ONLY bodyweight exercises.' : ''}
      ${equipment.contains('dumbbells') ? '- User has basic equipment (dumbbells, resistance bands).' : ''}
      ${equipment.contains('full gym access') ? '- User has full gym access.' : ''}
      
      Requirements:
      1. Create a logical split (e.g., Push/Pull/Legs, Upper/Lower, or Bro Split) fitting the days available.
      2. If days > muscles, use smart grouping. If muscles > days, combine them effectively.
      3. For REST days, simply omit them from the list or label them if necessary, but preferred to just show workout days.
      4. Include "estimatedMinutes" for each day (realistic workout duration including warm-up and rest).
      5. Include "estimatedMinutes" for EACH exercise (time to complete all sets including rest).
      6. Return strictly valid JSON matching this structure:
      
      {
        "name": "Creative Plan Name (e.g., '5-Day Power Builder')",
        "description": "Brief professional description of the strategy.",
        "weeklyPlan": [
          {
            "day": 1,
            "name": "Day 1: Focus Area",
            "targetMuscles": ["chest", "triceps"],
            "estimatedMinutes": 45,
            "exercises": [
              {
                "name": "Exercise Name",
                "sets": 3,
                "reps": "8-12",
                "restSeconds": 60,
                "estimatedMinutes": 5,
                "targetMuscle": "chest",
                "equipment": "barbell"
              }
            ]
          }
        ]
      }
      
      Ensure the exercises are real and effective. Adjust volume (sets/reps) based on the '$goal' (e.g. Strength = lower reps, Muscle Gain = 8-12 reps).
      VERIFY equipment constraints are followed strictly.
    ''';

    final content = [Content.text(prompt)];

    int currentKeyIndex =
        DateTime.now().millisecondsSinceEpoch %
        _apiKeys.length; // Start with a random key to distribute load

    for (int i = 0; i < _apiKeys.length; i++) {
      final apiKey = _apiKeys[(currentKeyIndex + i) % _apiKeys.length];
      try {
        final model = _getModel(apiKey);
        final response = await model.generateContent(content);

        if (response.text == null) {
          throw Exception('AI returned empty response');
        }

        print("AI Response ($apiKey): ${response.text}");

        String cleanJson = response.text!
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        return jsonDecode(cleanJson);
      } catch (e) {
        if (kDebugMode) {
          print(
            'AI Generation Error with key ${apiKey.substring(0, 5)}...: $e',
          );
        }
        if (i == _apiKeys.length - 1) {
          print('All API keys failed.');
          rethrow;
        }
        print('Switching to next API key...');
        continue;
      }
    }
    throw Exception(
      'Failed to generate workout plan after trying all API keys',
    );
  }
}
