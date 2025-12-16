import 'package:flutter/material.dart';
import '../models/workout_model.dart';

class WorkoutColors {
  static const Map<WorkoutCategory, List<Color>> categoryGradients = {
    WorkoutCategory.all: [Color(0xFF667EEA), Color(0xFF764BA2)],
    WorkoutCategory.cardio: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    WorkoutCategory.strength: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
    WorkoutCategory.yoga: [Color(0xFF11998E), Color(0xFF38EF7D)],
    WorkoutCategory.hiit: [Color(0xFFFF6A00), Color(0xFFFFD600)],
    WorkoutCategory.flexibility: [Color(0xFFEC008C), Color(0xFFFC6767)],
    WorkoutCategory.sports: [Color(0xFF0575E6), Color(0xFF021B79)],
  };

  static const Map<WorkoutCategory, Color> categorySolidColors = {
    WorkoutCategory.all: Color(0xFF667EEA),
    WorkoutCategory.cardio: Color(0xFFFF6B6B),
    WorkoutCategory.strength: Color(0xFF4E54C8),
    WorkoutCategory.yoga: Color(0xFF11998E),
    WorkoutCategory.hiit: Color(0xFFFF6A00),
    WorkoutCategory.flexibility: Color(0xFFEC008C),
    WorkoutCategory.sports: Color(0xFF0575E6),
  };

  static Color getCategoryColor(
    WorkoutCategory category, {
    bool isDark = false,
  }) {
    final color =
        categorySolidColors[category] ??
        categorySolidColors[WorkoutCategory.all]!;
    if (isDark) {
      return Color.lerp(color, Colors.white, 0.2)!;
    }
    return color;
  }

  static List<Color> getCategoryGradient(
    WorkoutCategory category, {
    bool isDark = false,
  }) {
    final gradient =
        categoryGradients[category] ?? categoryGradients[WorkoutCategory.all]!;
    if (isDark) {
      return gradient.map((c) => Color.lerp(c, Colors.white, 0.15)!).toList();
    }
    return gradient;
  }

  static LinearGradient getCategoryLinearGradient(
    WorkoutCategory category, {
    bool isDark = false,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    final colors = getCategoryGradient(category, isDark: isDark);
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  static Color getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return const Color(0xFF4CAF50); // Green
      case DifficultyLevel.intermediate:
        return const Color(0xFFFF9800); // Orange
      case DifficultyLevel.advanced:
        return const Color(0xFFF44336); // Red
    }
  }

  static Color getMuscleGroupColor(String muscleGroup) {
    final hash = muscleGroup.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  static const Color accent = Color.fromRGBO(206, 242, 75, 1);
  static const Color accentDark = Color.fromRGBO(206, 235, 75, 0.8);

  static Color getAccent({bool isDark = false}) {
    return isDark ? accentDark : accent;
  }
}
