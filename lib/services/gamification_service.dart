import 'dart:async';
import '../models/gamification_model.dart';

/// Service for managing gamification features.
///
/// Handles XP tracking, level progression, streaks (diet, workout, and global),
/// and achievement unlocking. Provides a broadcast stream for real-time updates.
/// Uses singleton pattern to ensure single instance across the app.
///
/// **Streak Logic:**
/// - Diet/Workout streaks: Track consecutive days of logging
/// - Global streak: Requires BOTH diet AND workout logged on the same day
/// - Streaks reset if a day is missed
///
/// **Level System:**
/// - Level N requires N * 100 XP to advance to Level N+1
/// - Example: Level 1→2 needs 100 XP, Level 2→3 needs 200 XP
class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal() {
    _initializeData();
  }

  late GamificationData _data;
  final _controller = StreamController<GamificationData>.broadcast();
  Stream<GamificationData> get gamificationStream => _controller.stream;

  // XP Thresholds: Level N requires N * 100 XP (simplified)
  // Level 1 -> 2: 100 XP
  // Level 2 -> 3: 200 XP
  // etc.
  int getXpForNextLevel(int currentLevel) => currentLevel * 100;

  void _initializeData() {
    // Initialize with default/mock data
    _data = GamificationData(
      stats: UserStats.initial(),
      achievements: _getDefaultAchievements(),
    );
    _controller.add(_data);
  }

  void reset() {
    _initializeData();
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_meal',
        title: 'First Bite',
        description: 'Log your first meal',
        iconAsset: 'assets/icons/apple.png', // Placeholder
      ),
      Achievement(
        id: 'hydration_hero',
        title: 'Hydration Hero',
        description: 'Reach your daily water goal',
        iconAsset: 'assets/icons/water_drop.png',
      ),
      Achievement(
        id: 'streak_3',
        title: 'Consistency is Key',
        description: 'Reach a 3-day streak',
        iconAsset: 'assets/icons/fire.png',
      ),
      Achievement(
        id: 'protein_pro',
        title: 'Protein Pro',
        description: 'Hit your protein goal for the day',
        iconAsset: 'assets/icons/muscle.png',
      ),
    ];
  }

  GamificationData getCurrentData() => _data;

  void addXp(int amount) {
    final currentStats = _data.stats;
    int newXp = currentStats.currentXp + amount;
    int newLevel = currentStats.currentLevel;

    // Check for level up
    int xpRequired = getXpForNextLevel(newLevel);
    while (newXp >= xpRequired) {
      newXp -= xpRequired;
      newLevel++;
      xpRequired = getXpForNextLevel(newLevel);
      // TODO: Notify level up event
    }

    _updateStats(
      currentStats.copyWith(currentXp: newXp, currentLevel: newLevel),
    );
  }

  void checkStreak(StreakType type, DateTime logDate) {
    final currentStats = _data.stats;

    // 1. Update Specific Streak (Diet or Workout)
    UserStats updatedStats = _updateSpecificStreak(currentStats, type, logDate);

    // 2. Update Global Streak (Any activity counts)
    updatedStats = _updateGlobalStreak(updatedStats, logDate);

    _updateStats(updatedStats);
  }

  UserStats _updateSpecificStreak(
    UserStats stats,
    StreakType type,
    DateTime logDate,
  ) {
    final lastDate = type == StreakType.diet
        ? stats.lastDietLogDate
        : stats.lastWorkoutLogDate;
    final currentStreak = type == StreakType.diet
        ? stats.dietStreak
        : stats.workoutStreak;

    if (lastDate == null) {
      return type == StreakType.diet
          ? stats.copyWith(dietStreak: 1, lastDietLogDate: logDate)
          : stats.copyWith(workoutStreak: 1, lastWorkoutLogDate: logDate);
    }

    if (_isSameDay(lastDate, logDate)) return stats; // Already logged today

    final isYesterday = _isSameDay(
      lastDate,
      logDate.subtract(const Duration(days: 1)),
    );
    final newStreak = isYesterday ? currentStreak + 1 : 1;

    return type == StreakType.diet
        ? stats.copyWith(dietStreak: newStreak, lastDietLogDate: logDate)
        : stats.copyWith(workoutStreak: newStreak, lastWorkoutLogDate: logDate);
  }

  UserStats _updateGlobalStreak(UserStats stats, DateTime logDate) {
    // Strict Mode: Global Streak only updates if BOTH Diet and Workout are done today
    final dietDoneToday =
        stats.lastDietLogDate != null &&
        _isSameDay(stats.lastDietLogDate!, logDate);
    final workoutDoneToday =
        stats.lastWorkoutLogDate != null &&
        _isSameDay(stats.lastWorkoutLogDate!, logDate);

    if (!dietDoneToday || !workoutDoneToday) {
      return stats; // Not eligible for global streak update yet
    }

    final lastDate = stats.lastLogDate;

    if (lastDate == null) {
      _unlockIfFirstMeal(stats);
      return stats.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastLogDate: logDate,
      );
    }

    if (_isSameDay(lastDate, logDate)) {
      return stats; // Already logged global streak today
    }

    final isYesterday = _isSameDay(
      lastDate,
      logDate.subtract(const Duration(days: 1)),
    );
    final newStreak = isYesterday ? stats.currentStreak + 1 : 1;
    final newLongest = newStreak > stats.longestStreak
        ? newStreak
        : stats.longestStreak;

    if (newStreak >= 3) {
      unlockAchievement('streak_3');
    }

    return stats.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastLogDate: logDate,
    );
  }

  void _unlockIfFirstMeal(UserStats stats) {
    // Logic moved here or handled by specific achievement check
    unlockAchievement('first_meal');
  }

  void unlockAchievement(String achievementId) {
    final index = _data.achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_data.achievements[index].isUnlocked) {
      final updatedAchievements = List<Achievement>.from(_data.achievements);
      updatedAchievements[index] = updatedAchievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      _data = _data.copyWith(achievements: updatedAchievements);
      _controller.add(_data);
    }
  }

  void _updateStats(UserStats newStats) {
    _data = _data.copyWith(stats: newStats);
    _controller.add(_data);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if both diet and workout activities were completed today
  /// Returns true only if BOTH streaks have been logged on the same day (today)
  bool areBothStreaksCompletedToday() {
    final stats = _data.stats;
    final now = DateTime.now();
    
    final dietDoneToday = stats.lastDietLogDate != null &&
        _isSameDay(stats.lastDietLogDate!, now);
    final workoutDoneToday = stats.lastWorkoutLogDate != null &&
        _isSameDay(stats.lastWorkoutLogDate!, now);
    
    return dietDoneToday && workoutDoneToday;
  }
}
