import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/size_config.dart';
import '../../models/nutrition_model.dart'; // Added import

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
  // We will show up to 14 days ending today.
  
  @override
  Widget build(BuildContext context) {
    // ... (rest of build method unchanged until we hit _getGoalStatusColor usage)
    // Actually, I am ONLY replacing the class definition and _getGoalStatusColor method. 
    // But replace_file_content targets contiguous blocks.
    // I can replace the top, and then I have to replace the bottom separately?
    // Or I can replace the whole file content? No, risky.
    // I will use MultiReplaceFileContent since I need to import too.
    // Actually, simple ReplaceFileContent for the method `_getGoalStatusColor` first.
    // Then another for Constructor.
    // Wait, adding Import at top too.
    
    // I will use `MultiReplaceFileContent`.
    
    // Chunk 1: Imports + Class Definition.
    // Chunk 2: _getGoalStatusColor implementation.
    return Container(); // Dummy return for thinking block
  }

  Color _getGoalStatusColor(DateTime date) {
    // Normalize date to midnight for lookup
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Check history data if available
    if (widget.historyData != null && widget.historyData!.containsKey(normalizedDate)) {
      final data = widget.historyData![normalizedDate]!;
      if (data.calorieGoalMet) return Colors.green;
      if (data.meals.isNotEmpty) return Colors.orange;
      return Colors.red.withOpacity(0.5);
    }
    
    // Future check
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    if (normalizedDate.isAfter(normalizedNow)) return Colors.transparent;

    // Creation date check
    if (widget.minDate != null) {
       final normalizedMin = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
       if (normalizedDate.isBefore(normalizedMin)) return Colors.transparent;
    }

    // Default to Red (Missed/No Log)
    return Colors.red.withOpacity(0.5);
  }
}

  @override
  State<MealHistoryCalendar> createState() => _MealHistoryCalendarState();
}

class _MealHistoryCalendarState extends State<MealHistoryCalendar> {
  // We will show up to 14 days ending today.
  
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white54 : Colors.black54;
    
    final today = DateTime.now();
    // Calculate start date (13 days ago typically)
    DateTime startDate = today.subtract(const Duration(days: 13));
    
    // Apply minDate constraint if strictly valid
    if (widget.minDate != null && widget.minDate!.isAfter(startDate)) {
      startDate = widget.minDate!;
    }
    // Ensure start doesn't exceed today (e.g. account created in future??)
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
            itemCount: 14, // Always show 14 days
            reverse: true, 
                           // "Disable moving to upcoming". Usually calendars show past <- Today. 
                           // If reverse: Item 0 is Today. Item 1 is Yesterday. This is better for "History". 
            itemBuilder: (context, index) {
              // If reverse=true, index 0 is the LAST item (Today).
              // Wait, typical ListView reverse means start from end.
              // To have "Today" at the rightmost end (if standard LTR), we render normally [Past ... Today].
              // To have "Today" at the leftmost (start), we render [Today ... Past].
              // User said "Disable moving to upcoming".
              // If I show [Today, Yesterday, ...], there is no upcoming.
              // Code used `_startDate.add(index)`.
              
              // Let's do [Past ... Today] and initialScroll to end? Or [Today ... Past]?
              // Usually horizontal calendars: [Past ... Today ... Future].
              // I will show [Past ... Today].
              // And perform `scrollToEnd`?
              // Or simpler: ListView (not reversed) but logic:
              // Index 0 = StartDate. Index N = Today.
              // This renders Past -> Today.
              // User has to scroll right to see Today.
              // Better: Index 0 = Today. Index 1 = Yesterday. (Most recent first).
              // So I will render `today.subtract(Duration(days: index))`.
              
              // 0 -> Today, 1 -> Yesterday...
              final date = today.subtract(Duration(days: index));
              
              // Check if date is valid (after minDate)
              // Only disable if STRICTLY before minDate (and not same day)
              final bool isBeforeCreation = widget.minDate != null && 
                                          date.isBefore(widget.minDate!) && 
                                          !_isSameDay(date, widget.minDate!);
              
              // Future check (unlikely with this loop but good safety)
              final bool isFuture = date.isAfter(today);

              final bool isDisabled = isBeforeCreation || isFuture;

              final isSelected = _isSameDay(
                date,
                widget.selectedDate,
              );
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
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.black, // Enforce Black/White
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getGoalStatusColor(DateTime date) {
    // Normalize date to midnight for lookup
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // Check history data if available
    // Finding key in map (since map keys should be normalized by caller)
    if (widget.historyData != null) {
       // Look for matching key (ignoring time if keys are strict? Map lookup is strict hash)
       // We assume caller provides keys as Year/Month/Day 00:00:00.000
       if (widget.historyData!.containsKey(normalizedDate)) {
         final data = widget.historyData![normalizedDate]!;
         if (data.calorieGoalMet) return Colors.green;
         if (data.meals.isNotEmpty) return Colors.orange;
         return Colors.red.withOpacity(0.5);
       }
    }
    
    // Future check
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    if (normalizedDate.isAfter(normalizedNow)) return Colors.transparent;

    // Creation date check
    if (widget.minDate != null) {
       final normalizedMin = DateTime(widget.minDate!.year, widget.minDate!.month, widget.minDate!.day);
       if (normalizedDate.isBefore(normalizedMin)) return Colors.transparent;
    }

    // Default to Red (Missed/No Log)
    return Colors.red.withOpacity(0.5);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
