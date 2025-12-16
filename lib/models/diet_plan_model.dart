class Macros {
  final int protein;
  final int carbs;
  final int fats;

  Macros({required this.protein, required this.carbs, required this.fats});

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      protein: (json['protein'] as num).toInt(),
      carbs: (json['carbs'] as num).toInt(),
      fats: (json['fats'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'protein': protein, 'carbs': carbs, 'fats': fats};
  }
}

class MealItem {
  final String type; // Breakfast, Lunch, Dinner, Snack
  final String name;
  final String description;
  final int calories;
  final Macros macros;
  final String instructions;

  MealItem({
    required this.type,
    required this.name,
    required this.description,
    required this.calories,
    required this.macros,
    required this.instructions,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      calories: (json['calories'] as num).toInt(),
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
      instructions: json['instructions'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'calories': calories,
      'macros': macros.toJson(),
      'instructions': instructions,
    };
  }
}

class DailyMealPlan {
  final String day;
  final List<MealItem> meals;

  DailyMealPlan({required this.day, required this.meals});

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      day: json['day'] as String,
      meals: (json['meals'] as List)
          .map((e) => MealItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'meals': meals.map((e) => e.toJson()).toList()};
  }
}

class DietPlan {
  final double tdee;
  final int dailyCalories;
  final Macros macros;
  final double waterIntakeLiters;
  final String dietType; // e.g., "High Protein", "Keto"
  final String region;
  final List<DailyMealPlan> weeklyPlan;

  DietPlan({
    required this.tdee,
    required this.dailyCalories,
    required this.macros,
    required this.waterIntakeLiters,
    required this.dietType,
    required this.region,
    required this.weeklyPlan,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      tdee: (json['tdee'] as num).toDouble(),
      dailyCalories: (json['dailyCalories'] as num).toInt(),
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>),
      waterIntakeLiters: (json['waterIntakeLiters'] as num).toDouble(),
      dietType: json['dietType'] as String,
      region: json['region'] as String,
      weeklyPlan: (json['weeklyPlan'] as List)
          .map((e) => DailyMealPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tdee': tdee,
      'dailyCalories': dailyCalories,
      'macros': macros.toJson(),
      'waterIntakeLiters': waterIntakeLiters,
      'dietType': dietType,
      'region': region,
      'weeklyPlan': weeklyPlan.map((e) => e.toJson()).toList(),
    };
  }
}
