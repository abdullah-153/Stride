import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseFirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get currentUserId => auth.currentUser?.uid;

  void ensureAuthenticated() {
    if (currentUserId == null) {
      throw Exception('User must be authenticated to perform this operation');
    }
  }

  DocumentReference getUserDocument(String userId) {
    return firestore.collection('users').doc(userId);
  }

  CollectionReference getUserSubcollection(String userId, String subcollection) {
    return getUserDocument(userId).collection(subcollection);
  }

  Map<String, dynamic> addTimestamps(Map<String, dynamic> data, {bool isUpdate = false}) {
    final now = FieldValue.serverTimestamp();
    
    if (isUpdate) {
      data['updatedAt'] = now;
    } else {
      data['createdAt'] = now;
      data['updatedAt'] = now;
    }
    
    return data;
  }

  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime parseDate(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  Future<T> handleFirestoreOperation<T>(
    Future<T> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e, errorMessage);
    } catch (e) {
      throw errorMessage ?? 'An unexpected error occurred: $e';
    }
  }

  String _handleFirebaseException(FirebaseException e, String? customMessage) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'unauthenticated':
        return 'You must be signed in to perform this action.';
      default:
        return customMessage ?? 'An error occurred: ${e.message}';
    }
  }

  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = firestore.batch();
    
    for (final operation in operations) {
      final type = operation['type'] as String;
      final ref = operation['ref'] as DocumentReference;
      final data = operation['data'] as Map<String, dynamic>?;
      
      switch (type) {
        case 'set':
          batch.set(ref, data!);
          break;
        case 'update':
          batch.update(ref, data!);
          break;
        case 'delete':
          batch.delete(ref);
          break;
      }
    }
    
    await batch.commit();
  }

  Future<bool> documentExists(DocumentReference ref) async {
    final doc = await ref.get();
    return doc.exists;
  }

  Stream<T> streamDocument<T>(
    DocumentReference ref,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return ref.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Document does not exist');
      }
      return fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  Stream<List<T>> streamCollection<T>(
    Query query,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> enableOfflinePersistence() async {
    try {
      await firestore.settings.persistenceEnabled;
    } catch (e) {
      print('Offline persistence already enabled or not supported: $e');
    }
  }
}
