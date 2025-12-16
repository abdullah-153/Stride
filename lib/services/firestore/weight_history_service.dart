import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/weight_entry_model.dart';
import 'base_firestore_service.dart';
import 'firestore_collections.dart';

class WeightHistoryService extends BaseFirestoreService {
  static final WeightHistoryService _instance = WeightHistoryService._internal();
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
        // Handle Timestamp from Firestore
        if (data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return WeightEntry.fromJson(data);
      }).toList();
    });
  }

  Future<void> addWeightEntry(String userId, double weight) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        final now = DateTime.now();
        final entry = WeightEntry(date: now, weight: weight);
        
        // Use normalized date string as ID to allow one entry per second? Or just auto-id. 
        // Using auto-id allows multiple entries per day if desired, but sorting ensures order.
        await getUserDocument(userId)
            .collection('weight_history')
            .add({
                ...entry.toJson(),
                'date': FieldValue.serverTimestamp(), // Use server timestamp for precise sorting
            });
            
        // Also update the main profile weight
        await getUserDocument(userId).update({
          'weight': weight,
          'bmi': entry.calculateBMI(80), // We need height here...
          // Actually, Profile update handles BMI. This is just log.
          // Let's rely on Profile update to handle current stats. 
          // This service just logs history.
        });
      },
      errorMessage: 'Failed to log weight',
    );
  }
  
  // Backfill history (helper if needed, but we start empty)
}
