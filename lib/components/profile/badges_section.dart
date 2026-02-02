import 'package:flutter/material.dart';
import '../../models/gamification_model.dart';
import '../../utils/size_config.dart';

class BadgesSection extends StatelessWidget {
  final List<Achievement> achievements;
  final bool isDarkMode;

  const BadgesSection({
    super.key,
    required this.achievements,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDarkMode ? Colors.white : Colors.black;

    return SizedBox(
      height: SizeConfig.h(100),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _buildBadgeItem(achievement);
        },
      ),
    );
  }

  Widget _buildBadgeItem(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final opacity = isUnlocked ? 1.0 : 0.3;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: SizeConfig.w(80),
      margin: EdgeInsets.only(right: SizeConfig.w(12)),
      child: Column(
        children: [
          Opacity(
            opacity: opacity,
            child: Container(
              padding: EdgeInsets.all(SizeConfig.w(10)),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? Colors.amber : Colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.shield_rounded,
                color: isUnlocked ? Colors.amber : Colors.grey,
                size: SizeConfig.w(30),
              ),
            ),
          ),
          SizedBox(height: SizeConfig.h(8)),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: SizeConfig.sp(10),
              color: textColor.withOpacity(opacity),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
