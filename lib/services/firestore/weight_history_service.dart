import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/weight_entry_model.dart';
import 'base_firestore_service.dart';

class WeightHistoryService extends BaseFirestoreService {
  static final WeightHistoryService _instance =
      WeightHistoryService._internal();
  factory WeightHistoryService() => _instance;
  WeightHistoryService._internal();

  Stream<List<WeightEntry>> getWeightHistory(String userId) {
    return getUserDocument(userId)
        .collection('weight_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            if (data['date'] is Timestamp) {
              data['date'] = (data['date'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            return WeightEntry.fromJson(data);
          }).toList();
        });
  }

  Future<void> addWeightEntry(String userId, double weight) async {
    ensureAuthenticated();

    return handleFirestoreOperation(() async {
      final now = DateTime.now();
      final entry = WeightEntry(date: now, weight: weight);

      await getUserDocument(userId).collection('weight_history').add({
        ...entry.toJson(),
        'date': FieldValue.serverTimestamp(),
      });

      await getUserDocument(
        userId,
      ).update({'weight': weight, 'bmi': entry.calculateBMI(80)});
    }, errorMessage: 'Failed to log weight');
  }
}
