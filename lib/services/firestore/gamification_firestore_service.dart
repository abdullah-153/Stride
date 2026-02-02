import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/gamification_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class GamificationFirestoreService extends BaseFirestoreService {
  static final GamificationFirestoreService _instance =
      GamificationFirestoreService._internal();
  factory GamificationFirestoreService() => _instance;
  GamificationFirestoreService._internal();

  static const int BASE_XP = 80;
  static const int XP_PER_LEVEL_MULTIPLIER = 20;

  int _getXpForLevel(int level) => BASE_XP + (level * XP_PER_LEVEL_MULTIPLIER);

  Future<GamificationData> getGamificationData(String userId) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserDocument(
        userId,
      ).collection(FirestoreCollections.gamification).doc('data').get();

      if (!doc.exists || doc.data() == null) {
        final initialData = _createInitialGamificationData();
        await _initializeGamificationData(userId, initialData);
        return initialData;
      }

      return _gamificationDataFromJson(doc.data()!);
    }, errorMessage: 'Failed to fetch gamification data');
  }

  Stream<GamificationData> streamGamificationData(String userId) {
    final docRef = getUserDocument(
      userId,
    ).collection(FirestoreCollections.gamification).doc('data');

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return _createInitialGamificationData();
      }
      return _gamificationDataFromJson(snapshot.data()!);
    });
  }

  Future<void> addXp(String userId, int xpToAdd) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final docRef = getUserDocument(
        userId,
      ).collection(FirestoreCollections.gamification).doc('data');

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          final initialData = _createInitialGamificationData();
          transaction.set(docRef, _gamificationDataToJson(initialData));
          return;
        }

        final data = snapshot.data()!;
        final stats = data[FirestoreFields.stats] as Map<String, dynamic>;

        int currentXp = stats[FirestoreFields.currentXp] as int;
        int currentLevel = stats[FirestoreFields.currentLevel] as int;

        currentXp += xpToAdd;

        final xpNeeded = _getXpForLevel(currentLevel);
        if (currentXp >= xpNeeded) {
          currentXp -= xpNeeded;
          currentLevel++;
        }

        transaction.update(docRef, {
          '${FirestoreFields.stats}.${FirestoreFields.currentXp}': currentXp,
          '${FirestoreFields.stats}.${FirestoreFields.currentLevel}':
              currentLevel,
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      });
    }, errorMessage: 'Failed to add XP');
  }

  Future<void> addWaterXp(String userId) async {
    await addXp(userId, 10);
  }

  Future<void> updateStreak(
    String userId,
    StreakType streakType,
    DateTime date,
  ) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final docRef = getUserDocument(
        userId,
      ).collection(FirestoreCollections.gamification).doc('data');

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          final initialData = _createInitialGamificationData();
          transaction.set(docRef, _gamificationDataToJson(initialData));
          return;
        }

        final data = snapshot.data()!;
        final stats = data[FirestoreFields.stats] as Map<String, dynamic>;

        final updates = <String, dynamic>{
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        };

        if (streakType == StreakType.diet) {
          final lastDietLog = timestampToDateTime(
            stats[FirestoreFields.lastDietLogDate],
          );
          final dietStreak = stats[FirestoreFields.dietStreak] as int? ?? 0;

          if (_isSameDay(lastDietLog, date)) {
            updates['${FirestoreFields.stats}.${FirestoreFields.lastDietLogDate}'] =
                Timestamp.fromDate(date);
          } else if (_shouldIncrementStreak(lastDietLog, date)) {
            updates['${FirestoreFields.stats}.${FirestoreFields.dietStreak}'] =
                dietStreak + 1;
            updates['${FirestoreFields.stats}.${FirestoreFields.lastDietLogDate}'] =
                Timestamp.fromDate(date);
          } else {
            updates['${FirestoreFields.stats}.${FirestoreFields.dietStreak}'] =
                1;
            updates['${FirestoreFields.stats}.${FirestoreFields.lastDietLogDate}'] =
                Timestamp.fromDate(date);
          }
        } else if (streakType == StreakType.workout) {
          final lastWorkoutLog = timestampToDateTime(
            stats[FirestoreFields.lastWorkoutLogDate],
          );
          final workoutStreak =
              stats[FirestoreFields.workoutStreak] as int? ?? 0;

          if (_isSameDay(lastWorkoutLog, date)) {
            updates['${FirestoreFields.stats}.${FirestoreFields.lastWorkoutLogDate}'] =
                Timestamp.fromDate(date);
          } else if (_shouldIncrementStreak(lastWorkoutLog, date)) {
            updates['${FirestoreFields.stats}.${FirestoreFields.workoutStreak}'] =
                workoutStreak + 1;
            updates['${FirestoreFields.stats}.${FirestoreFields.lastWorkoutLogDate}'] =
                Timestamp.fromDate(date);
          } else {
            updates['${FirestoreFields.stats}.${FirestoreFields.workoutStreak}'] =
                1;
            updates['${FirestoreFields.stats}.${FirestoreFields.lastWorkoutLogDate}'] =
                Timestamp.fromDate(date);
          }
        }

        final lastLog = timestampToDateTime(stats[FirestoreFields.lastLogDate]);
        final currentStreak = stats[FirestoreFields.currentStreak] as int? ?? 0;
        final longestStreak = stats[FirestoreFields.longestStreak] as int? ?? 0;

        int newStreak = currentStreak;
        if (_isSameDay(lastLog, date)) {
          newStreak = currentStreak;
        } else if (_shouldIncrementStreak(lastLog, date)) {
          newStreak = currentStreak + 1;
        } else {
          newStreak = 1;
        }

        updates['${FirestoreFields.stats}.${FirestoreFields.currentStreak}'] =
            newStreak;
        updates['${FirestoreFields.stats}.${FirestoreFields.lastLogDate}'] =
            Timestamp.fromDate(date);

        if (newStreak > longestStreak) {
          updates['${FirestoreFields.stats}.${FirestoreFields.longestStreak}'] =
              newStreak;
        }

        final activityDate = DateTime(date.year, date.month, date.day);
        updates['${FirestoreFields.stats}.activityDates'] =
            FieldValue.arrayUnion([activityDate.toIso8601String()]);

        transaction.update(docRef, updates);
      });
    }, errorMessage: 'Failed to update streak');
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.gamification).doc('data').update({
        '${FirestoreFields.achievements}.$achievementId.${FirestoreFields.isUnlocked}':
            true,
        '${FirestoreFields.achievements}.$achievementId.${FirestoreFields.unlockedAt}':
            FieldValue.serverTimestamp(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to unlock achievement');
  }

  Future<void> resetStreak(String userId, StreakType streakType) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final updates = <String, dynamic>{
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      };

      if (streakType == StreakType.diet) {
        updates['${FirestoreFields.stats}.${FirestoreFields.dietStreak}'] = 0;
      } else if (streakType == StreakType.workout) {
        updates['${FirestoreFields.stats}.${FirestoreFields.workoutStreak}'] =
            0;
      }

      await getUserDocument(userId)
          .collection(FirestoreCollections.gamification)
          .doc('data')
          .update(updates);
    }, errorMessage: 'Failed to reset streak');
  }

  Future<void> resetGlobalStreak(String userId) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.gamification).doc('data').update({
        '${FirestoreFields.stats}.${FirestoreFields.currentStreak}': 0,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    }, errorMessage: 'Failed to reset global streak');
  }

  Future<void> _initializeGamificationData(
    String userId,
    GamificationData data,
  ) async {
    await getUserDocument(userId)
        .collection(FirestoreCollections.gamification)
        .doc('data')
        .set(_gamificationDataToJson(data));
  }

  GamificationData _createInitialGamificationData() {
    return GamificationData(stats: UserStats.initial(), achievements: []);
  }

  Map<String, dynamic> _gamificationDataToJson(GamificationData data) {
    final achievementsMap = <String, dynamic>{};
    for (final achievement in data.achievements) {
      achievementsMap[achievement.id] = {
        FirestoreFields.isUnlocked: achievement.isUnlocked,
        FirestoreFields.unlockedAt: achievement.unlockedAt != null
            ? Timestamp.fromDate(achievement.unlockedAt!)
            : null,
      };
    }

    return {
      FirestoreFields.stats: data.stats.toJson(),
      FirestoreFields.achievements: achievementsMap,
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  GamificationData _gamificationDataFromJson(Map<String, dynamic> json) {
    final statsData = json[FirestoreFields.stats] as Map<String, dynamic>;
    final achievementsData =
        json[FirestoreFields.achievements] as Map<String, dynamic>? ?? {};

    final stats = UserStats.fromJson(statsData);

    final achievements = <Achievement>[];
    achievementsData.forEach((key, value) {
      final achievementData = value as Map<String, dynamic>;
      achievements.add(
        Achievement(
          id: key,
          title: '',
          description: '',
          iconAsset: '',
          isUnlocked:
              achievementData[FirestoreFields.isUnlocked] as bool? ?? false,
          unlockedAt: timestampToDateTime(
            achievementData[FirestoreFields.unlockedAt],
          ),
        ),
      );
    });

    return GamificationData(stats: stats, achievements: achievements);
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    final d1 = date1.toLocal();
    final d2 = date2.toLocal();
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _shouldIncrementStreak(DateTime? lastLog, DateTime currentLog) {
    if (lastLog == null) return false;

    final lastDate = lastLog.toLocal();
    final currentDate = currentLog.toLocal();

    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final currentDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    final difference = currentDay.difference(lastDay).inDays;

    return difference == 1;
  }

  bool _shouldResetStreak(DateTime? lastLog, DateTime currentLog) {
    if (lastLog == null) return true;

    final lastDate = lastLog.toLocal();
    final currentDate = currentLog.toLocal();

    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final currentDay = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    final difference = currentDay.difference(lastDay).inDays;

    return difference > 1;
  }
}
