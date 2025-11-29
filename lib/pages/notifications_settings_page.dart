import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final isDarkMode = ref.watch(themeProvider); // Use theme provider
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(SizeConfig.w(20)),
        children: [
          // Enable Notifications
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: SwitchListTile(
              title: Text(
                'Enable Notifications',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Receive all app notifications',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              value: settings.notificationsEnabled,
              activeThumbColor: Colors.orange,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .toggleNotifications(value);
              },
            ),
          ),

          SizedBox(height: SizeConfig.h(20)),

          // Workout Reminders
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Workout Reminders',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Get reminded to log your workouts',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  value: settings.workoutReminders,
                  activeThumbColor: Colors.orange,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .toggleWorkoutReminders(value);
                        }
                      : null,
                ),
                if (settings.workoutReminders)
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    title: Text(
                      'Reminder Time',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      settings.workoutReminderTime != null
                          ? '${settings.workoutReminderTime!.hour.toString().padLeft(2, '0')}:${settings.workoutReminderTime!.minute.toString().padLeft(2, '0')}'
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime:
                            settings.workoutReminderTime ??
                            const TimeOfDay(hour: 18, minute: 0),
                      );
                      if (time != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setWorkoutReminderTime(time);
                      }
                    },
                  ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.h(20)),

          // Diet Reminders
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Diet Reminders',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Get reminded to log your meals',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  value: settings.dietReminders,
                  activeThumbColor: Colors.orange,
                  onChanged: settings.notificationsEnabled
                      ? (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .toggleDietReminders(value);
                        }
                      : null,
                ),
                if (settings.dietReminders)
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    title: Text(
                      'Reminder Time',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      settings.dietReminderTime != null
                          ? '${settings.dietReminderTime!.hour.toString().padLeft(2, '0')}:${settings.dietReminderTime!.minute.toString().padLeft(2, '0')}'
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime:
                            settings.dietReminderTime ??
                            const TimeOfDay(hour: 12, minute: 0),
                      );
                      if (time != null) {
                        ref
                            .read(appSettingsProvider.notifier)
                            .setDietReminderTime(time);
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
