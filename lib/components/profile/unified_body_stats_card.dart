import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class UnifiedBodyStatsCard extends StatelessWidget {
  final double weight;
  final double height;
  final int age;
  final bool isDarkMode;
  final bool isMetric;
  final VoidCallback onTap;

  const UnifiedBodyStatsCard({
    super.key,
    required this.weight,
    required this.height,
    required this.age,
    required this.isDarkMode,
    required this.isMetric,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final labelColor = isDarkMode ? Colors.white60 : Colors.black54;

    final displayWeight = isMetric ? weight : weight * 2.20462;
    final weightUnit = isMetric ? 'kg' : 'lbs';

    final displayHeight = isMetric ? height : height / 30.48;
    final heightUnit = isMetric ? 'cm' : 'ft';

    String formattedHeight;
    if (isMetric) {
      formattedHeight = height.round().toString();
    } else {
      final feet = (height / 30.48).floor();
      final inches = ((height / 2.54) - (feet * 12)).round();
      formattedHeight = "$feet'$inches\"";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.h(20),
          horizontal: SizeConfig.w(24),
        ),
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
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    label: 'Weight',
                    value: displayWeight.toStringAsFixed(1),
                    unit: weightUnit,
                    textColor: textColor,
                    labelColor: labelColor,
                    icon: Icons.monitor_weight_rounded,
                    iconColor: Colors.orange,
                  ),
                  VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                  _buildStatItem(
                    label: 'Height',
                    value: formattedHeight,
                    unit: isMetric ? heightUnit : '',
                    textColor: textColor,
                    labelColor: labelColor,
                    icon: Icons.height_rounded,
                    iconColor: const Color(0xFFCEF24B),
                  ),
                  VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                  _buildStatItem(
                    label: 'Age',
                    value: age.toString(),
                    unit: 'yrs',
                    textColor: textColor,
                    labelColor: labelColor,
                    icon: Icons.cake_rounded,
                    iconColor: Colors.purpleAccent,
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.h(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(11),
                    color: labelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: SizeConfig.w(4)),
                Icon(
                  Icons.chevron_right,
                  size: SizeConfig.sp(16),
                  color: labelColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    required Color textColor,
    required Color labelColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: SizeConfig.sp(20), color: iconColor),
        SizedBox(height: SizeConfig.h(8)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: SizeConfig.sp(20),
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            if (unit.isNotEmpty) ...[
              SizedBox(width: SizeConfig.w(2)),
              Text(
                unit,
                style: TextStyle(
                  fontSize: SizeConfig.sp(12),
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: SizeConfig.h(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(12),
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
