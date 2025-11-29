import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/size_config.dart';

class MealHistoryCalendar extends StatefulWidget {
  final bool isDarkMode;
  final DateTime selectedDate; // Added selectedDate
  final Function(DateTime) onDateSelected;

  const MealHistoryCalendar({
    super.key,
    required this.isDarkMode,
    required this.selectedDate, // Require it
    required this.onDateSelected,
  });

  @override
  State<MealHistoryCalendar> createState() => _MealHistoryCalendarState();
}

class _MealHistoryCalendarState extends State<MealHistoryCalendar> {
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    // Start from 3 days ago to show some history + today + future
    _startDate = DateTime.now().subtract(const Duration(days: 3));
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white54 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: SizeConfig.sp(20),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: subTextColor,
                size: SizeConfig.w(20),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.h(16)),
        SizedBox(
          height: SizeConfig.h(85),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(12)),
            itemCount: 14, // Show 2 weeks
            itemBuilder: (context, index) {
              final date = _startDate.add(Duration(days: index));
              final isSelected = _isSameDay(
                date,
                widget.selectedDate,
              ); // Use widget.selectedDate
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(date); // Just notify parent
                },
                child: Container(
                  width: SizeConfig.w(60),
                  margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(4)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : (widget.isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                    border: isToday && !isSelected
                        ? Border.all(color: Colors.blue, width: 1.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date), // Mon, Tue...
                        style: TextStyle(
                          fontSize: SizeConfig.sp(12),
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : subTextColor,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: SizeConfig.sp(18),
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(4)),
                      // Goal indicator dot
                      Container(
                        width: SizeConfig.w(6),
                        height: SizeConfig.w(6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.5)
                              : _getGoalStatusColor(date),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getGoalStatusColor(DateTime date) {
    // Mock logic for goal status
    // In a real app, this would check the DailyNutrition data
    if (date.isAfter(DateTime.now())) return Colors.transparent;

    final random = date.day % 3;
    if (random == 0) return Colors.green; // Met
    if (random == 1) return Colors.orange; // Close
    return Colors.red.withOpacity(0.5); // Missed
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
