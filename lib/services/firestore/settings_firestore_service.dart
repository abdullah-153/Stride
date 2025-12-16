import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_settings_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class SettingsFirestoreService extends BaseFirestoreService {
  static final SettingsFirestoreService _instance =
      SettingsFirestoreService._internal();
  factory SettingsFirestoreService() => _instance;
  SettingsFirestoreService._internal();

  Future<AppSettings> getSettings(String userId) async {
    return handleFirestoreOperation(() async {
      final doc = await getUserDocument(
        userId,
      ).collection(FirestoreCollections.settings).doc('data').get();

      if (!doc.exists || doc.data() == null) {
        return AppSettings.defaultSettings();
      }

      return AppSettings.fromJson(doc.data()!);
    }, errorMessage: 'Failed to fetch settings');
  }

  Stream<AppSettings> streamSettings(String userId) {
    final docRef = getUserDocument(
      userId,
    ).collection(FirestoreCollections.settings).doc('data');

    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return AppSettings.defaultSettings();
      }
      return AppSettings.fromJson(snapshot.data()!);
    });
  }

  Future<void> updateSettings(String userId, AppSettings settings) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final settingsData = settings.toJson();
      final dataWithTimestamps = addTimestamps(settingsData, isUpdate: true);

      await getUserDocument(userId)
          .collection(FirestoreCollections.settings)
          .doc('data')
          .set(dataWithTimestamps, SetOptions(merge: true));
    }, errorMessage: 'Failed to update settings');
  }

  Future<void> updateNotificationPreferences(
    String userId, {
    bool? notificationsEnabled,
    bool? workoutReminders,
    bool? dietReminders,
  }) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final updates = <String, dynamic>{
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      };

      if (notificationsEnabled != null) {
        updates[FirestoreFields.notificationsEnabled] = notificationsEnabled;
      }
      if (workoutReminders != null) {
        updates[FirestoreFields.workoutReminders] = workoutReminders;
      }
      if (dietReminders != null) {
        updates[FirestoreFields.dietReminders] = dietReminders;
      }

      await getUserDocument(
        userId,
      ).collection(FirestoreCollections.settings).doc('data').update(updates);
    }, errorMessage: 'Failed to update notification preferences');
  }
}
