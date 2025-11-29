import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/services/activity_service.dart';
import 'package:fitness_tracker_frontend/models/activity_model.dart';

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
  ActivityData? _activityData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivityData();
  }

  Future<void> _loadActivityData() async {
    try {
      final data = await _activityService.getTodayActivity();
      if (mounted) {
        setState(() {
          _activityData = data;
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
          child: CircularProgressIndicator(
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    // Use API data or fallback to defaults
    final workoutsCompleted = _activityData?.workoutsCompleted ?? 0;
    final totalWorkouts = _activityData?.totalWorkouts ?? 5;
    final calories = _activityData?.caloriesBurned ?? 0;
    final steps = _activityData?.steps ?? 0;

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
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _navigateToWorkout,
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                    child: Ink(
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: workoutBg,
                        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                      ),
                      padding: EdgeInsets.all(SizeConfig.w(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Workout",
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(15),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                                size: SizeConfig.w(13),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: SizeConfig.h(6),
                                ),
                                child: Text(
                                  "/$totalWorkouts",
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(14),
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
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
                    ),
                    SizedBox(height: SizeConfig.h(8)),
                    _ActivityMiniCard(
                      title: "Steps",
                      value: _formatNumber(steps),
                      unit: "steps",
                      onTap: _navigateToWorkout,
                      isDarkMode: widget.isDarkMode,
                    ),
                  ],
                ),
              ),
            ],
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

  const _ActivityMiniCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme
    final cardBgColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.4)
        : Colors.black87.withOpacity(0.4);
    final titleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final valueColor = isDarkMode ? Colors.white : Colors.black87;
    final unitColor = isDarkMode
        ? Colors.white.withOpacity(0.8)
        : Colors.black87.withOpacity(0.8);
    final arrowColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        child: Ink(
          height: SizeConfig.h(65),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(SizeConfig.w(16)),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(12),
            vertical: SizeConfig.h(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(13),
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: arrowColor,
                    size: SizeConfig.w(11),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(20),
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(4)),
                  Padding(
                    padding: EdgeInsets.only(bottom: SizeConfig.h(2)),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(11),
                        fontWeight: FontWeight.w500,
                        color: unitColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
