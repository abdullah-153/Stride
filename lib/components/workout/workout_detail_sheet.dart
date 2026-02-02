import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import '../../utils/size_config.dart';
import 'exercise_list_item.dart';

class WorkoutDetailSheet extends StatelessWidget {
  final Workout workout;
  final bool isDarkMode;
  final VoidCallback? onStartWorkout;

  const WorkoutDetailSheet({
    super.key,
    required this.workout,
    this.isDarkMode = false,
    this.onStartWorkout,
  });

  static Future<void> show(
    BuildContext context,
    Workout workout, {
    bool isDarkMode = false,
    VoidCallback? onStartWorkout,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutDetailSheet(
        workout: workout,
        isDarkMode: isDarkMode,
        onStartWorkout: onStartWorkout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;
    final accentColor = const Color.fromRGBO(206, 242, 75, 1);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.w(24)),
              topRight: Radius.circular(SizeConfig.w(24)),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: SizeConfig.h(12)),
                width: SizeConfig.w(40),
                height: SizeConfig.h(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(SizeConfig.w(2)),
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(SizeConfig.w(20)),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workout.title,
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(28),
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(8)),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.w(10),
                                      vertical: SizeConfig.h(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(
                                        SizeConfig.w(8),
                                      ),
                                      border: Border.all(
                                        color: accentColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      workout.category.displayName
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: SizeConfig.sp(10),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: SizeConfig.w(8)),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.w(10),
                                      vertical: SizeConfig.h(4),
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.white12
                                          : Colors.black12,
                                      borderRadius: BorderRadius.circular(
                                        SizeConfig.w(8),
                                      ),
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
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.h(20)),

                    Container(
                      padding: EdgeInsets.all(SizeConfig.w(16)),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2C2C2E)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value: '${workout.durationMinutes} min',
                            isDarkMode: isDarkMode,
                          ),
                          Container(
                            width: 1,
                            height: SizeConfig.h(40),
                            color: borderColor,
                          ),
                          _StatItem(
                            icon: Icons.local_fire_department_outlined,
                            label: 'Calories',
                            value: '${workout.caloriesBurned}',
                            isDarkMode: isDarkMode,
                          ),
                          Container(
                            width: 1,
                            height: SizeConfig.h(40),
                            color: borderColor,
                          ),
                          _StatItem(
                            icon: Icons.star_outline_rounded,
                            label: 'Points',
                            value: '${workout.points}',
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    Text(
                      workout.description,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(14),
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(18),
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '${workout.exerciseCount} exercises',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(14),
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.h(12)),

                    ...workout.exercises.map((exercise) {
                      return ExerciseListItem(
                        exercise: exercise,
                        isDarkMode: isDarkMode,
                      );
                    }),

                    SizedBox(height: SizeConfig.h(80)),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(SizeConfig.w(20)),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(top: BorderSide(color: borderColor, width: 1)),
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onStartWorkout?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.white : Colors.black,
                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: SizeConfig.w(24)),
                        SizedBox(width: SizeConfig.w(8)),
                        Text(
                          'Start Workout',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.grey.shade600;

    return Column(
      children: [
        Icon(icon, size: SizeConfig.w(24), color: subTextColor),
        SizedBox(height: SizeConfig.h(6)),
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.sp(16),
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: SizeConfig.sp(11), color: subTextColor),
        ),
      ],
    );
  }
}
