import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/models/nutrition_model.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/components/shared/circular_progress.dart';
import 'macro_progress_bar.dart';

class AnimatedNutritionCard extends StatelessWidget {
  final DailyNutrition nutrition;
  final bool isDarkMode;
  final bool isHistory;

  const AnimatedNutritionCard({
    super.key,
    required this.nutrition,
    required this.isDarkMode,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isHistory
        ? (isDarkMode ? const Color(0xFF4C3418) : const Color(0xFFFFF8E1))
        : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.white);

    final borderColor = isHistory
        ? (isDarkMode
              ? Colors.amber.withOpacity(0.3)
              : Colors.amber.withOpacity(0.5))
        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final accentColor = isHistory ? Colors.amber : Colors.blue;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHistory ? 'Nutrition Record' : 'Daily Nutrition',
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              if (isHistory)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "HISTORY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: SizeConfig.h(20)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DietCircularProgress(
                totalKcal: nutrition.goal.dailyCalories.toDouble(),
                consumedKcal: nutrition.totalCalories.toDouble(),
                burnedKcal: 0,
                isDarkMode: isDarkMode,
                diameter: SizeConfig.w(130),
              ),

              SizedBox(width: SizeConfig.w(20)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${nutrition.totalCalories}',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(32),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(4)),
                        Flexible(
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(14),
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Goal: ${nutrition.goal.dailyCalories}',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(13),
                        color: subTextColor,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(12)),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(10),
                        vertical: SizeConfig.h(5),
                      ),
                      decoration: BoxDecoration(
                        color: nutrition.calorieGoalMet
                            ? Colors.green.withOpacity(0.15)
                            : accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                      ),
                      child: Text(
                        nutrition.calorieGoalMet
                            ? 'Goal Met!'
                            : (isHistory ? 'Ended' : 'On Track'),
                        style: TextStyle(
                          fontSize: SizeConfig.sp(12),
                          fontWeight: FontWeight.w700,
                          color: nutrition.calorieGoalMet
                              ? Colors.green
                              : accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(24)),

          MacroProgressBar(
            label: 'Protein',
            current: nutrition.totalMacros.protein,
            goal: nutrition.goal.protein,
            color: accentColor,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(12)),
          MacroProgressBar(
            label: 'Carbs',
            current: nutrition.totalMacros.carbs,
            goal: nutrition.goal.carbs,
            color: accentColor,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(12)),
          MacroProgressBar(
            label: 'Fats',
            current: nutrition.totalMacros.fats,
            goal: nutrition.goal.fats,
            color: accentColor,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
