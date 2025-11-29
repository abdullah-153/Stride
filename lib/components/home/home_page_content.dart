import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/gamification_service.dart';
import '../../models/gamification_model.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/size_config.dart';
import 'home_menu.dart';
import 'streak_progress.dart';
import 'today_progress_section.dart';
import 'weekdays_bar.dart';

/// Main content widget for the home page
class HomePageContent extends ConsumerWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;
  final Function(int)? onNavigate;

  const HomePageContent({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    // Get user profile data
    final userName = ref.watch(userNameProvider);
    final profileImage = ref.watch(profileImageProvider);

    // Define colors based on the theme
    final primaryTextColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black45;
    final avatarBgColor = isDarkMode ? const Color(0xFF2C2C2E) : Colors.black12;
    final avatarIconColor = isDarkMode ? Colors.white70 : Colors.black;
    final weekdaysBgColor = isDarkMode ? Colors.white : Colors.black;
    final weekdaysAcColor = isDarkMode ? Colors.black : Colors.white;

    final horizontal = SizeConfig.w(16);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.h(12)),
            // Header row
            _buildHeader(
              userName: userName,
              profileImage: profileImage,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              avatarBgColor: avatarBgColor,
              avatarIconColor: avatarIconColor,
            ),
            SizedBox(height: SizeConfig.h(10)),
            // Days bar
            SizedBox(
              height: SizeConfig.h(86),
              child: WeeklyDaysBar(
                bgColor: weekdaysBgColor,
                acColor: weekdaysAcColor,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(height: SizeConfig.h(10)),
            // Main content
            TodayActivitySection(
              isDarkMode: isDarkMode,
              onNavigate: onNavigate,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.topCenter,
              child: StreamBuilder<GamificationData>(
                stream: GamificationService().gamificationStream,
                initialData: GamificationService().getCurrentData(),
                builder: (context, snapshot) {
                  final data = snapshot.data!;
                  return StreakProgress(
                    isDarkMode: isDarkMode,
                    streakDays: data.stats.currentStreak,
                    lastDietLogDate: data.stats.lastDietLogDate,
                    lastWorkoutLogDate: data.stats.lastWorkoutLogDate,
                  );
                },
              ),
            ),
            SizedBox(height: SizeConfig.h(100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String userName,
    required String? profileImage,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color avatarBgColor,
    required Color avatarIconColor,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onNavigate?.call(3), // Navigate to ProfilePage
          child: CircleAvatar(
            radius: SizeConfig.w(28),
            backgroundImage: profileImage != null
                ? FileImage(File(profileImage)) as ImageProvider
                : null,
            backgroundColor: avatarBgColor,
            child: profileImage == null
                ? Icon(
                    Icons.person,
                    color: avatarIconColor,
                    size: SizeConfig.w(30),
                  )
                : null,
          ),
        ),
        SizedBox(width: SizeConfig.w(14)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: SizeConfig.sp(22),
                color: primaryTextColor,
              ),
              children: [
                TextSpan(
                  text: "Hello, ",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: secondaryTextColor,
                  ),
                ),
                TextSpan(
                  text: "$userName ",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        HomeMenu(isDarkMode: isDarkMode, onThemeChanged: onThemeChanged),
      ],
    );
  }
}
