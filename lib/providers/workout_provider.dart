import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutState {
  final List<Workout> todayWorkouts;
  final Set<String> completedWorkoutIds;
  final bool isLoading;

  WorkoutState({
    this.todayWorkouts = const [],
    this.completedWorkoutIds = const {},
    this.isLoading = true,
  });

  WorkoutState copyWith({
    List<Workout>? todayWorkouts,
    Set<String>? completedWorkoutIds,
    bool? isLoading,
  }) {
    return WorkoutState(
      todayWorkouts: todayWorkouts ?? this.todayWorkouts,
      completedWorkoutIds: completedWorkoutIds ?? this.completedWorkoutIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, AsyncValue<WorkoutState>>((ref) {
      return WorkoutNotifier();
    });

class WorkoutNotifier extends StateNotifier<AsyncValue<WorkoutState>> {
  final WorkoutService _workoutService = WorkoutService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  WorkoutNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId == null) {
      state = AsyncValue.data(WorkoutState(isLoading: false));
      return;
    }

    try {
      final todayWorkouts = await _workoutService.getTodayWorkouts();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final history = await _workoutService.getWorkoutHistory(
        startDate: startOfDay,
        endDate: endOfDay,
      );

      final completedIds = history
          .map((w) => w['workoutId'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      state = AsyncValue.data(
        WorkoutState(
          todayWorkouts: todayWorkouts,
          completedWorkoutIds: completedIds,
          isLoading: false,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  List<Workout> get sortedWorkouts {
    final currentState = state.value;
    if (currentState == null) return [];

    final completed = currentState.completedWorkoutIds;
    final all = List<Workout>.from(currentState.todayWorkouts);

    all.sort((a, b) {
      final aDone = completed.contains(a.id);
      final bDone = completed.contains(b.id);
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1;
    });

    return all;
  }

  int getNextUncompletedIndex(int currentIndex, List<Workout> currentList) {
    if (currentList.isEmpty) return 0;

    final currentState = state.value;
    final completed = currentState?.completedWorkoutIds ?? {};

    for (int i = currentIndex + 1; i < currentList.length; i++) {
      if (!completed.contains(currentList[i].id)) {
        return i;
      }
    }

    for (int i = 0; i <= currentIndex; i++) {
      if (!completed.contains(currentList[i].id)) {
        return i;
      }
    }

    return 0;
  }

  Future<void> completeWorkout(Workout workout) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newCompletedIds = Set<String>.from(currentState.completedWorkoutIds)
      ..add(workout.id);

    state = AsyncValue.data(
      currentState.copyWith(completedWorkoutIds: newCompletedIds),
    );

    try {
      await _workoutService.completeWorkout(workout);
    } catch (e) {
      state = AsyncValue.data(currentState);
      print("Failed to sync workout completion: $e");
    }
  }

  Future<void> uncompleteWorkout(String workoutId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newCompletedIds = Set<String>.from(currentState.completedWorkoutIds)
      ..remove(workoutId);

    state = AsyncValue.data(
      currentState.copyWith(completedWorkoutIds: newCompletedIds),
    );
  }

  void addWorkoutToToday(Workout workout) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedWorkouts = List<Workout>.from(currentState.todayWorkouts);
    if (!updatedWorkouts.any((w) => w.id == workout.id)) {
      updatedWorkouts.add(workout);
      state = AsyncValue.data(
        currentState.copyWith(todayWorkouts: updatedWorkouts),
      );
    }
  }

  void removeWorkoutFromToday(String workoutId) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedWorkouts = List<Workout>.from(currentState.todayWorkouts);
    updatedWorkouts.removeWhere((w) => w.id == workoutId);

    state = AsyncValue.data(
      currentState.copyWith(todayWorkouts: updatedWorkouts),
    );
  }
}
