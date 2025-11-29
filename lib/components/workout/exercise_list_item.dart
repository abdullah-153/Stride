import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../utils/workout_colors.dart';
import '../../utils/size_config.dart';

class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final bool isDarkMode;
  final bool isCompleted;
  final VoidCallback? onToggle;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    this.isDarkMode = false,
    this.isCompleted = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.grey.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
      padding: EdgeInsets.all(SizeConfig.w(14)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox (if onToggle provided)
          if (onToggle != null) ...[
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: SizeConfig.w(24),
                height: SizeConfig.w(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? WorkoutColors.accent
                        : (isDarkMode ? Colors.white38 : Colors.grey.shade400),
                    width: 2,
                  ),
                  color: isCompleted
                      ? WorkoutColors.accent
                      : Colors.transparent,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: SizeConfig.w(16),
                        color: Colors.black,
                      )
                    : null,
              ),
            ),
            SizedBox(width: SizeConfig.w(12)),
          ],

          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: SizeConfig.sp(15),
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: SizeConfig.h(4)),
                Row(
                  children: [
                    // Reps/Sets/Duration info
                    if (exercise.displayText.isNotEmpty) ...[
                      Icon(
                        _getExerciseIcon(),
                        size: SizeConfig.w(14),
                        color: subTextColor,
                      ),
                      SizedBox(width: SizeConfig.w(4)),
                      Text(
                        exercise.displayText,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(13),
                          color: subTextColor,
                        ),
                      ),
                    ],
                    // Muscle groups
                    if (exercise.muscleGroups.isNotEmpty) ...[
                      if (exercise.displayText.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(6),
                          ),
                          child: Text(
                            '•',
                            style: TextStyle(color: subTextColor),
                          ),
                        ),
                      Expanded(
                        child: Wrap(
                          spacing: SizeConfig.w(4),
                          runSpacing: SizeConfig.h(4),
                          children: exercise.muscleGroups.take(2).map((muscle) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(6),
                                vertical: SizeConfig.h(2),
                              ),
                              decoration: BoxDecoration(
                                color: WorkoutColors.getMuscleGroupColor(
                                  muscle,
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  SizeConfig.w(8),
                                ),
                              ),
                              child: Text(
                                muscle,
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(11),
                                  color: WorkoutColors.getMuscleGroupColor(
                                    muscle,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
                if (exercise.notes != null) ...[
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    exercise.notes!,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(12),
                      color: subTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon() {
    if (exercise.sets != null && exercise.reps != null) {
      return Icons.repeat_rounded;
    } else if (exercise.durationSeconds != null) {
      return Icons.timer_outlined;
    } else if (exercise.reps != null) {
      return Icons.fitness_center_outlined;
    }
    return Icons.info_outline;
  }
}
