import 'package:flutter/material.dart';
import '../../models/nutrition_model.dart';
import '../../utils/size_config.dart';
import 'macro_progress_bar.dart';

class NutritionDashboardCard extends StatelessWidget {
  final DailyNutrition dailyNutrition;
  final bool isDarkMode;

  const NutritionDashboardCard({
    super.key,
    required this.dailyNutrition,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final calorieProgress = dailyNutrition.goal.dailyCalories > 0
        ? (dailyNutrition.totalCalories / dailyNutrition.goal.dailyCalories)
              .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(16),
        vertical: SizeConfig.h(8),
      ),
      padding: EdgeInsets.all(SizeConfig.w(18)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(20)),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nutrition',
            style: TextStyle(
              fontSize: SizeConfig.sp(18),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: SizeConfig.h(16)),

          Row(
            children: [
              SizedBox(
                width: SizeConfig.w(100),
                height: SizeConfig.w(100),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: SizeConfig.w(100),
                      height: SizeConfig.w(100),
                      child: CircularProgressIndicator(
                        value: calorieProgress,
                        strokeWidth: SizeConfig.w(10),
                        backgroundColor: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color.fromRGBO(206, 242, 75, 1),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${dailyNutrition.totalCalories}',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(24),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(12),
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.w(20)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal: ${dailyNutrition.goal.dailyCalories} kcal',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(13),
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(4)),
                    Text(
                      '${dailyNutrition.goal.dailyCalories - dailyNutrition.totalCalories} kcal remaining',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(10),
                        vertical: SizeConfig.h(4),
                      ),
                      decoration: BoxDecoration(
                        color: dailyNutrition.calorieGoalMet
                            ? const Color.fromRGBO(206, 242, 75, 0.2)
                            : (isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                      ),
                      child: Text(
                        dailyNutrition.calorieGoalMet
                            ? 'On Track'
                            : 'Keep Going',
                        style: TextStyle(
                          fontSize: SizeConfig.sp(11),
                          fontWeight: FontWeight.w600,
                          color: dailyNutrition.calorieGoalMet
                              ? const Color.fromRGBO(206, 242, 75, 1)
                              : subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(20)),

          MacroProgressBar(
            label: 'Protein',
            current: dailyNutrition.totalMacros.protein,
            goal: dailyNutrition.goal.protein,
            color: const Color(0xFF4A90E2),
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(12)),
          MacroProgressBar(
            label: 'Carbs',
            current: dailyNutrition.totalMacros.carbs,
            goal: dailyNutrition.goal.carbs,
            color: const Color.fromRGBO(206, 242, 75, 1),
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(12)),
          MacroProgressBar(
            label: 'Fats',
            current: dailyNutrition.totalMacros.fats,
            goal: dailyNutrition.goal.fats,
            color: const Color(0xFFFF9500),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
