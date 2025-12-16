import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class StreakSummaryCard extends StatefulWidget {
  final bool isDarkMode;
  final List<bool> weeklyActivity; // Last 7 days
  final int currentStreak;
  final List<int> dailyCalories; 
  final List<int> dailyDuration;

  const StreakSummaryCard({
    super.key,
    required this.isDarkMode,
    required this.weeklyActivity,
    required this.currentStreak,
    this.dailyCalories = const [2100, 2300, 1800, 2400, 2200, 1900, 2000], 
    this.dailyDuration = const [45, 60, 30, 0, 50, 0, 45],
  });

  @override
  State<StreakSummaryCard> createState() => _StreakSummaryCardState();
}

class _StreakSummaryCardState extends State<StreakSummaryCard> {
  int? _selectedDayIndex;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;

    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final completedDays = widget.weeklyActivity.where((active) => active).length;

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
          // 7-day activity heatmap with interaction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isActive = index < widget.weeklyActivity.length && widget.weeklyActivity[index];
              final isSelected = _selectedDayIndex == index;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = isSelected ? null : index),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: SizeConfig.w(36),
                      height: SizeConfig.w(36),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFCEF24B).withOpacity(isSelected ? 1.0 : 0.8)
                            : (widget.isDarkMode
                                ? Colors.white.withOpacity(isSelected ? 0.2 : 0.05)
                                : Colors.grey.withOpacity(isSelected ? 0.3 : 0.1)),
                        borderRadius: BorderRadius.circular(SizeConfig.w(10)),
                        border: Border.all(
                          color: isSelected 
                              ? (isActive ? Colors.white : const Color(0xFFCEF24B)) 
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: isActive && isSelected ? [
                          BoxShadow(
                            color: const Color(0xFFCEF24B).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ] : [],
                      ),
                      child: isActive
                          ? Icon(
                              Icons.check_rounded,
                              color: Colors.black,
                              size: SizeConfig.sp(20),
                            )
                          : null,
                    ),
                    SizedBox(height: SizeConfig.h(8)),
                    Text(
                      daysOfWeek[index],
                      style: TextStyle(
                        fontSize: SizeConfig.sp(10),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFFCEF24B) : subTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          // Details Panel (Animated)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _selectedDayIndex != null 
                ? Container(
                    margin: EdgeInsets.only(top: SizeConfig.h(20)),
                    padding: EdgeInsets.all(SizeConfig.w(16)),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode ? Colors.black26 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailItem(
                          Icons.local_fire_department_rounded, 
                          "${widget.dailyCalories[_selectedDayIndex!]} kcal", 
                          "Burnt", 
                          Colors.orange
                        ),
                        Container(width: 1, height: 30, color: borderColor),
                        _buildDetailItem(
                          Icons.timer_rounded, 
                          "${widget.dailyDuration[_selectedDayIndex!]} min", 
                          "Duration", 
                          Colors.blue
                        ),
                      ],
                    ),
                  ) 
                : const SizedBox.shrink(),
          ),

          SizedBox(height: SizeConfig.h(20)),
          Divider(color: borderColor, thickness: 1),
          SizedBox(height: SizeConfig.h(16)),

          // Overall Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                label: 'Active Days',
                value: '$completedDays/7',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
              Container(
                width: 1,
                height: SizeConfig.h(30),
                color: borderColor,
              ),
              _buildStatColumn(
                label: 'Current Streak',
                value: '${widget.currentStreak} 🔥',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
              Container(
                width: 1,
                height: SizeConfig.h(30),
                color: borderColor,
              ),
             _buildStatColumn(
                label: 'Comp. Rate',
                value: '${(completedDays/7 * 100).toInt()}%',
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: SizeConfig.sp(14),
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(10),
            color: widget.isDarkMode ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.sp(16),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        SizedBox(height: SizeConfig.h(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(11),
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}
