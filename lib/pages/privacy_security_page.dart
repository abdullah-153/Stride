import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/size_config.dart';

class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

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
          'Privacy & Security',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(SizeConfig.w(20)),
        children: [
          // Privacy Level
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Control who can see your fitness data',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                RadioListTile<String>(
                  title: Text(
                    'Public',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Everyone can see your data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  value: 'public',
                  groupValue: settings.privacyLevel,
                  activeColor: Colors.orange,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .updatePrivacyLevel(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Friends',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Only friends can see your data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  value: 'friends',
                  groupValue: settings.privacyLevel,
                  activeColor: Colors.orange,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .updatePrivacyLevel(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text(
                    'Private',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Only you can see your data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  value: 'private',
                  groupValue: settings.privacyLevel,
                  activeColor: Colors.orange,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .updatePrivacyLevel(value);
                    }
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: SizeConfig.h(20)),

          // Data Management
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
                ListTile(
                  leading: Icon(
                    Icons.download,
                    color: isDarkMode ? Colors.orange : Colors.orange,
                  ),
                  title: Text(
                    'Export Data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Download all your fitness data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Implement data export
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data export coming soon')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(
                    'Clear All Data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Permanently delete all your data',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear All Data?'),
                        content: const Text(
                          'This will permanently delete all your fitness data. This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement data clearing
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data cleared')),
                              );
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
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
