import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class FitnessGoalsCard extends StatelessWidget {
  final bool isDarkMode;
  final int weeklyWorkoutGoal;
  final int currentWeeklyWorkouts;
  final int dailyCalorieGoal;
  final int currentCalories;
  final double? weightGoal;
  final double currentWeight;
  final VoidCallback? onEditGoals;

  const FitnessGoalsCard({
    super.key,
    required this.isDarkMode,
    required this.weeklyWorkoutGoal,
    required this.currentWeeklyWorkouts,
    required this.dailyCalorieGoal,
    required this.currentCalories,
    this.weightGoal,
    required this.currentWeight,
    this.onEditGoals,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final workoutProgress = (currentWeeklyWorkouts / weeklyWorkoutGoal).clamp(
      0.0,
      1.0,
    );
    final calorieProgress = (currentCalories / dailyCalorieGoal).clamp(
      0.0,
      1.0,
    );
    final weightProgress = weightGoal != null
        ? ((currentWeight - weightGoal!) / currentWeight).abs().clamp(0.0, 1.0)
        : null;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalItem(
            icon: Icons.fitness_center_rounded,
            label: 'Weekly Workouts',
            current: currentWeeklyWorkouts,
            goal: weeklyWorkoutGoal,
            progress: workoutProgress,
            color: const Color(0xFFCEF24B),
            textColor: textColor,
            subTextColor: subTextColor,
          ),

          SizedBox(height: SizeConfig.h(16)),

          _buildGoalItem(
            icon: Icons.local_fire_department,
            label: 'Daily Calories',
            current: currentCalories,
            goal: dailyCalorieGoal,
            progress: calorieProgress,
            color: const Color(0xFF0EA5E9),
            textColor: textColor,
            subTextColor: subTextColor,
          ),

          if (weightGoal != null) ...[
            SizedBox(height: SizeConfig.h(16)),
            _buildWeightGoalItem(
              currentWeight: currentWeight,
              goalWeight: weightGoal!,
              progress: weightProgress!,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalItem({
    required IconData icon,
    required String label,
    required int current,
    required int goal,
    required double progress,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.w(8)),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: SizeConfig.sp(16), color: color),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(14),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    '$current / $goal',
                    style: TextStyle(
                      fontSize: SizeConfig.sp(12),
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: SizeConfig.sp(14),
                fontWeight: FontWeight.w700,
                color: progress >= 1.0 ? Colors.green : color,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(10)),
        ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.w(8)),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: SizeConfig.h(8),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightGoalItem({
    required double currentWeight,
    required double goalWeight,
    required double progress,
    required Color textColor,
    required Color subTextColor,
  }) {
    final difference = (currentWeight - goalWeight).abs();
    final isGaining = goalWeight > currentWeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(SizeConfig.w(8)),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.monitor_weight_rounded,
                size: SizeConfig.sp(16),
                color: Colors.purple,
              ),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weight Goal',
                    style: TextStyle(
                      fontSize: SizeConfig.sp(14),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    '${currentWeight.toStringAsFixed(1)} Ã¢â€ â€™ ${goalWeight.toStringAsFixed(1)} kg',
                    style: TextStyle(
                      fontSize: SizeConfig.sp(12),
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${difference.toStringAsFixed(1)} kg ${isGaining ? 'to gain' : 'to lose'}',
              style: TextStyle(
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(10)),
        ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.w(8)),
          child: LinearProgressIndicator(
            value: 1.0 - progress,
            backgroundColor: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: SizeConfig.h(8),
          ),
        ),
      ],
    );
  }
}
