import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyDaysBar extends StatefulWidget {
  final Color bgColor;
  final Color acColor;
  final bool isDarkMode;

  const WeeklyDaysBar({
    super.key,
    required this.bgColor,
    required this.acColor,
    this.isDarkMode = false,
  });

  @override
  State<WeeklyDaysBar> createState() => _WeeklyDaysBarState();
}

class _WeeklyDaysBarState extends State<WeeklyDaysBar> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final double tileWidth = availableWidth / 8;
        final double tileHeight = tileWidth * 2.2;

        return Center(
          child: SizedBox(
            height: tileHeight + 20,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              separatorBuilder: (_, __) => SizedBox(width: tileWidth * 0.08),
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday =
                    DateFormat('yyyy-MM-dd').format(day) ==
                    DateFormat('yyyy-MM-dd').format(now);

                final double scale = isToday ? 1.15 : 1.0;

                final Color textColor = isToday
                    ? widget.acColor
                    : (widget.isDarkMode
                          ? Colors.white70
                          : Colors.grey.shade700);
                final Color circleColor = isToday
                    ? widget.bgColor
                    : (widget.isDarkMode ? Color(0xFF121212) : Colors.white);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: tileWidth * scale,
                  height: tileHeight * scale,
                  decoration: BoxDecoration(
                    color: circleColor,
                    borderRadius: BorderRadius.circular(tileWidth),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat(
                          'E',
                        ).format(day).substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: isToday ? 13 : 11,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          fontSize: isToday ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
