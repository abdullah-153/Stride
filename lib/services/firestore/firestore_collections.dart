class FirestoreCollections {
  static const String users = 'users';

  static const String profile = 'profile';
  static const String gamification = 'gamification';
  static const String settings = 'settings';

  static const String workouts = 'workouts';
  static const String completedWorkouts = 'completedWorkouts';
  static const String nutrition = 'nutrition';
  static const String meals = 'meals';
  static const String activity = 'activity';
  static const String weightEntries = 'weightEntries';
}

class FirestoreFields {
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String userId = 'userId';
  static const String timestamp = 'timestamp';
  static const String date = 'date';

  static const String name = 'name';
  static const String email = 'email';
  static const String bio = 'bio';
  static const String weight = 'weight';
  static const String height = 'height';
  static const String age = 'age';
  static const String dateOfBirth = 'dateOfBirth';
  static const String profileImageUrl = 'profileImageUrl';
  static const String profileImagePath = 'profileImagePath';
  static const String weeklyWorkoutGoal = 'weeklyWorkoutGoal';
  static const String dailyCalorieGoal = 'dailyCalorieGoal';
  static const String weightGoal = 'weightGoal';
  static const String totalWorkoutsCompleted = 'totalWorkoutsCompleted';
  static const String totalMealsLogged = 'totalMealsLogged';
  static const String daysActive = 'daysActive';
  static const String preferredUnits = 'preferredUnits';

  static const String stats = 'stats';
  static const String currentXp = 'currentXp';
  static const String currentLevel = 'currentLevel';
  static const String currentStreak = 'currentStreak';
  static const String longestStreak = 'longestStreak';
  static const String lastLogDate = 'lastLogDate';
  static const String dietStreak = 'dietStreak';
  static const String workoutStreak = 'workoutStreak';
  static const String lastDietLogDate = 'lastDietLogDate';
  static const String lastWorkoutLogDate = 'lastWorkoutLogDate';
  static const String achievements = 'achievements';
  static const String isUnlocked = 'isUnlocked';
  static const String unlockedAt = 'unlockedAt';

  static const String workoutId = 'workoutId';
  static const String title = 'title';
  static const String category = 'category';
  static const String durationMinutes = 'durationMinutes';
  static const String caloriesBurned = 'caloriesBurned';
  static const String points = 'points';
  static const String difficulty = 'difficulty';
  static const String exercises = 'exercises';
  static const String description = 'description';
  static const String isRecommended = 'isRecommended';
  static const String completedAt = 'completedAt';
  static const String actualDuration = 'actualDuration';
  static const String notes = 'notes';

  static const String waterIntake = 'waterIntake';
  static const String goal = 'goal';
  static const String dailyCalories = 'dailyCalories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fats = 'fats';
  static const String waterGoal = 'waterGoal';

  static const String mealType = 'type';
  static const String calories = 'calories';
  static const String macros = 'macros';
  static const String imageUrl = 'imageUrl';
  static const String isFavorite = 'isFavorite';

  static const String workoutsCompleted = 'workoutsCompleted';
  static const String totalWorkouts = 'totalWorkouts';
  static const String steps = 'steps';
  static const String maxSteps = 'maxSteps';

  static const String notificationsEnabled = 'notificationsEnabled';
  static const String workoutReminders = 'workoutReminders';
  static const String dietReminders = 'dietReminders';
  static const String workoutReminderTime = 'workoutReminderTime';
  static const String dietReminderTime = 'dietReminderTime';
  static const String privacyLevel = 'privacyLevel';
  static const String hour = 'hour';
  static const String minute = 'minute';
}

class FirebaseStoragePaths {
  static String userProfileImage(String userId) =>
      'users/$userId/profile/avatar';
  static String userMealImage(String userId, String mealId) =>
      'users/$userId/meals/$mealId';
}
