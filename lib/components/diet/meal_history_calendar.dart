import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/size_config.dart';
import '../../models/nutrition_model.dart';

class MealHistoryCalendar extends StatefulWidget {
  final bool isDarkMode;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? minDate;
  final Map<DateTime, DailyNutrition>? historyData;

  const MealHistoryCalendar({
    super.key,
    required this.isDarkMode,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.historyData,
  });

  @override
  State<MealHistoryCalendar> createState() => _MealHistoryCalendarState();
}

class _MealHistoryCalendarState extends State<MealHistoryCalendar> {
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white54 : Colors.black54;

    final today = DateTime.now();
    DateTime startDate = today.subtract(const Duration(days: 13));

    if (widget.minDate != null && widget.minDate!.isAfter(startDate)) {
      startDate = widget.minDate!;
    }
    if (startDate.isAfter(today)) startDate = today;

    final totalDays = today.difference(startDate).inDays + 1;

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
            itemCount: 14,
            reverse: true,
            itemBuilder: (context, index) {
              final date = today.subtract(Duration(days: index));

              final bool isBeforeCreation =
                  widget.minDate != null &&
                  date.isBefore(widget.minDate!) &&
                  !_isSameDay(date, widget.minDate!);

              final bool isFuture = date.isAfter(today);

              final bool isDisabled = isBeforeCreation || isFuture;

              final isSelected = _isSameDay(date, widget.selectedDate);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  if (isDisabled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFuture
                              ? "You can't travel to the future! 🚀"
                              : "Account hadn't been created yet!",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: Colors.black,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(20),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else {
                    widget.onDateSelected(date);
                  }
                },
                child: Opacity(
                  opacity: isDisabled ? 0.4 : 1.0,
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
                          DateFormat('E').format(date),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getGoalStatusColor(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (widget.historyData != null) {
      if (widget.historyData!.containsKey(normalizedDate)) {
        final data = widget.historyData![normalizedDate]!;
        if (data.calorieGoalMet) return Colors.green;
        if (data.meals.isNotEmpty) return Colors.orange;
        return Colors.red.withOpacity(0.5);
      }
    }

    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    if (normalizedDate.isAfter(normalizedNow)) return Colors.transparent;

    if (widget.minDate != null) {
      final normalizedMin = DateTime(
        widget.minDate!.year,
        widget.minDate!.month,
        widget.minDate!.day,
      );
      if (normalizedDate.isBefore(normalizedMin)) return Colors.transparent;
    }

    return Colors.red.withOpacity(0.5);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
