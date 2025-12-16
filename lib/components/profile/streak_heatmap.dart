import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/size_config.dart';

class StreakHeatMap extends StatelessWidget {
  final List<DateTime> activityDates;
  final bool isDarkMode;

  const StreakHeatMap({
    super.key,
    required this.activityDates,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    final activtySet = activityDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black45;
    final boxColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final activeColor =
        Colors.green; // GitHub green, or use app theme (Lime/Blue)?

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Activity Log",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(16),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(now),
                    style: TextStyle(
                      fontSize: SizeConfig.sp(12),
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "${_calculateMonthlyStreak(now, activtySet)} days",
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(20)),

          LayoutBuilder(
            builder: (context, constraints) {

              const int columns = 7;
              final double gap = SizeConfig.w(6);
              final double availableWidth = constraints.maxWidth;
              final double itemSize =
                  (availableWidth - (gap * (columns - 1))) / columns;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  childAspectRatio: 1,
                ),
                itemCount:
                    daysInMonth +
                    startOfMonth.weekday -
                    1, // Add offset for starting weekday
                itemBuilder: (context, index) {
                  final offset = startOfMonth.weekday - 1;

                  if (index < offset) {
                    return const SizedBox(); // Empty slot
                  }

                  final day = index - offset + 1;
                  final date = DateTime(now.year, now.month, day);
                  final isActive = activtySet.contains(date);

                  return Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(
                              0xFFCEF24B,
                            ) // Lime (Premium/Workout theme)
                          : boxColor,
                      borderRadius: BorderRadius.circular(SizeConfig.w(6)),
                    ),
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(10),
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? Colors.black : subTextColor,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  int _calculateMonthlyStreak(DateTime now, Set<DateTime> activitySet) {
    int count = 0;
    for (int i = 1; i <= now.day; i++) {
      if (activitySet.contains(DateTime(now.year, now.month, i))) {
        count++;
      }
    }
    return count;
  }
}
