import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore/workout_plan_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutPlansState {
  final List<Map<String, dynamic>> plans;
  final String? activePlanId;
  final bool isLoading;
  final String? error;

  WorkoutPlansState({
    this.plans = const [],
    this.activePlanId,
    this.isLoading = true,
    this.error,
  });

  WorkoutPlansState copyWith({
    List<Map<String, dynamic>>? plans,
    String? activePlanId,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutPlansState(
      plans: plans ?? this.plans,
      activePlanId: activePlanId ?? this.activePlanId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final workoutPlansProvider = StateNotifierProvider<WorkoutPlansNotifier, AsyncValue<WorkoutPlansState>>((ref) {
  return WorkoutPlansNotifier();
});

class WorkoutPlansNotifier extends StateNotifier<AsyncValue<WorkoutPlansState>> {
  final WorkoutPlanService _service = WorkoutPlanService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  WorkoutPlansNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId == null) {
      state = AsyncValue.data(WorkoutPlansState(isLoading: false));
      return;
    }

    try {
      final plans = await _service.getUserWorkoutPlans(_userId);
      final activeData = await _service.getActiveWorkoutPlan(_userId);
      final activePlanId = activeData?['planId'];

      state = AsyncValue.data(WorkoutPlansState(
        plans: plans,
        activePlanId: activePlanId,
        isLoading: false,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _init();
  }

  Future<void> deletePlan(String planId) async {
    final currentState = state.value;
    if (currentState == null || _userId == null) return;

     
    final updatedPlans = currentState.plans.where((p) => p['id'] != planId).toList();
     
    final updatedActiveId = currentState.activePlanId == planId ? null : currentState.activePlanId;

    state = AsyncValue.data(currentState.copyWith(
      plans: updatedPlans,
      activePlanId: updatedActiveId,
    ));

    try {
      await _service.deleteWorkoutPlan(_userId, planId);
    } catch (e) {
       
      state = AsyncValue.data(currentState);
      print("Failed to delete plan: $e");
    }
  }
  
  Future<void> activatePlan(String planId) async {
    final currentState = state.value;
    if (currentState == null || _userId == null) return;

     
    state = AsyncValue.data(currentState.copyWith(
      activePlanId: planId,
    ));

    try {
      await _service.setActiveWorkoutPlan(_userId, planId, DateTime.now());
       
       
       
    } catch (e) {
      state = AsyncValue.data(currentState);  
       print("Failed to activate plan: $e");
    }
  }
  
   
  void updatePlan(Map<String, dynamic> updatedPlan) {
    final currentState = state.value;
    if (currentState == null) return;
    
    final updatedPlans = List<Map<String, dynamic>>.from(currentState.plans);
    final index = updatedPlans.indexWhere((p) => p['id'] == updatedPlan['id']);
    
    if (index != -1) {
      updatedPlans[index] = updatedPlan;
      state = AsyncValue.data(currentState.copyWith(plans: updatedPlans));
    }
  }
}
