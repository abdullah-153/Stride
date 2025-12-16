class ActivityData {
  final int workoutsCompleted;
  final int totalWorkouts;
  final int caloriesBurned;
  final int steps;
  final int maxSteps;

  ActivityData({
    required this.workoutsCompleted,
    required this.totalWorkouts,
    required this.caloriesBurned,
    required this.steps,
    required this.maxSteps,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      workoutsCompleted: json['workoutsCompleted'] as int,
      totalWorkouts: json['totalWorkouts'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      steps: json['steps'] as int,
      maxSteps: json['maxSteps'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workoutsCompleted': workoutsCompleted,
      'totalWorkouts': totalWorkouts,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'maxSteps': maxSteps,
    };
  }
}
