enum WorkoutCategory { all, cardio, strength, yoga, hiit, flexibility, sports }

extension WorkoutCategoryExtension on WorkoutCategory {
  String get displayName {
    switch (this) {
      case WorkoutCategory.all:
        return 'All';
      case WorkoutCategory.cardio:
        return 'Cardio';
      case WorkoutCategory.strength:
        return 'Strength';
      case WorkoutCategory.yoga:
        return 'Yoga';
      case WorkoutCategory.hiit:
        return 'HIIT';
      case WorkoutCategory.flexibility:
        return 'Flexibility';
      case WorkoutCategory.sports:
        return 'Sports';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutCategory.all:
        return '🏃';
      case WorkoutCategory.cardio:
        return '❤️';
      case WorkoutCategory.strength:
        return '💪';
      case WorkoutCategory.yoga:
        return '🧘';
      case WorkoutCategory.hiit:
        return '⚡';
      case WorkoutCategory.flexibility:
        return '🤸';
      case WorkoutCategory.sports:
        return '⚽';
    }
  }
}

enum DifficultyLevel { beginner, intermediate, advanced }

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }
}

class Exercise {
  final String name;
  final int? reps;
  final int? sets;
  final int? durationSeconds;
  final String? notes;
  final List<String> muscleGroups;

  Exercise({
    required this.name,
    this.reps,
    this.sets,
    this.durationSeconds,
    this.notes,
    this.muscleGroups = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      reps: json['reps'] as int?,
      sets: json['sets'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      notes: json['notes'] as String?,
      muscleGroups:
          (json['muscleGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reps': reps,
      'sets': sets,
      'durationSeconds': durationSeconds,
      'notes': notes,
      'muscleGroups': muscleGroups,
    };
  }

  String get displayText {
    if (sets != null && reps != null) {
      return '$sets sets × $reps reps';
    } else if (sets != null && durationSeconds != null) {
      return '$sets sets × ${durationSeconds}s';
    } else if (durationSeconds != null) {
      return '${durationSeconds}s';
    } else if (reps != null) {
      return '$reps reps';
    }
    return '';
  }
}

class Workout {
  final String id;
  final String title;
  final WorkoutCategory category;
  final int durationMinutes;
  final int caloriesBurned;
  final int points;
  final DifficultyLevel difficulty;
  final List<Exercise> exercises;
  final String description;
  final bool isRecommended;

  Workout({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.points,
    required this.difficulty,
    required this.exercises,
    required this.description,
    this.isRecommended = false,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      title: json['title'] as String,
      category: WorkoutCategory.values.firstWhere(
        (e) => e.toString() == 'WorkoutCategory.${json['category']}',
        orElse: () => WorkoutCategory.cardio,
      ),
      durationMinutes: json['durationMinutes'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      points: json['points'] as int,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == 'DifficultyLevel.${json['difficulty']}',
        orElse: () => DifficultyLevel.beginner,
      ),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String,
      isRecommended: json['isRecommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.toString().split('.').last,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'points': points,
      'difficulty': difficulty.toString().split('.').last,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'description': description,
      'isRecommended': isRecommended,
    };
  }

  int get exerciseCount => exercises.length;

  // Compatibility getters
  String get time => "$durationMinutes min";
  int get kcal => caloriesBurned;
}
