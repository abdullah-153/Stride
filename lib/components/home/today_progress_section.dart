import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/services/activity_service.dart';
import 'package:fitness_tracker_frontend/models/activity_model.dart';
import 'package:fitness_tracker_frontend/services/user_profile_service.dart';
import 'package:fitness_tracker_frontend/models/user_profile_model.dart';
import 'package:fitness_tracker_frontend/services/nutrition_service.dart';
import 'package:fitness_tracker_frontend/models/nutrition_model.dart';
import '../shared/bouncing_dots_indicator.dart';
import '../../pages/active_tracking_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/workout_provider.dart';

class TodayActivitySection extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final Function(int)? onNavigate;

  const TodayActivitySection({
    super.key,
    this.isDarkMode = false,
    this.onNavigate,
  });

  @override
  ConsumerState<TodayActivitySection> createState() =>
      _TodayActivitySectionState();
}

class _TodayActivitySectionState extends ConsumerState<TodayActivitySection>
    with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  final UserProfileService _userProfileService = UserProfileService();
  final NutritionService _nutritionService = NutritionService();

  ActivityData? _activityData;
  UserProfile? _userProfile;
  bool _isLoading = true;

  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _loadActivityData();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToWorkout() {
    HapticFeedback.lightImpact();
    widget.onNavigate?.call(2);
  }

  void _navigateToDiet() {
    HapticFeedback.lightImpact();
    widget.onNavigate?.call(1);
  }

  void _navigateToSteps() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ActiveTrackingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final workoutState = ref.watch(workoutProvider);
    final completedCount = workoutState.value?.completedWorkoutIds.length ?? 0;
    final totalWorkoutsCount = workoutState.value?.todayWorkouts.length ?? 0;

    if (_isLoading) {
      return _buildLoadingState();
    }

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final slideValue = Curves.easeOutCubic.transform(
          _entranceController.value,
        );
        final fadeValue = Curves.easeOut.transform(_entranceController.value);

        return Transform.translate(
          offset: Offset(0, 16 * (1 - slideValue)),
          child: Opacity(opacity: fadeValue, child: child),
        );
      },
      child: StreamBuilder<ActivityData?>(
        stream: _activityService.streamTodayActivity(),
        builder: (context, activitySnapshot) {
          return StreamBuilder<DailyNutrition?>(
            stream: _nutritionService.streamDailyNutrition(DateTime.now()),
            builder: (context, nutritionSnapshot) {
              final activityData = activitySnapshot.data;
              final nutritionData = nutritionSnapshot.data;

              final workouts = completedCount;
              final dailyWorkoutGoal =
                  (_userProfile?.weeklyWorkoutGoal ?? 5) > 0
                  ? ((_userProfile?.weeklyWorkoutGoal ?? 5) / 7).ceil()
                  : 1;
              final totalWorkouts =
                  math.max(dailyWorkoutGoal, totalWorkoutsCount) > 0
                  ? math.max(dailyWorkoutGoal, totalWorkoutsCount)
                  : 1;

              final calories = nutritionData?.totalCalories ?? 0;
              final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;

              final steps = activityData?.steps ?? 0;
              final stepGoal = 10000;

              return _buildContent(
                workouts: workouts,
                totalWorkouts: totalWorkouts,
                calories: calories,
                calorieGoal: calorieGoal,
                steps: steps,
                stepGoal: stepGoal,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required int workouts,
    required int totalWorkouts,
    required int calories,
    required int calorieGoal,
    required int steps,
    required int stepGoal,
  }) {
    final isDark = widget.isDarkMode;

    final containerBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
    final headerColor = isDark ? Colors.white54 : Colors.black45;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.grey.shade200;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(22)),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Today's Activity",
                style: TextStyle(
                  fontSize: SizeConfig.sp(14),
                  fontWeight: FontWeight.w600,
                  color: headerColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),

          Divider(color: dividerColor, height: SizeConfig.h(22)),

          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _MetricCard(
                    label: "Workouts",
                    value: workouts,
                    goal: totalWorkouts,
                    suffix: "done",
                    icon: Icons.fitness_center_rounded,
                    iconColor: const Color(0xFFFF9500),
                    onTap: _navigateToWorkout,
                    isDarkMode: isDark,
                    isFeatured: true,
                  ),
                ),

                SizedBox(width: SizeConfig.w(10)),

                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: "Calories",
                          value: calories,
                          goal: calorieGoal,
                          suffix: "kcal",
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFF34C759),
                          onTap: _navigateToDiet,
                          isDarkMode: isDark,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(10)),
                      Expanded(
                        child: _MetricCard(
                          label: "Steps",
                          value: steps,
                          goal: stepGoal,
                          suffix: "steps",
                          icon: Icons.directions_walk_rounded,
                          iconColor: const Color(0xFF007AFF),
                          onTap: _navigateToSteps,
                          isDarkMode: isDark,
                        ),
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

  Widget _buildLoadingState() {
    final isDark = widget.isDarkMode;
    return Container(
      height: SizeConfig.h(180),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.w(22)),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: BouncingDotsIndicator(
          color: isDark ? Colors.white54 : Colors.black38,
        ),
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final String label;
  final int value;
  final int goal;
  final String suffix;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isDarkMode;
  final bool isFeatured;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.suffix,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.isDarkMode,
    this.isFeatured = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;
  late Animation<int> _countAnim;

  double _scale = 1.0;
  int _prevValue = 0;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  void _setupAnimations() {
    final pct = (widget.value / widget.goal).clamp(0.0, 1.0);

    _progressAnim = Tween<double>(begin: 0, end: pct).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _countAnim = IntTween(begin: _prevValue, end: widget.value).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(_MetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.goal != widget.goal) {
      _prevValue = oldWidget.value;
      _setupAnimations();
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatValue(int val) {
    if (widget.label == "Steps" && val >= 1000) {
      return "${(val / 1000).toStringAsFixed(1)}k";
    }
    return "$val";
  }

  String _formatGoal(int goal) {
    if (widget.label == "Steps" && goal >= 1000) {
      return "${(goal / 1000).toStringAsFixed(0)}k";
    }
    return "$goal";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final cardBg = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100;
    final primaryText = isDark ? Colors.white : Colors.black;
    final secondaryText = isDark ? Colors.white60 : Colors.black54;
    final tertiaryText = isDark ? Colors.white38 : Colors.black38;
    final progressBg = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.08);
    final progressFill = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.all(SizeConfig.w(widget.isFeatured ? 14 : 12)),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(SizeConfig.w(16)),
          ),
          child: widget.isFeatured
              ? _buildFeaturedLayout(
                  primaryText,
                  secondaryText,
                  tertiaryText,
                  progressBg,
                  progressFill,
                )
              : _buildCompactLayout(
                  primaryText,
                  secondaryText,
                  tertiaryText,
                  progressBg,
                  progressFill,
                ),
        ),
      ),
    );
  }

  Widget _buildFeaturedLayout(
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
    Color progressBg,
    Color progressFill,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: SizeConfig.w(16), color: widget.iconColor),
            SizedBox(width: SizeConfig.w(8)),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: SizeConfig.sp(10),
                fontWeight: FontWeight.w700,
                color: tertiaryText,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),

        const Spacer(),

        AnimatedBuilder(
          animation: _countAnim,
          builder: (context, _) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _formatValue(_countAnim.value),
                  style: TextStyle(
                    fontSize: SizeConfig.sp(42),
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                    height: 1,
                    letterSpacing: -1.5,
                  ),
                ),
                Text(
                  " /${widget.goal}",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(14),
                    fontWeight: FontWeight.w500,
                    color: tertiaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(width: SizeConfig.w(6)),
                Padding(
                  padding: EdgeInsets.only(bottom: SizeConfig.h(2)),
                  child: Text(
                    widget.suffix,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(12),
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        SizedBox(height: SizeConfig.h(10)),

        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 4,
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: _progressAnim.value,
                  backgroundColor: progressBg,
                  valueColor: AlwaysStoppedAnimation(progressFill),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(
    Color primaryText,
    Color secondaryText,
    Color tertiaryText,
    Color progressBg,
    Color progressFill,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: SizeConfig.w(14), color: widget.iconColor),
            SizedBox(width: SizeConfig.w(6)),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: SizeConfig.sp(9),
                fontWeight: FontWeight.w700,
                color: tertiaryText,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),

        SizedBox(height: SizeConfig.h(10)),

        AnimatedBuilder(
          animation: _countAnim,
          builder: (context, _) {
            String displayVal = _formatValue(_countAnim.value);
            String goalVal = _formatGoal(widget.goal);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayVal,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(20),
                        fontWeight: FontWeight.w700,
                        color: primaryText,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "/$goalVal",
                      style: TextStyle(
                        fontSize: SizeConfig.sp(10),
                        fontWeight: FontWeight.w500,
                        color: tertiaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(2)),
                Text(
                  widget.suffix,
                  style: TextStyle(
                    fontSize: SizeConfig.sp(9),
                    fontWeight: FontWeight.w500,
                    color: secondaryText,
                  ),
                ),
              ],
            );
          },
        ),

        SizedBox(height: SizeConfig.h(8)),

        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: AnimatedBuilder(
              animation: _progressAnim,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: _progressAnim.value,
                  backgroundColor: progressBg,
                  valueColor: AlwaysStoppedAnimation(progressFill),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
