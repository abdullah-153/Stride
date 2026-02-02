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

    final userName = ref.watch(userNameProvider);
    final profileImage = ref.watch(profileImageProvider);

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
            _buildHeader(
              userName: userName,
              profileImage: profileImage,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
              avatarBgColor: avatarBgColor,
              avatarIconColor: avatarIconColor,
            ),
            SizedBox(height: SizeConfig.h(10)),
            SizedBox(
              height: SizeConfig.h(86),
              child: WeeklyDaysBar(
                bgColor: weekdaysBgColor,
                acColor: weekdaysAcColor,
                isDarkMode: isDarkMode,
              ),
            ),
            SizedBox(height: SizeConfig.h(10)),
            StreamBuilder<GamificationData>(
              stream: GamificationService().gamificationStream,
              builder: (context, snapshot) {
                final currentStreak = snapshot.hasData
                    ? snapshot.data!.stats.currentStreak
                    : 0;
                final currentLevel = snapshot.hasData
                    ? snapshot.data!.stats.currentLevel
                    : 1;
                final currentXp = snapshot.hasData
                    ? snapshot.data!.stats.currentXp
                    : 0;
                final nextLevelXp = GamificationService().getXpForNextLevel(
                  currentLevel,
                );

                final lastDietDate = snapshot.hasData
                    ? snapshot.data!.stats.lastDietLogDate
                    : null;
                final lastWorkoutDate = snapshot.hasData
                    ? snapshot.data!.stats.lastWorkoutLogDate
                    : null;

                final activityDates = snapshot.hasData
                    ? snapshot.data!.stats.activityDates
                    : <DateTime>[];

                return StreakProgress(
                  streakDays: currentStreak,
                  activityDates: activityDates,
                  isDarkMode: isDarkMode,
                  currentLevel: currentLevel,
                  currentXp: currentXp,
                  nextLevelXp: nextLevelXp,
                  lastDietLogDate: lastDietDate,
                  lastWorkoutLogDate: lastWorkoutDate,
                );
              },
            ),
            SizedBox(height: SizeConfig.h(10)),
            TodayActivitySection(
              isDarkMode: isDarkMode,
              onNavigate: onNavigate,
            ),
            const SizedBox(height: 12),

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
          onTap: () => onNavigate?.call(3),
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
