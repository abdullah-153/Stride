import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import 'fluid_wave_progress.dart';

class StreakProgress extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    // Define colors based on the theme
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
          _buildBadgeProgress(primaryTextColor, secondaryTextColor),
          SizedBox(height: SizeConfig.h(15)),
          _buildCollectedBadges(primaryTextColor, isDarkMode),
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

  Widget _buildBadgeProgress(Color primaryColor, Color secondaryColor) {
    final currentStreak = streakDays;
    const requiredStreak = 10;
    final progress = currentStreak / requiredStreak;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next Badge: Newbie',
              style: TextStyle(
                color: primaryColor,
                fontSize: SizeConfig.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$currentStreak / $requiredStreak days',
              style: TextStyle(
                color: secondaryColor,
                fontSize: SizeConfig.sp(14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(8)),
        SizedBox(height: SizeConfig.h(8)),
        FluidWaveProgress(
          value: progress,
          height: SizeConfig.h(32), // Vertically larger
          borderRadius: SizeConfig.w(12), // Boxy capsule shape
          backgroundColor: isDarkMode
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          color: isDarkMode ? Colors.white : Colors.black,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildCollectedBadges(Color primaryColor, bool isDarkMode) {
    final iconColor = isDarkMode
        ? Colors.white.withOpacity(0.3)
        : Colors.black.withOpacity(0.2);
    return Row(
      children: [
        Text(
          'Badges',
          style: TextStyle(
            color: primaryColor,
            fontSize: SizeConfig.sp(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: SizeConfig.w(80),
          height: SizeConfig.h(30),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              // Placeholder for more badges
              Positioned(
                right: SizeConfig.w(30),
                child: Icon(
                  Icons.shield_rounded,
                  color: iconColor,
                  size: SizeConfig.w(28),
                ),
              ),
              Positioned(
                right: SizeConfig.w(15),
                child: Icon(
                  Icons.shield_rounded,
                  color: iconColor,
                  size: SizeConfig.w(28),
                ),
              ),
              // The most recent badge
              Positioned(
                right: 0,
                child: Icon(
                  Icons.shield_moon_rounded,
                  color: Colors.amber,
                  size: SizeConfig.w(28),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
