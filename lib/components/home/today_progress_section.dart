import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/services/activity_service.dart';
import 'package:fitness_tracker_frontend/models/activity_model.dart';
import 'package:fitness_tracker_frontend/services/user_profile_service.dart';
import 'package:fitness_tracker_frontend/models/user_profile_model.dart';
import '../shared/bouncing_dots_indicator.dart';

class TodayActivitySection extends StatefulWidget {
  final bool isDarkMode;
  final Function(int)? onNavigate;

  const TodayActivitySection({
    super.key,
    this.isDarkMode = false,
    this.onNavigate,
  });

  @override
  State<TodayActivitySection> createState() => _TodayActivitySectionState();
}

class _TodayActivitySectionState extends State<TodayActivitySection> {
  final ActivityService _activityService = ActivityService();
  final UserProfileService _userProfileService = UserProfileService();
  ActivityData? _activityData;
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    try {
      final activityData = await _activityService.getTodayActivity();
      final profileData = await _userProfileService.loadProfile();
      if (mounted) {
        setState(() {
          _activityData = activityData;
          _userProfile = profileData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToWorkout() {
    widget.onNavigate?.call(2); // Navigate to WorkoutPage (index 2)
  }

  void _navigateToDiet() {
    widget.onNavigate?.call(1); // Navigate to DietPage (index 1)
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final screenH = SizeConfig.screenHeight;
    final preferred = SizeConfig.h(140);
    final maxAllowed = screenH * 0.32;
    final cardHeight = math.min(preferred, maxAllowed);

    final containerBgColor = widget.isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final borderColor = widget.isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final shadowColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.02)
        : Colors.black.withOpacity(0.04);
    final headerColor = widget.isDarkMode ? Colors.white54 : Colors.black38;
    final workoutBg = widget.isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.black;

    // Show loading state
    if (_isLoading) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.w(4),
          vertical: SizeConfig.h(6),
        ),
        padding: EdgeInsets.all(SizeConfig.w(14)),
        decoration: BoxDecoration(
          color: containerBgColor,
          borderRadius: BorderRadius.circular(SizeConfig.w(22)),
          border: Border.all(color: borderColor, width: 1.1),
        ),
        child: Center(
          child: BouncingDotsIndicator(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    // Use API data or fallback to defaults
    final workoutsCompleted = _activityData?.workoutsCompleted ?? 0;
    // For workout progress, we can use the weekly goal / 7 as a rough daily goal, or just use 1 if goal is 0
    final dailyWorkoutGoal = (_userProfile?.weeklyWorkoutGoal ?? 5) > 0 
        ? ((_userProfile?.weeklyWorkoutGoal ?? 5) / 7).ceil() 
        : 1;
    final totalWorkouts = dailyWorkoutGoal > 0 ? dailyWorkoutGoal : 1; 
    
    final calories = _activityData?.caloriesBurned ?? 0;
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    
    final steps = _activityData?.steps ?? 0;
    final stepGoal = 10000; // Default step goal as it's not in profile yet
    
    // Calculate progress for workout card
    final workoutProgress = (workoutsCompleted / totalWorkouts).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(4),
        vertical: SizeConfig.h(6),
      ),
      padding: EdgeInsets.all(SizeConfig.w(14)),
      decoration: BoxDecoration(
        color: containerBgColor,
        borderRadius: BorderRadius.circular(SizeConfig.w(22)),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Activity",
            style: TextStyle(
              fontSize: SizeConfig.sp(14),
              fontWeight: FontWeight.w600,
              color: headerColor,
            ),
          ),
          SizedBox(height: SizeConfig.h(10)),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateToWorkout,
                      borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                      child: Ink(
                        // Removed fixed height here
                        decoration: BoxDecoration(
                          color: workoutBg,
                          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                          border: Border.all(
                            color: widget.isDarkMode 
                                ? Colors.white.withOpacity(0.1) 
                                : Colors.transparent,
                            width: 1
                          ),
                        ),
                        child: Stack(
                          children: [
                             // Background Decorative Icon
                            Positioned(
                              right: -SizeConfig.w(10),
                              bottom: -SizeConfig.h(10),
                              child: Icon(
                                Icons.fitness_center_rounded,
                                size: SizeConfig.w(80),
                                color: widget.isDarkMode 
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white.withOpacity(0.15),
                              ),
                            ),
                            
                            Padding(
                              padding: EdgeInsets.all(SizeConfig.w(14)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Workout",
                                            style: TextStyle(
                                              fontSize: SizeConfig.sp(15),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const Spacer(),
                                          // Progress Ring with Arrow inside
                                          SizedBox(
                                            width: SizeConfig.w(40),
                                            height: SizeConfig.w(40),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  value: workoutProgress, // The progress value
                                                  strokeWidth: 3,
                                                  backgroundColor: Colors.white.withOpacity(0.2),
                                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCEF24B)),
                                                ),
                                                Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: SizeConfig.w(12),
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  // Removed Spacer
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        "$workoutsCompleted",
                                        style: TextStyle(
                                          fontSize: SizeConfig.sp(34),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: SizeConfig.w(4)),
                                      Text(
                                        "/$totalWorkouts",
                                        style: TextStyle(
                                          fontSize: SizeConfig.sp(14),
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.w(10)),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _ActivityMiniCard(
                        title: "Calories",
                        value: _formatNumber(calories),
                        unit: "kcal",
                        onTap: _navigateToDiet,
                        isDarkMode: widget.isDarkMode,
                        progress: (calories / 2500).clamp(0.0, 1.0), // Example goal
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                      _ActivityMiniCard(
                        title: "Steps",
                        value: _formatNumber(steps),
                        unit: "steps",
                        onTap: _navigateToWorkout,
                        isDarkMode: widget.isDarkMode,
                        progress: (steps / 10000).clamp(0.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0k', 'k');
    }
    return number.toString();
  }
}

class _ActivityMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final VoidCallback onTap;
  final bool isDarkMode;
  final double progress;

  const _ActivityMiniCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.onTap,
    this.isDarkMode = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Colors & Styles
    final cardBgColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    // Enhanced border visibility for Light Mode
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.08); // Increased from 0.05
    final titleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final valueColor = isDarkMode ? Colors.white : Colors.black87;
    final unitColor = isDarkMode ? Colors.white54 : Colors.black45;
    
    // Parse value for animation (remove non-digits for parsing)
    final numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final double endValue = double.tryParse(numericString) ?? 0;
    
    final isSteps = title == "Steps";
    final isCalories = title == "Calories";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.w(20)),
        child: Ink(
          height: SizeConfig.h(85), // Slightly taller for premium feel
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(SizeConfig.w(20)),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05), // Increased shadow in light mode
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Decorative Icon
              Positioned(
                right: -SizeConfig.w(10),
                bottom: -SizeConfig.h(10),
                child: Icon(
                  isSteps ? Icons.directions_walk_rounded : Icons.local_fire_department_rounded,
                  size: SizeConfig.w(60),
                  color: isDarkMode 
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.05), // Increased opacity for light mode
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(SizeConfig.w(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: SizeConfig.sp(13),
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(4)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                             // Animated Counter
                             TweenAnimationBuilder<double>(
                               tween: Tween<double>(begin: 0, end: endValue),
                               duration: const Duration(milliseconds: 1500),
                               curve: Curves.easeOutExpo,
                               builder: (context, val, child) {
                                 String text = "";
                                 if (endValue >= 1000) {
                                   // Keep k format if original had it, or re-format
                                   if (value.contains('k')) {
                                      text = '${(val / 1000).toStringAsFixed(1)}k'; 
                                   } else {
                                      text = val.toInt().toString();
                                   }
                                 } else {
                                   text = val.toInt().toString();
                                 }
                                 return Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(22),
                                    fontWeight: FontWeight.w800,
                                    color: valueColor,
                                    height: 1.0,
                                  ),
                                );
                               },
                             ),
                            SizedBox(width: SizeConfig.w(4)),
                            Text(
                              unit,
                              style: TextStyle(
                                fontSize: SizeConfig.sp(11),
                                fontWeight: FontWeight.w500,
                                color: unitColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Circular Progress (Now for both Steps and Calories)
                    SizedBox(
                      width: SizeConfig.w(40),
                      height: SizeConfig.w(40),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutQuart,
                            builder: (context, val, _) {
                              return CircularProgressIndicator(
                                value: val,
                                strokeWidth: 3,
                                strokeCap: StrokeCap.round,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCalories ? Colors.deepOrangeAccent : Colors.blueAccent
                                ),
                              );
                            },
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: SizeConfig.w(10),
                            color: titleColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
