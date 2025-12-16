import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class SettingsOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDarkMode;
  final VoidCallback? onTap;

  const SettingsOptionCard({
    super.key,
    required this.icon,
    required this.title,
    this.isDarkMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontSize: SizeConfig.sp(16),
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDarkMode ? Colors.white38 : Colors.black38,
      ),
      onTap: onTap,
    );
  }
}
