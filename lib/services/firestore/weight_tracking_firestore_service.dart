import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/weight_entry_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class WeightTrackingFirestoreService extends BaseFirestoreService {
  static final WeightTrackingFirestoreService _instance =
      WeightTrackingFirestoreService._internal();
  factory WeightTrackingFirestoreService() => _instance;
  WeightTrackingFirestoreService._internal();

  Future<void> addWeightEntry(String userId, WeightEntry entry) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final entryData = entry.toJson();
      final dataWithTimestamps = addTimestamps(entryData);

      final dateKey = getDateKey(entry.date);
      await getUserSubcollection(
        userId,
        FirestoreCollections.weightEntries,
      ).doc(dateKey).set(dataWithTimestamps);
    }, errorMessage: 'Failed to add weight entry');
  }

  Future<void> updateWeightEntry(String userId, WeightEntry entry) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final entryData = entry.toJson();
      final dataWithTimestamps = addTimestamps(entryData, isUpdate: true);

      final dateKey = getDateKey(entry.date);
      await getUserSubcollection(
        userId,
        FirestoreCollections.weightEntries,
      ).doc(dateKey).update(dataWithTimestamps);
    }, errorMessage: 'Failed to update weight entry');
  }

  Future<void> deleteWeightEntry(String userId, DateTime date) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final dateKey = getDateKey(date);
      await getUserSubcollection(
        userId,
        FirestoreCollections.weightEntries,
      ).doc(dateKey).delete();
    }, errorMessage: 'Failed to delete weight entry');
  }

  Future<List<WeightEntry>> getWeightHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    return handleFirestoreOperation(() async {
      Query query = getUserSubcollection(
        userId,
        FirestoreCollections.weightEntries,
      ).orderBy(FirestoreFields.date, descending: true);

      if (startDate != null) {
        query = query.where(
          FirestoreFields.date,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          FirestoreFields.date,
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) => WeightEntry.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    }, errorMessage: 'Failed to fetch weight history');
  }

  Future<WeightEntry?> getLatestWeight(String userId) async {
    return handleFirestoreOperation(() async {
      final snapshot = await getUserSubcollection(
        userId,
        FirestoreCollections.weightEntries,
      ).orderBy(FirestoreFields.date, descending: true).limit(1).get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return WeightEntry.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    }, errorMessage: 'Failed to fetch latest weight');
  }

  Stream<List<WeightEntry>> streamWeightHistory(String userId, {int? limit}) {
    Query query = getUserSubcollection(
      userId,
      FirestoreCollections.weightEntries,
    ).orderBy(FirestoreFields.date, descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => WeightEntry.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }
}
