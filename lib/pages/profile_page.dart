import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/profile/profile_tile_card.dart';
import '../components/profile/activity_stats_card.dart';
import '../components/profile/streak_summary_card.dart';
import '../components/profile/badges_section.dart';
import '../components/profile/unified_body_stats_card.dart';
import '../components/profile/fitness_goals_card.dart';
import '../services/gamification_service.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import '../models/gamification_model.dart';
import '../models/user_profile_model.dart';
import '../utils/size_config.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../pages/edit_profile_page.dart';
import '../pages/weight_tracking_page.dart';
import '../utils/profile_bottom_sheets.dart';
import '../utils/edit_goals_bottom_sheet.dart';
import '../utils/body_update_sheet.dart';
import '../services/auth_service.dart';
import '../components/profile/streak_heatmap.dart';
import '../components/common/global_back_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final horizontal = SizeConfig.w(20);
    final headerSize = SizeConfig.sp(48);

    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final sectionTitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    final cardDecoration = BoxDecoration(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(SizeConfig.w(24)),
      border: Border.all(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GlobalBackButton(
          isDark: isDarkMode,
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [],
      ),
      body: StreamBuilder<GamificationData>(
        stream: GamificationService().gamificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.error_outline, color: Colors.red, size: 48),
                   SizedBox(height: 16),
                   Text("Failed to load profile", style: TextStyle(color: textColor)),
                   Text(snapshot.error.toString(), style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12)),
                 ],
               ),
             );
          }

          if (!snapshot.hasData) {
            return Center(
              child: BouncingDotsIndicator(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            );
          }
          final data = snapshot.data!;
          final nextLevelXp = GamificationService().getXpForNextLevel(data.stats.currentLevel);
          
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: SizeConfig.h(100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.h(10)),

                    // Page Title
                    Padding(
                      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 24),
                      child: Text(
                        "Profile\nSettings",
                        style: TextStyle(
                          fontSize: headerSize,
                          fontWeight: FontWeight.w300,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                    ),

                    // Unified Header (Profile + Level Progress integration)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(SizeConfig.w(24)),
                          decoration: cardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Avatar with Level Ring
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: SizeConfig.w(86),
                                        height: SizeConfig.w(86),
                                        child: CircularProgressIndicator(
                                          value: data.stats.currentXp / nextLevelXp,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.grey.withOpacity(0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: SizeConfig.w(38),
                                        backgroundImage:
                                            ref.watch(profileImageProvider) != null
                                            ? FileImage(File(ref.watch(profileImageProvider)!))
                                            : null,
                                        backgroundColor: isDarkMode
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                        child: ref.watch(profileImageProvider) == null
                                            ? Icon(Icons.person, size: 40, color: Colors.grey)
                                            : null,
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: SizeConfig.w(20)),
                                  // Text Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                ref.watch(userNameProvider),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: SizeConfig.sp(22),
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.edit_outlined, size: 20, color: sectionTitleColor),
                                          ],
                                        ),
                                        SizedBox(height: SizeConfig.h(4)),
                                        Text(
                                          ref.watch(userBioProvider),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: SizeConfig.sp(14),
                                            color: sectionTitleColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: SizeConfig.h(8)),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            "Level ${data.stats.currentLevel}",
                                            style: TextStyle(
                                              fontSize: SizeConfig.sp(11),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    // Unified Body Stats Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: UnifiedBodyStatsCard(
                        weight: ref.watch(userWeightProvider),
                        height: ref.watch(userHeightProvider),
                        age: ref.watch(userAgeProvider),
                        isDarkMode: isDarkMode,
                        isMetric: ref.watch(userProfileProvider).value!.preferredUnits == UnitPreference.metric,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WeightTrackingPage(),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    // Activity Overview
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ACTIVITY", style: TextStyle(fontSize: SizeConfig.sp(12), fontWeight: FontWeight.bold, color: sectionTitleColor, letterSpacing: 1.2)),
                          SizedBox(height: SizeConfig.h(12)),
                          ActivityStatsCard(
                            isDarkMode: isDarkMode,
                            weeklyWorkouts: 0,
                            weeklyMeals: 0,
                            weeklyCaloriesBurned: 0,
                            monthlyWorkouts: 0,
                            monthlyMeals: 0,
                            monthlyCaloriesBurned: 0,
                            totalWorkouts: 0,
                            totalMeals: 0,
                            totalXP: data.stats.currentXp,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    // Streak Summary
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("STREAK SUMMARY", style: TextStyle(fontSize: SizeConfig.sp(12), fontWeight: FontWeight.bold, color: sectionTitleColor, letterSpacing: 1.2)),
                          SizedBox(height: SizeConfig.h(12)),
                          StreakHeatMap(
                            activityDates: data.stats.activityDates,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: SizeConfig.h(24)),
                    // Badges Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("BADGES", style: TextStyle(fontSize: SizeConfig.sp(12), fontWeight: FontWeight.bold, color: sectionTitleColor, letterSpacing: 1.2)),
                          SizedBox(height: SizeConfig.h(16)),
                          BadgesSection(
                            achievements: data.achievements,
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(32)),

                    // Settings Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SETTINGS", style: TextStyle(fontSize: SizeConfig.sp(12), fontWeight: FontWeight.bold, color: sectionTitleColor, letterSpacing: 1.2)),
                          SizedBox(height: SizeConfig.h(16)),
                          Container(
                            decoration: cardDecoration,
                            child: Column(
                              children: [
                                SettingsOptionCard(
                                  icon: Icons.person_outline_rounded,
                                  title: "Personal Details",
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditProfilePage(),
                                      ),
                                    );
                                  },
                                ),
                                Divider(
                                  height: 1,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                ),
                                SettingsOptionCard(
                                  icon: Icons.notifications_none_rounded,
                                  title: "Notifications",
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    ProfileBottomSheets.showNotificationsSheet(context, ref);
                                  },
                                ),
                                Divider(
                                  height: 1,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                ),
                                SettingsOptionCard(
                                  icon: Icons.lock_outline_rounded,
                                  title: "Privacy & Security",
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    ProfileBottomSheets.showPrivacySheet(context, ref);
                                  },
                                ),
                                Divider(
                                  height: 1,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                ),
                                SettingsOptionCard(
                                  icon: Icons.help_outline_rounded,
                                  title: "Help & Support",
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    ProfileBottomSheets.showInfoSheet(
                                      context,
                                      title: 'Help & Support',
                                      content: '', // Content is now internal to the method
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(32)),

                     // Preferences Section (Units)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PREFERENCES", style: TextStyle(fontSize: SizeConfig.sp(12), fontWeight: FontWeight.bold, color: sectionTitleColor, letterSpacing: 1.2)),
                          SizedBox(height: SizeConfig.h(16)),
                          Container(
                            decoration: cardDecoration,
                            child: SettingsOptionCard(
                              icon: Icons.straighten_rounded,
                              title: "Units: ${ref.watch(userProfileProvider).value!.preferredUnits == UnitPreference.metric ? 'Metric (kg/cm)' : 'Imperial (lbs/ft)'}",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                ProfileBottomSheets.showUnitsSheet(context, ref);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(32)),

                    // Logout Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () async {
                            await ref.read(authServiceProvider).signOut(); // Updated: Actual Firebase Sign Out
                            await ref.read(userProfileProvider.notifier).clearProfile();
                            GamificationService().reset();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/startup',
                                (route) => false,
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                            ),
                          ),
                          child: Text(
                            "Log Out",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(16),
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
