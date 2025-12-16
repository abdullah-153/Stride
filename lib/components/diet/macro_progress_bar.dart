import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final int current;
  final int goal;
  final Color color;
  final bool isDarkMode;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final bgColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: SizeConfig.sp(13),
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            Text(
              '${current}g / ${goal}g',
              style: TextStyle(
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(6)),
        Stack(
          children: [
            Container(
              height: SizeConfig.h(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(SizeConfig.w(4)),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: SizeConfig.h(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(SizeConfig.w(4)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
