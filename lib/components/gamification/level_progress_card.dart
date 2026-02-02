import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class LevelProgressCard extends StatelessWidget {
  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;
  final bool isDarkMode;

  const LevelProgressCard({
    super.key,
    required this.currentLevel,
    required this.currentXp,
    required this.nextLevelXp,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);

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
                'Level $currentLevel',
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                '$currentXp / $nextLevelXp XP',
                style: TextStyle(
                  fontSize: SizeConfig.sp(12),
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(12)),
          ClipRRect(
            borderRadius: BorderRadius.circular(SizeConfig.w(10)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: SizeConfig.h(8) > 0 ? SizeConfig.h(8) : 8.0,
              backgroundColor: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}
