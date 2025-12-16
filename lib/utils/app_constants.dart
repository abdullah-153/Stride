/// App-wide constants for the Fitness Tracker app
library;

// ==================== COLORS ====================

import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  // Primary accent color
  static const Color accentGreen = Color.fromRGBO(206, 242, 75, 1);
  static const Color accentYellow = Color.fromRGBO(206, 235, 75, 1);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2E);

  // Light mode colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);

  // Navigation colors
  static const Color navHome = Colors.black;
  static const Color navDiet = Color.fromRGBO(206, 235, 75, 1);
  static const Color navWorkout = Colors.blue;
  static const Color navProfile = Colors.orange;
}

// ==================== DURATIONS ====================

/// Animation and timing constants
class AppDurations {
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration extraLongAnimation = Duration(milliseconds: 1000);

  static const Duration debounce = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
}

// ==================== SIZES ====================

/// Size and spacing constants
class AppSizes {
  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
}

// ==================== STRINGS ====================

/// String constants used throughout the app
class AppStrings {
  // App info
  static const String appName = 'Stride';

  // Navigation
  static const String navHome = 'Home';
  static const String navDiet = 'Diet';
  static const String navWorkout = 'Workout';
  static const String navProfile = 'Profile';

  // Common actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String logout = 'Logout';
  static const String confirm = 'Confirm';

  // Messages
  static const String logoutConfirmMessage = 'Do you want to logout?';
  static const String deleteConfirmMessage =
      'Are you sure you want to delete this?';
  static const String saveSuccessMessage = 'Saved successfully';
  static const String errorMessage = 'Something went wrong';
}

// ==================== ROUTES ====================

/// Route name constants
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

// ==================== NUMERIC CONSTANTS ====================

/// Numeric constants for calculations and limits
class AppConstants {
  // Nutrition
  static const double defaultDailyCalories = 2000.0;
  static const double defaultDailyProtein = 150.0;
  static const double defaultDailyCarbs = 250.0;
  static const double defaultDailyFat = 65.0;
  static const double defaultDailyWater = 2000.0; // ml

  // Workout
  static const int defaultWorkoutDuration = 30; // minutes
  static const int maxWorkoutDuration = 180; // minutes

  // Profile
  static const double minWeight = 30.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 120;

  // Gamification
  static const int xpPerWorkout = 50;
  static const int xpPerMeal = 25;
  static const int xpPerWaterIntake = 10;
  static const int xpPerLevel = 1000;
}
