import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/gamification_model.dart';
import 'firestore/gamification_firestore_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final GamificationFirestoreService _firestoreService =
      GamificationFirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Function(int newLevel, int xpGained)? onLevelUp;

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<GamificationData> getCurrentData() async {
    if (_currentUserId == null) {
      return GamificationData(
        stats: UserStats.initial(),
        achievements: _getDefaultAchievements(),
      );
    }

    try {
      return await _firestoreService.getGamificationData(_currentUserId!).then((
        data,
      ) {
        return _mergeWithDefaults(data);
      });
    } catch (e) {
      print('Error getting gamification data: $e');
      return GamificationData(
        stats: UserStats.initial(),
        achievements: _getDefaultAchievements(),
      );
    }
  }

  int getXpForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  Stream<GamificationData> get gamificationStream {
    if (_currentUserId == null) {
      return Stream.value(
        GamificationData(
          stats: UserStats.initial(),
          achievements: _getDefaultAchievements(),
        ),
      );
    }

    return _firestoreService.streamGamificationData(_currentUserId!).map((
      data,
    ) {
      return _mergeWithDefaults(data);
    });
  }

  GamificationData _mergeWithDefaults(GamificationData data) {
    final defaultAchievements = _getDefaultAchievements();
    final updatedAchievements = <Achievement>[];

    for (var defaultAch in defaultAchievements) {
      final existing = data.achievements.firstWhere(
        (a) => a.id == defaultAch.id,
        orElse: () => defaultAch, // Return default (locked) if not found
      );

      updatedAchievements.add(
        defaultAch.copyWith(
          isUnlocked: existing.isUnlocked,
          unlockedAt: existing.unlockedAt,
        ),
      );
    }

    return GamificationData(
      stats: data.stats,
      achievements: updatedAchievements,
    );
  }

  Future<bool> addXp(int amount) async {
    if (_currentUserId == null) return false;

    try {
      final currentData = await _firestoreService.getGamificationData(
        _currentUserId!,
      );
      final oldLevel = currentData.stats.currentLevel;

      await _firestoreService.addXp(_currentUserId!, amount);

      final newData = await _firestoreService.getGamificationData(
        _currentUserId!,
      );
      final newLevel = newData.stats.currentLevel;

      if (newLevel > oldLevel && onLevelUp != null) {
        onLevelUp!(newLevel, amount);
      }

      return newLevel > oldLevel;
    } catch (e) {
      print('Error adding XP: $e');
      return false;
    }
  }

  Future<void> checkStreak(StreakType type, DateTime logDate) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.updateStreak(_currentUserId!, type, logDate);

      final data = await _firestoreService.getGamificationData(_currentUserId!);

      if (data.stats.currentStreak >= 3) {
        await unlockAchievement('streak_3');
      }

      if (type == StreakType.diet) {
        await unlockAchievement('first_meal');
      }
    } catch (e) {
      print('Error checking streak: $e');
    }
  }

  Future<bool> isFirstOfDayForType(StreakType type) async {
    if (_currentUserId == null) return true;

    try {
      final data = await _firestoreService.getGamificationData(_currentUserId!);
      final now = DateTime.now();
      final lastDate = type == StreakType.diet
          ? data.stats.lastDietLogDate
          : data.stats.lastWorkoutLogDate;

      if (lastDate == null) return true;
      return !_isSameDay(lastDate, now);
    } catch (e) {
      print('Error checking if first of day: $e');
      return true;
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.unlockAchievement(_currentUserId!, achievementId);
    } catch (e) {
      print('Error unlocking achievement: $e');
    }
  }

  Future<bool> areBothStreaksCompletedToday() async {
    if (_currentUserId == null) return false;

    try {
      final data = await _firestoreService.getGamificationData(_currentUserId!);
      final now = DateTime.now();

      final dietDoneToday =
          data.stats.lastDietLogDate != null &&
          _isSameDay(data.stats.lastDietLogDate!, now);
      final workoutDoneToday =
          data.stats.lastWorkoutLogDate != null &&
          _isSameDay(data.stats.lastWorkoutLogDate!, now);

      return dietDoneToday && workoutDoneToday;
    } catch (e) {
      print('Error checking if both streaks completed: $e');
      return false;
    }
  }

  Future<void> reset() async {
    if (_currentUserId == null) return;

    try {
      await _firestoreService.resetStreak(_currentUserId!, StreakType.diet);
      await _firestoreService.resetStreak(_currentUserId!, StreakType.workout);
    } catch (e) {
      print('Error resetting gamification data: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_meal',
        title: 'First Bite',
        description: 'Log your first meal',
        iconAsset: 'assets/icons/apple.png',
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
}
