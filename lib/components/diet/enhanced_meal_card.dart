import 'package:flutter/material.dart';
import '../../models/nutrition_model.dart';
import '../../utils/size_config.dart';
import 'package:flutter/services.dart';

class EnhancedMealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isDarkMode;
  final bool isHistory;

  const EnhancedMealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isDarkMode = false,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseBg = isDarkMode ? const Color(0xFF2C2C2E) : Colors.white;
    final cardBg = isHistory ? baseBg.withOpacity(0.6) : baseBg;

    final borderColor = isHistory
        ? (isDarkMode ? Colors.white10 : Colors.black12)
        : (isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.shade300);

    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final effectiveTextColor = isHistory
        ? textColor.withOpacity(0.7)
        : textColor;

    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();

            onTap?.call();
          },
          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
          child: Ink(
            padding: EdgeInsets.all(SizeConfig.w(14)),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(SizeConfig.w(16)),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: SizeConfig.w(50),
                  height: SizeConfig.w(50),
                  decoration: BoxDecoration(
                    color: _getMealTypeColor().withOpacity(
                      isHistory ? 0.1 : 0.2,
                    ),
                    borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                  ),
                  child: Icon(
                    _getMealTypeIcon(),
                    color: _getMealTypeColor().withOpacity(
                      isHistory ? 0.7 : 1.0,
                    ),
                    size: SizeConfig.w(24),
                  ),
                ),
                SizedBox(width: SizeConfig.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(15),
                          fontWeight: FontWeight.w700,
                          color: effectiveTextColor,
                          decoration: isHistory
                              ? TextDecoration.none
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: SizeConfig.h(4)),
                      Row(
                        children: [
                          Text(
                            '${meal.calories} kcal',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(13),
                              fontWeight: FontWeight.w600,
                              color: isHistory
                                  ? (const Color.fromRGBO(206, 242, 75, 0.7))
                                  : const Color.fromRGBO(206, 242, 75, 1),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(8)),
                          Text(
                            '•',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: SizeConfig.sp(12),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(8)),
                          Text(
                            'P: ${meal.macros.protein}g  C: ${meal.macros.carbs}g  F: ${meal.macros.fats}g',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(11),
                              fontWeight: FontWeight.w500,
                              color: subTextColor.withOpacity(
                                isHistory ? 0.6 : 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if ((onEdit != null || onDelete != null) && !isHistory)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: SizeConfig.w(20),
                      color: subTextColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        HapticFeedback.lightImpact();
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        HapticFeedback.mediumImpact();
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: textColor,
                              ),
                              const SizedBox(width: 8),
                              Text('Edit', style: TextStyle(color: textColor)),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                if (isHistory)
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: subTextColor.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor() {
    switch (meal.type) {
      case MealType.breakfast:
        return const Color(0xFFFF9500);
      case MealType.lunch:
        return const Color(0xFF4A90E2);
      case MealType.dinner:
        return const Color(0xFFFF6B6B);
      case MealType.snack:
        return const Color.fromRGBO(206, 242, 75, 1);
    }
  }

  IconData _getMealTypeIcon() {
    switch (meal.type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }
}
