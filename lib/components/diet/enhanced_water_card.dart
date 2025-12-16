import 'package:flutter/material.dart';
import '../../models/nutrition_model.dart';
import '../../utils/size_config.dart';
import 'package:flutter/services.dart';

class EnhancedWaterCard extends StatelessWidget {
  final DailyNutrition dailyNutrition;
  final Function(int) onAddWater;
  final bool isDarkMode;

  const EnhancedWaterCard({
    super.key,
    required this.dailyNutrition,
    required this.onAddWater,
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
    final buttonBg = isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.grey.shade100;

    final waterProgress = dailyNutrition.goal.waterGoal > 0
        ? (dailyNutrition.waterIntake / dailyNutrition.goal.waterGoal).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    final hydrationPercent = (waterProgress * 100).toInt();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Intake',
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(10),
                  vertical: SizeConfig.h(4),
                ),
                decoration: BoxDecoration(
                  color: waterProgress >= 1.0
                      ? const Color.fromRGBO(206, 242, 75, 0.2)
                      : (isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                ),
                child: Text(
                  '$hydrationPercent%',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(12),
                    fontWeight: FontWeight.w700,
                    color: waterProgress >= 1.0
                        ? const Color.fromRGBO(206, 242, 75, 1)
                        : subTextColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(16)),

          Row(
            children: [
              SizedBox(
                width: SizeConfig.w(80),
                height: SizeConfig.w(80),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: SizeConfig.w(80),
                      height: SizeConfig.w(80),
                      child: CircularProgressIndicator(
                        value: waterProgress,
                        strokeWidth: SizeConfig.w(8),
                        backgroundColor: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.water_drop,
                      size: SizeConfig.w(32),
                      color: const Color(0xFF4A90E2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeConfig.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${dailyNutrition.waterIntake}',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(28),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(4)),
                        Padding(
                          padding: EdgeInsets.only(bottom: SizeConfig.h(4)),
                          child: Text(
                            'ml',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(14),
                              fontWeight: FontWeight.w600,
                              color: subTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.h(2)),
                    Text(
                      'Goal: ${dailyNutrition.goal.waterGoal} ml',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(16)),

          Text(
            'Quick Add',
            style: TextStyle(
              fontSize: SizeConfig.sp(13),
              fontWeight: FontWeight.w600,
              color: subTextColor,
            ),
          ),
          SizedBox(height: SizeConfig.h(8)),

          Row(
            children: [
              _QuickAddButton(
                label: '250ml',
                amount: 250,
                onTap: () => onAddWater(250),
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: SizeConfig.w(8)),
              _QuickAddButton(
                label: '500ml',
                amount: 500,
                onTap: () => onAddWater(500),
                isDarkMode: isDarkMode,
              ),
              SizedBox(width: SizeConfig.w(8)),
              _QuickAddButton(
                label: '1L',
                amount: 1000,
                onTap: () => onAddWater(1000),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final int amount;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _QuickAddButton({
    required this.label,
    required this.amount,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBg = isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.grey.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.1);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
          child: Ink(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.h(14)),
            decoration: BoxDecoration(
              color: buttonBg,
              borderRadius: BorderRadius.circular(SizeConfig.w(16)),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: isDarkMode
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: SizeConfig.w(20),
                  color: const Color(0xFF4A90E2),
                ),
                SizedBox(height: SizeConfig.h(6)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: SizeConfig.sp(13),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
