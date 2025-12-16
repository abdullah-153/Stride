library;


import 'package:flutter/material.dart';

class AppColors {
  static const Color accentGreen = Color.fromRGBO(206, 242, 75, 1);
  static const Color accentYellow = Color.fromRGBO(206, 235, 75, 1);

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2E);

  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);

  static const Color navHome = Colors.black;
  static const Color navDiet = Color.fromRGBO(206, 235, 75, 1);
  static const Color navWorkout = Colors.blue;
  static const Color navProfile = Colors.orange;
}


class AppDurations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration extraLongAnimation = Duration(milliseconds: 1000);

  static const Duration debounce = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}


class AppSizes {
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
}


class AppStrings {
  static const String appName = 'Stride';

  static const String navHome = 'Home';
  static const String navDiet = 'Diet';
  static const String navWorkout = 'Workout';
  static const String navProfile = 'Profile';

  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String logout = 'Logout';
  static const String confirm = 'Confirm';

  static const String logoutConfirmMessage = 'Do you want to logout?';
  static const String deleteConfirmMessage =
      'Are you sure you want to delete this?';
  static const String saveSuccessMessage = 'Saved successfully';
  static const String errorMessage = 'Something went wrong';
}


class AppRoutes {
  static const String startup = '/startup';
  static const String home = '/home';
  static const String login = '/loginpage';
  static const String register = '/registerpage';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notificationSettings = '/notification-settings';
  static const String privacySecurity = '/privacy-security';
}


class AppConstants {
  static const double defaultDailyCalories = 2000.0;
  static const double defaultDailyProtein = 150.0;
  static const double defaultDailyCarbs = 250.0;
  static const double defaultDailyFat = 65.0;
  static const double defaultDailyWater = 2000.0; // ml

  static const int defaultWorkoutDuration = 30; // minutes
  static const int maxWorkoutDuration = 180; // minutes

  static const double minWeight = 30.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 120;

  static const int xpPerWorkout = 50;
  static const int xpPerMeal = 25;
  static const int xpPerWaterIntake = 10;
  static const int xpPerLevel = 1000;
}
