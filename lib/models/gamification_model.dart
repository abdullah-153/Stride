enum StreakType { diet, workout }

class UserStats {
  final int currentXp;
  final int currentLevel;
  final int currentStreak; // Global streak
  final int longestStreak;
  final DateTime? lastLogDate; // Global last log

  // Specific streaks
  final int dietStreak;
  final int workoutStreak;
  final DateTime? lastDietLogDate;
  final DateTime? lastWorkoutLogDate;

  UserStats({
    required this.currentXp,
    required this.currentLevel,
    required this.currentStreak,
    required this.longestStreak,
    this.lastLogDate,
    this.dietStreak = 0,
    this.workoutStreak = 0,
    this.lastDietLogDate,
    this.lastWorkoutLogDate,
  });

  factory UserStats.initial() {
    return UserStats(
      currentXp: 0,
      currentLevel: 1,
      currentStreak: 0,
      longestStreak: 0,
      dietStreak: 0,
      workoutStreak: 0,
    );
  }

  UserStats copyWith({
    int? currentXp,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLogDate,
    int? dietStreak,
    int? workoutStreak,
    DateTime? lastDietLogDate,
    DateTime? lastWorkoutLogDate,
  }) {
    return UserStats(
      currentXp: currentXp ?? this.currentXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLogDate: lastLogDate ?? this.lastLogDate,
      dietStreak: dietStreak ?? this.dietStreak,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      lastDietLogDate: lastDietLogDate ?? this.lastDietLogDate,
      lastWorkoutLogDate: lastWorkoutLogDate ?? this.lastWorkoutLogDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentXp': currentXp,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastLogDate': lastLogDate?.toIso8601String(),
      'dietStreak': dietStreak,
      'workoutStreak': workoutStreak,
      'lastDietLogDate': lastDietLogDate?.toIso8601String(),
      'lastWorkoutLogDate': lastWorkoutLogDate?.toIso8601String(),
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentXp: json['currentXp'] as int,
      currentLevel: json['currentLevel'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastLogDate: json['lastLogDate'] != null
          ? DateTime.parse(json['lastLogDate'] as String)
          : null,
      dietStreak: json['dietStreak'] as int? ?? 0,
      workoutStreak: json['workoutStreak'] as int? ?? 0,
      lastDietLogDate: json['lastDietLogDate'] != null
          ? DateTime.parse(json['lastDietLogDate'] as String)
          : null,
      lastWorkoutLogDate: json['lastWorkoutLogDate'] != null
          ? DateTime.parse(json['lastWorkoutLogDate'] as String)
          : null,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset; // Or use IconData code point if preferred
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      iconAsset: iconAsset,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconAsset: json['iconAsset'] as String,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class GamificationData {
  final UserStats stats;
  final List<Achievement> achievements;

  GamificationData({required this.stats, required this.achievements});

  GamificationData copyWith({
    UserStats? stats,
    List<Achievement>? achievements,
  }) {
    return GamificationData(
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
    );
  }
}
