class NutritionGoal {
  final int dailyCalories;
  final int protein;
  final int carbs;
  final int fats;
  final int waterGoal;

  NutritionGoal({
    required this.dailyCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.waterGoal,
  });

  factory NutritionGoal.fromJson(Map<String, dynamic> json) {
    return NutritionGoal(
      dailyCalories: json['dailyCalories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fats: json['fats'] as int,
      waterGoal: json['waterGoal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyCalories': dailyCalories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'waterGoal': waterGoal,
    };
  }
}

class MacroNutrients {
  final int protein;
  final int carbs;
  final int fats;

  MacroNutrients({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  int get totalCalories => (protein * 4) + (carbs * 4) + (fats * 9);

  factory MacroNutrients.fromJson(Map<String, dynamic> json) {
    return MacroNutrients(
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fats: json['fats'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'protein': protein, 'carbs': carbs, 'fats': fats};
  }

  MacroNutrients operator +(MacroNutrients other) {
    return MacroNutrients(
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fats: fats + other.fats,
    );
  }
}

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class Meal {
  final String id;
  final String name;
  final MealType type;
  final int calories;
  final MacroNutrients macros;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isFavorite;

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.macros,
    required this.timestamp,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MealType.values.firstWhere(
        (e) => e.toString() == 'MealType.${json['type']}',
      ),
      calories: json['calories'] as int,
      macros: MacroNutrients.fromJson(json['macros'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'calories': calories,
      'macros': macros.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  Meal copyWith({
    String? id,
    String? name,
    MealType? type,
    int? calories,
    MacroNutrients? macros,
    DateTime? timestamp,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      calories: calories ?? this.calories,
      macros: macros ?? this.macros,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class DailyNutrition {
  final DateTime date;
  final List<Meal> meals;
  final int waterIntake;
  final NutritionGoal goal;

  DailyNutrition({
    required this.date,
    required this.meals,
    required this.waterIntake,
    required this.goal,
  });

  int get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);

  MacroNutrients get totalMacros {
    if (meals.isEmpty) {
      return MacroNutrients(protein: 0, carbs: 0, fats: 0);
    }
    return meals.map((m) => m.macros).reduce((a, b) => a + b);
  }

  bool get calorieGoalMet {
    final diff = (totalCalories - goal.dailyCalories).abs();
    return diff <= (goal.dailyCalories * 0.1);
  }

  bool get waterGoalMet => waterIntake >= goal.waterGoal;

  bool get proteinGoalMet {
    final diff = (totalMacros.protein - goal.protein).abs();
    return diff <= (goal.protein * 0.1);
  }

  bool get carbsGoalMet {
    final diff = (totalMacros.carbs - goal.carbs).abs();
    return diff <= (goal.carbs * 0.1);
  }

  bool get fatsGoalMet {
    final diff = (totalMacros.fats - goal.fats).abs();
    return diff <= (goal.fats * 0.1);
  }

  bool get allGoalsMet =>
      calorieGoalMet &&
      waterGoalMet &&
      proteinGoalMet &&
      carbsGoalMet &&
      fatsGoalMet;

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List)
          .map((m) => Meal.fromJson(m as Map<String, dynamic>))
          .toList(),
      waterIntake: json['waterIntake'] as int,
      goal: NutritionGoal.fromJson(json['goal'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'waterIntake': waterIntake,
      'goal': goal.toJson(),
    };
  }
}
