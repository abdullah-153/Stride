import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../utils/size_config.dart';

class WorkoutDiscoveryCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback? onAddToPlan;
  final bool isDarkMode;

  const WorkoutDiscoveryCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.onAddToPlan,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final accentColor = const Color.fromRGBO(206, 242, 75, 1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: SizeConfig.w(12)),
        width: SizeConfig.w(280),
        padding: EdgeInsets.all(SizeConfig.w(16)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(8),
                    vertical: SizeConfig.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    workout.category.displayName.toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: SizeConfig.sp(10),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // Difficulty
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(8),
                    vertical: SizeConfig.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                    borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                  ),
                  child: Text(
                    workout.difficulty.displayName,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: SizeConfig.sp(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.h(12)),

            // Title
            Text(
              workout.title,
              style: TextStyle(
                color: textColor,
                fontSize: SizeConfig.sp(18),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: SizeConfig.h(8)),

            // Stats row
            Row(
              children: [
                Flexible(
                  child: _StatItem(
                    icon: Icons.timer_outlined,
                    text: '${workout.durationMinutes}m',
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                Flexible(
                  child: _StatItem(
                    icon: Icons.local_fire_department_outlined,
                    text: '${workout.caloriesBurned}',
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                Flexible(
                  child: _StatItem(
                    icon: Icons.fitness_center_outlined,
                    text: '${workout.exerciseCount}',
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.h(12)),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onAddToPlan,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textColor,
                      side: BorderSide(color: borderColor, width: 1),
                      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.w(10)),
                      ),
                    ),
                    child: Text(
                      'Add to Plan',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                Container(
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(SizeConfig.w(10)),
                  ),
                  child: IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: SizeConfig.w(18),
                    ),
                    padding: EdgeInsets.all(SizeConfig.w(8)),
                    constraints: BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDarkMode;

  const _StatItem({
    required this.icon,
    required this.text,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: subTextColor, size: SizeConfig.w(14)),
        SizedBox(width: SizeConfig.w(4)),
        Text(
          text,
          style: TextStyle(
            color: subTextColor,
            fontSize: SizeConfig.sp(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
