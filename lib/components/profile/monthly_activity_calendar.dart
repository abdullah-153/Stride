import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class MonthlyActivityCalendar extends StatefulWidget {
  final bool isDarkMode;
  final Map<DateTime, ActivityType> monthlyActivity; // Date -> Activity type
  final int currentStreak;

  const MonthlyActivityCalendar({
    super.key,
    required this.isDarkMode,
    required this.monthlyActivity,
    required this.currentStreak,
  });

  @override
  State<MonthlyActivityCalendar> createState() =>
      _MonthlyActivityCalendarState();
}

enum ActivityType { none, workout, meal, both }

class _MonthlyActivityCalendarState extends State<MonthlyActivityCalendar> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    final days = <DateTime>[];

    final firstWeekday = firstDay.weekday % 7; // 0 = Monday
    for (int i = 0; i < firstWeekday; i++) {
      days.add(firstDay.subtract(Duration(days: firstWeekday - i)));
    }

    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i + 1));
    }

    return days;
  }

  ActivityType _getActivityForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return widget.monthlyActivity[dateKey] ?? ActivityType.none;
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.workout:
        return const Color(0xFFCEF24B); // Lime
      case ActivityType.meal:
        return const Color(0xFF0EA5E9); // Blue
      case ActivityType.both:
        return Colors.purple;
      case ActivityType.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    final days = _getDaysInMonth();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final isCurrentMonth =
        _currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
        border: Border.all(color: borderColor, width: 1),
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
              Text(
                'Activity Calendar',
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: textColor),
                    onPressed: _previousMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  Text(
                    '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                    style: TextStyle(
                      fontSize: SizeConfig.sp(14),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(12)),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: isCurrentMonth
                          ? subTextColor.withOpacity(0.3)
                          : textColor,
                    ),
                    onPressed: isCurrentMonth ? null : _nextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(20)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays
                .map(
                  (day) => SizedBox(
                    width: SizeConfig.w(36),
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(10),
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          SizedBox(height: SizeConfig.h(12)),

          Wrap(
            spacing: SizeConfig.w(4),
            runSpacing: SizeConfig.h(4),
            children: days.map((date) {
              final isCurrentMonthDay = date.month == _currentMonth.month;
              final isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              final activity = _getActivityForDate(date);
              final activityColor = _getActivityColor(activity);

              return Container(
                width: SizeConfig.w(36),
                height: SizeConfig.w(36),
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.orange.withOpacity(0.2)
                      : (activity != ActivityType.none
                            ? activityColor.withOpacity(0.15)
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                  border: Border.all(
                    color: isToday
                        ? Colors.orange
                        : (activity != ActivityType.none
                              ? activityColor
                              : Colors.transparent),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: SizeConfig.sp(12),
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrentMonthDay
                              ? (isToday ? Colors.orange : textColor)
                              : subTextColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                    if (activity != ActivityType.none && isCurrentMonthDay)
                      Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: SizeConfig.w(4),
                            height: SizeConfig.w(4),
                            decoration: BoxDecoration(
                              color: activityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: SizeConfig.h(20)),
          Divider(color: borderColor, thickness: 1),
          SizedBox(height: SizeConfig.h(16)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: SizeConfig.w(12),
                  runSpacing: SizeConfig.h(8),
                  children: [
                    _buildLegendItem('Workout', const Color(0xFFCEF24B)),
                    _buildLegendItem('Meal', const Color(0xFF0EA5E9)),
                    _buildLegendItem('Both', Colors.purple),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(12),
                  vertical: SizeConfig.h(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                ),
                child: Row(
                  children: [
                    Text('Ã°Å¸â€Â¥', style: TextStyle(fontSize: SizeConfig.sp(14))),
                    SizedBox(width: SizeConfig.w(4)),
                    Text(
                      '${widget.currentStreak} day streak',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: SizeConfig.w(12),
          height: SizeConfig.w(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(SizeConfig.w(3)),
          ),
        ),
        SizedBox(width: SizeConfig.w(6)),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(11),
            fontWeight: FontWeight.w500,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }
}
