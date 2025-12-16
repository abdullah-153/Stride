import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class UserStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDarkMode;

  const UserStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final iconColor = Colors.orange;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black54;

    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    return Container(
      width: SizeConfig.w(100),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.h(16),
        horizontal: SizeConfig.w(12),
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(
          SizeConfig.w(24),
        ), // Match ProfilePage radius
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(8)),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: SizeConfig.w(24), color: iconColor),
          ),
          SizedBox(height: SizeConfig.h(12)),
          Text(
            value,
            style: TextStyle(
              fontSize: SizeConfig.sp(18),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: SizeConfig.h(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.sp(12),
              fontWeight: FontWeight.w400,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
