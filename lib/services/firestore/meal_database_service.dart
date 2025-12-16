import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore/base_firestore_service.dart';

class MealDatabaseService extends BaseFirestoreService {
  static final MealDatabaseService _instance = MealDatabaseService._internal();
  factory MealDatabaseService() => _instance;
  MealDatabaseService._internal();

  Future<void> cacheMeal(Map<String, dynamic> mealData) async {
    return handleFirestoreOperation(
      () async {
        final mealId = mealData['id'] as String;
        final dataWithTimestamps = addTimestamps(mealData);
        
        await firestore
            .collection('mealDatabase')
            .doc(mealId)
            .set(dataWithTimestamps, SetOptions(merge: true));
      },
      errorMessage: 'Failed to cache meal',
    );
  }

  Future<Map<String, dynamic>?> getMealFromCache(String mealId) async {
    return handleFirestoreOperation(
      () async {
        final doc = await firestore
            .collection('mealDatabase')
            .doc(mealId)
            .get();
        
        if (!doc.exists || doc.data() == null) {
          return null;
        }
        
        return {...doc.data()!, 'id': doc.id};
      },
      errorMessage: 'Failed to get meal from cache',
    );
  }

  Future<List<Map<String, dynamic>>> searchCachedMeals(String query) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('mealDatabase')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(20)
            .get();
        
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      },
      errorMessage: 'Failed to search cached meals',
    );
  }

  Future<List<Map<String, dynamic>>> getMealsByCategory(String category) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await firestore
            .collection('mealDatabase')
            .where('category', isEqualTo: category)
            .limit(20)
            .get();
        
        return snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList();
      },
      errorMessage: 'Failed to get meals by category',
    );
  }

  Future<void> saveMealToUser(String userId, String mealId) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        await getUserSubcollection(userId, 'savedMeals')
            .doc(mealId)
            .set({
          'mealId': mealId,
          'savedAt': FieldValue.serverTimestamp(),
          'isFavorite': true,
        });
      },
      errorMessage: 'Failed to save meal',
    );
  }

  Future<void> removeSavedMeal(String userId, String mealId) async {
    ensureAuthenticated();
    
    return handleFirestoreOperation(
      () async {
        await getUserSubcollection(userId, 'savedMeals')
            .doc(mealId)
            .delete();
      },
      errorMessage: 'Failed to remove saved meal',
    );
  }

  Future<List<String>> getUserSavedMealIds(String userId) async {
    return handleFirestoreOperation(
      () async {
        final snapshot = await getUserSubcollection(userId, 'savedMeals')
            .get();
        
        return snapshot.docs.map((doc) => doc.id).toList();
      },
      errorMessage: 'Failed to get saved meals',
    );
  }
}
