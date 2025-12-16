import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class HomeMenu extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const HomeMenu({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
      elevation: 10,
      icon: Icon(
        Icons.menu_rounded,
        size: SizeConfig.w(28),
        color: isDarkMode ? Colors.white70 : Colors.black38,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      onSelected: (int value) {
        if (value == 5) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/startup', (route) => false);
        }
      },
      itemBuilder: (BuildContext context) {
        bool menuIsDark = isDarkMode;
        final menuTextStyle = TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        );

        return <PopupMenuEntry<int>>[
          PopupMenuItem<int>(
            enabled: true,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dark Mode', style: menuTextStyle),
                    const SizedBox(width: 10),
                    Switch.adaptive(
                      activeTrackColor: Colors.black,
                      activeThumbColor: Colors.white,
                      value: menuIsDark,
                      onChanged: (bool value) {
                        setState(() {
                          menuIsDark = value;
                        });
                        onThemeChanged(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const PopupMenuDivider(),

          PopupMenuItem<int>(
            value: 3,
            child: Text('Submit feedback', style: menuTextStyle),
          ),
          PopupMenuItem<int>(
            value: 4,
            child: Text('Privacy policy', style: menuTextStyle),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem<int>(
            value: 5,
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ];
      },
    );
  }
}
