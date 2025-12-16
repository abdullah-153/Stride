import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class StreakProgress extends StatelessWidget {
  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;

  final bool isDarkMode;
  final int streakDays;
  final DateTime? lastDietLogDate;
  final DateTime? lastWorkoutLogDate;

  const StreakProgress({
    super.key,
    this.isDarkMode = false,
    required this.streakDays,
    this.lastDietLogDate,
    this.lastWorkoutLogDate,
    required this.currentLevel,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    final containerBgColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final borderColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final shadowColor = isDarkMode
        ? Colors.white.withOpacity(0.02)
        : Colors.black.withOpacity(0.04);
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final dividerColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStreakHeader(secondaryTextColor),
          Divider(color: dividerColor, height: SizeConfig.h(25)),
          _buildWeekTracker(),
          SizedBox(height: SizeConfig.h(15)),
          _buildTotalStreakCount(primaryTextColor, secondaryTextColor),
          Divider(color: dividerColor, height: SizeConfig.h(30)),
          _buildLevelProgress(primaryTextColor, secondaryTextColor, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStreakHeader(Color secondaryColor) {
    final today = DateTime.now();
    final isDietDone =
        lastDietLogDate != null &&
        lastDietLogDate!.year == today.year &&
        lastDietLogDate!.month == today.month &&
        lastDietLogDate!.day == today.day;

    final isWorkoutDone =
        lastWorkoutLogDate != null &&
        lastWorkoutLogDate!.year == today.year &&
        lastWorkoutLogDate!.month == today.month &&
        lastWorkoutLogDate!.day == today.day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Global Streak',
              style: TextStyle(
                color: secondaryColor,
                fontSize: SizeConfig.sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: SizeConfig.w(4)),
            Icon(Icons.public, color: secondaryColor, size: SizeConfig.w(14)),
          ],
        ),
        Row(
          children: [
            _buildDailyIndicator(
              isDietDone,
              Icons.restaurant_menu_rounded,
              Colors.green,
            ),
            SizedBox(width: SizeConfig.w(8)),
            _buildDailyIndicator(
              isWorkoutDone,
              Icons.fitness_center_rounded,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyIndicator(bool isDone, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.w(4)),
      decoration: BoxDecoration(
        color: isDone ? color.withOpacity(0.2) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? color : Colors.grey.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: SizeConfig.w(12),
        color: isDone ? color : Colors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildWeekTracker() {
    final weekStatus = [
      'completed',
      'completed',
      'missed',
      'completed',
      'completed',
      'current',
      'future',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekStatus.map((status) => _buildDayCircle(status)).toList(),
    );
  }

  Widget _buildDayCircle(String status) {
    Color circleColor;
    Widget child;

    switch (status) {
      case 'completed':
        circleColor = Colors.blue;
        child = Icon(Icons.check, color: Colors.white, size: SizeConfig.w(16));
        break;
      case 'missed':
        circleColor = Colors.orange;
        child = Icon(Icons.close, color: Colors.white, size: SizeConfig.w(16));
        break;
      case 'current':
        circleColor = isDarkMode ? Colors.white : Colors.black;
        child = Container();
        break;
      default:
        circleColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
        child = Container();
    }

    return CircleAvatar(
      backgroundColor: circleColor,
      radius: SizeConfig.w(16),
      child: child,
    );
  }

  Widget _buildTotalStreakCount(Color primaryColor, Color secondaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$streakDays',
          style: TextStyle(
            color: primaryColor,
            fontSize: SizeConfig.sp(60),
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        SizedBox(width: SizeConfig.w(8)),
        Text(
          'days',
          style: TextStyle(
            color: secondaryColor,
            fontSize: SizeConfig.sp(20),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress(
    Color primaryColor,
    Color secondaryColor,
    bool isDarkMode,
  ) {
    final progress = currentXp / nextLevelXp;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LVL $currentLevel',
              style: TextStyle(
                color: primaryColor,
                fontSize: SizeConfig.sp(16),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentXp / $nextLevelXp XP',
              style: TextStyle(
                color: secondaryColor,
                fontSize: SizeConfig.sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(12)),
        Stack(
          children: [
            Container(
              height: SizeConfig.h(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(SizeConfig.w(8)),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: SizeConfig.h(24),
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(8)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Next Level: ${currentLevel + 1}',
              style: TextStyle(
                color: secondaryColor,
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
