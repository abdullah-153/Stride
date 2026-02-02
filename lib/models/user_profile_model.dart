import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_tracker_frontend/models/nutrition_model.dart';
import 'package:fitness_tracker_frontend/models/diet_plan_model.dart';

enum UnitPreference { metric, imperial }

class UserProfile {
  final String name;
  final String bio;
  final double weight;
  final double height;
  final int age;
  final DateTime? dateOfBirth;
  final String? profileImagePath;
  final String gender;

  final int weeklyWorkoutGoal;
  final int dailyCalorieGoal;
  final double? weightGoal;

  final NutritionGoal? nutritionGoal;
  final DietPlan? activeDietPlan;

  final int totalWorkoutsCompleted;
  final int totalMealsLogged;
  final int daysActive;

  final UnitPreference preferredUnits;

  const UserProfile({
    required this.name,
    this.bio = '',
    required this.weight,
    required this.height,
    required this.age,
    this.gender = 'Male',
    this.dateOfBirth,
    this.profileImagePath,
    this.weeklyWorkoutGoal = 5,
    this.dailyCalorieGoal = 2000,
    this.weightGoal,
    this.nutritionGoal,
    this.activeDietPlan,
    this.totalWorkoutsCompleted = 0,
    this.totalMealsLogged = 0,
    this.daysActive = 0,
    this.preferredUnits = UnitPreference.metric,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  UserProfile copyWith({
    String? name,
    String? bio,
    double? weight,
    double? height,
    int? age,
    String? gender,
    DateTime? dateOfBirth,
    String? profileImagePath,
    int? weeklyWorkoutGoal,
    int? dailyCalorieGoal,
    double? weightGoal,
    NutritionGoal? nutritionGoal,
    DietPlan? activeDietPlan,
    int? totalWorkoutsCompleted,
    int? totalMealsLogged,
    int? daysActive,
    UnitPreference? preferredUnits,
  }) {
    return UserProfile(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      dailyCalorieGoal:
          dailyCalorieGoal ??
          nutritionGoal?.dailyCalories ??
          this.dailyCalorieGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      nutritionGoal: nutritionGoal ?? this.nutritionGoal,
      activeDietPlan: activeDietPlan ?? this.activeDietPlan,
      totalWorkoutsCompleted:
          totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      totalMealsLogged: totalMealsLogged ?? this.totalMealsLogged,
      daysActive: daysActive ?? this.daysActive,
      preferredUnits: preferredUnits ?? this.preferredUnits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bio': bio,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileImagePath': profileImagePath,
      'weeklyWorkoutGoal': weeklyWorkoutGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'weightGoal': weightGoal,
      'nutritionGoal': nutritionGoal?.toJson(),
      'activeDietPlan': activeDietPlan?.toJson(),
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
      'totalMealsLogged': totalMealsLogged,
      'daysActive': daysActive,
      'preferredUnits': preferredUnits.toString().split('.').last,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      bio: json['bio'] as String? ?? '',
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      gender: json['gender'] as String? ?? 'Male',
      dateOfBirth: json['dateOfBirth'] != null
          ? (json['dateOfBirth'] is Timestamp
                ? (json['dateOfBirth'] as Timestamp).toDate()
                : DateTime.parse(json['dateOfBirth'] as String))
          : null,
      profileImagePath: json['profileImagePath'] as String?,
      weeklyWorkoutGoal: json['weeklyWorkoutGoal'] as int? ?? 5,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2000,
      weightGoal: json['weightGoal'] != null
          ? (json['weightGoal'] as num).toDouble()
          : null,
      nutritionGoal: json['nutritionGoal'] != null
          ? NutritionGoal.fromJson(json['nutritionGoal'])
          : null,
      activeDietPlan: json['activeDietPlan'] != null
          ? DietPlan.fromJson(json['activeDietPlan'])
          : null,
      totalWorkoutsCompleted: json['totalWorkoutsCompleted'] as int? ?? 0,
      totalMealsLogged: json['totalMealsLogged'] as int? ?? 0,
      daysActive: json['daysActive'] as int? ?? 0,
      preferredUnits: json['preferredUnits'] != null
          ? UnitPreference.values.firstWhere(
              (e) => e.toString().split('.').last == json['preferredUnits'],
              orElse: () => UnitPreference.metric,
            )
          : UnitPreference.metric,
    );
  }

  factory UserProfile.defaultProfile() {
    return const UserProfile(
      name: 'User',
      bio: 'Fitness Enthusiast',
      weight: 70.0,
      height: 170.0,
      age: 25,
      gender: 'Male',
      weeklyWorkoutGoal: 5,
      dailyCalorieGoal: 2000,
      totalWorkoutsCompleted: 0,
      totalMealsLogged: 0,
      daysActive: 0,
      preferredUnits: UnitPreference.metric,
    );
  }
}
