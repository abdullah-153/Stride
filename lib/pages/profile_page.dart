import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/profile/profile_tile_card.dart';
import '../components/profile/user_stat_card.dart';
import '../components/gamification/level_progress_card.dart';
import '../components/profile/badges_section.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../utils/size_config.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';
import '../pages/edit_profile_page.dart';
import '../pages/notifications_settings_page.dart';
import '../pages/privacy_security_page.dart';
import '../utils/profile_bottom_sheets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final horizontal = SizeConfig.w(20);
    final headerSize = SizeConfig.sp(48);

    // Use global theme provider
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode
        ? const Color(0xFF121212)
        : Colors.white; // Changed to pure white
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final sectionTitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    // Standardized Card Decoration
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: StreamBuilder<GamificationData>(
        stream: GamificationService().gamificationStream,
        initialData: GamificationService().getCurrentData(),
        builder: (context, snapshot) {
          final data = snapshot.data!;
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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

                SizedBox(height: SizeConfig.h(10)),

                // Profile Header (Avatar & Name)
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
                      padding: EdgeInsets.all(SizeConfig.w(20)),
                      decoration: cardDecoration,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: SizeConfig.w(35),
                              backgroundImage:
                                  ref.watch(profileImageProvider) != null
                                  ? FileImage(
                                          File(
                                            ref.watch(profileImageProvider)!,
                                          ),
                                        )
                                        as ImageProvider
                                  : null,
                              backgroundColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              child: ref.watch(profileImageProvider) == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 35,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(20)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(userNameProvider),
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(22),
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: SizeConfig.h(4)),
                              Text(
                                ref.watch(userBioProvider),
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(14),
                                  color: sectionTitleColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: SizeConfig.h(30)),

                // User Stats
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ProfileBottomSheets.showEditWeight(
                            context,
                            currentWeight: ref.read(userWeightProvider),
                            onSave: (weight) async {
                              await ref
                                  .read(userProfileProvider.notifier)
                                  .updateWeight(weight);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Weight updated!'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: UserStatCard(
                          label: 'Weight',
                          value:
                              '${ref.watch(userWeightProvider).toStringAsFixed(1)} kg',
                          icon: Icons.monitor_weight_rounded,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ProfileBottomSheets.showEditHeight(
                            context,
                            currentHeight: ref.read(userHeightProvider),
                            onSave: (height) async {
                              await ref
                                  .read(userProfileProvider.notifier)
                                  .updateHeight(height);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Height updated!'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: UserStatCard(
                          label: 'Height',
                          value:
                              '${ref.watch(userHeightProvider).toStringAsFixed(0)} cm',
                          icon: Icons.height_rounded,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final currentProfile = ref
                              .read(userProfileProvider)
                              .value;
                          ProfileBottomSheets.showEditDateOfBirth(
                            context,
                            currentDOB: currentProfile?.dateOfBirth,
                            onSave: (dob) async {
                              await ref
                                  .read(userProfileProvider.notifier)
                                  .updateDateOfBirth(dob);
                              // Calculate age from DOB
                              final age = DateTime.now().year - dob.year;
                              await ref
                                  .read(userProfileProvider.notifier)
                                  .updateAge(age);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Date of birth updated!'),
                                  ),
                                );
                              }
                            },
                          );
                        },
                        child: UserStatCard(
                          label: 'Age',
                          value: '${ref.watch(userAgeProvider)}',
                          icon: Icons.cake_rounded,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.h(32)),

                // Gamification Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PROGRESS",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(13),
                          fontWeight: FontWeight.w700,
                          color: sectionTitleColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(16)),
                      LevelProgressCard(
                        currentLevel: data.stats.currentLevel,
                        currentXp: data.stats.currentXp,
                        nextLevelXp: GamificationService().getXpForNextLevel(
                          data.stats.currentLevel,
                        ),
                        isDarkMode: isDarkMode,
                      ),

                      SizedBox(height: SizeConfig.h(24)),

                      Text(
                        "BADGES",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(13),
                          fontWeight: FontWeight.w700,
                          color: sectionTitleColor,
                          letterSpacing: 1.5,
                        ),
                      ),
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
                      Text(
                        "SETTINGS",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(13),
                          fontWeight: FontWeight.w700,
                          color: sectionTitleColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(16)),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
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
                                    builder: (context) =>
                                        const EditProfilePage(),
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
                              icon: Icons.notifications_outlined,
                              title: "Notifications",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationsSettingsPage(),
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
                              icon: Icons.privacy_tip_outlined,
                              title: "Privacy & Security",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PrivacySecurityPage(),
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
                              icon: Icons.help_outline_rounded,
                              title: "Help & Support",
                              isDarkMode: isDarkMode,
                              onTap: () {
                                ProfileBottomSheets.showInfoSheet(
                                  context,
                                  title: 'Help & Support',
                                  content: '''Welcome to Fitness Tracker!

Frequently Asked Questions:

Q: How do I log a workout?
A: Navigate to the Workout page and tap the "+" button to add a new workout.

Q: How do I track my diet?
A: Go to the Diet page and add meals throughout the day.

Q: What are XP points?
A: XP points are earned by completing workouts and logging meals. They help you level up!

Q: How does the streak system work?
A: Your streak increases when you log both a workout AND a meal on the same day.

Need more help?
Contact us at: support@fitnesstracker.com

Version: 1.0.0''',
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

                // Logout Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        // Clear user profile data
                        await ref
                            .read(userProfileProvider.notifier)
                            .clearProfile();

                        // Reset gamification data
                        GamificationService().reset();

                        if (context.mounted) {
                          // Navigate to startup page and remove all previous routes
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/startup',
                            (route) => false,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.h(16),
                        ),
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

                SizedBox(
                  height: SizeConfig.h(100),
                ), // Increased spacing to prevent navbar overlap
              ],
            ),
          );
        },
      ),
    );
  }
}
