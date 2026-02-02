import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile_model.dart';
import '../utils/validators.dart';

class ProfileBottomSheets {
  static Future<void> showEditWeight(
    BuildContext context, {
    required double currentWeight,
    required Function(double) onSave,
  }) async {
    bool isKg = true;
    double displayWeight = currentWeight;
    final controller = TextEditingController(
      text: displayWeight.toStringAsFixed(1),
    );
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Weight',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('kg'),
                        selected: isKg,
                        selectedColor: Colors.orange,
                        onSelected: (selected) {
                          if (!isKg) {
                            setState(() {
                              isKg = true;
                              final currentValue =
                                  double.tryParse(controller.text) ?? 0;
                              displayWeight = currentValue * 0.453592;
                              controller.text = displayWeight.toStringAsFixed(
                                1,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('lbs'),
                        selected: !isKg,
                        selectedColor: Colors.orange,
                        onSelected: (selected) {
                          if (isKg) {
                            setState(() {
                              isKg = false;
                              final currentValue =
                                  double.tryParse(controller.text) ?? 0;
                              displayWeight = currentValue * 2.20462;
                              controller.text = displayWeight.toStringAsFixed(
                                1,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    validator: Validators.validateWeight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Weight (${isKg ? 'kg' : 'lbs'})',
                      prefixIcon: const Icon(Icons.monitor_weight_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          double weight = double.parse(controller.text);
                          if (!isKg) {
                            weight = weight * 0.453592;
                          }
                          onSave(weight);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showEditHeight(
    BuildContext context, {
    required double currentHeight,
    required Function(double) onSave,
  }) async {
    bool isCm = true;
    double displayHeight = currentHeight;
    final controller = TextEditingController(
      text: displayHeight.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Height',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('cm'),
                        selected: isCm,
                        selectedColor: Colors.orange,
                        onSelected: (selected) {
                          if (!isCm) {
                            setState(() {
                              isCm = true;
                              final currentValue =
                                  double.tryParse(controller.text) ?? 0;
                              displayHeight = currentValue * 30.48;
                              controller.text = displayHeight.toStringAsFixed(
                                0,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('ft'),
                        selected: !isCm,
                        selectedColor: Colors.orange,
                        onSelected: (selected) {
                          if (isCm) {
                            setState(() {
                              isCm = false;
                              final currentValue =
                                  double.tryParse(controller.text) ?? 0;
                              displayHeight = currentValue / 30.48;
                              controller.text = displayHeight.toStringAsFixed(
                                1,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller,
                    validator: Validators.validateHeight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Height (${isCm ? 'cm' : 'ft'})',
                      prefixIcon: const Icon(Icons.height_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          double height = double.parse(controller.text);
                          if (!isCm) {
                            height = height * 30.48;
                          }
                          onSave(height);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showEditDateOfBirth(
    BuildContext context, {
    DateTime? currentDOB,
    required Function(DateTime) onSave,
  }) async {
    final now = DateTime.now();
    final minDate = DateTime(now.year - 100, now.month, now.day);
    final maxDate = DateTime(now.year - 13, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDOB ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
      helpText: 'Select Date of Birth',
      fieldLabelText: 'Date of Birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              surface: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      onSave(selectedDate);
    }
  }

  static Future<void> showNotificationsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final isDarkMode = ref.watch(themeProvider);
          final settings = ref.watch(appSettingsProvider);

          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSwitchTile(
                  "Enable Notifications",
                  "Receive all app notifications",
                  settings.notificationsEnabled,
                  (v) => ref
                      .read(appSettingsProvider.notifier)
                      .toggleNotifications(v),
                  isDarkMode,
                ),

                const SizedBox(height: 16),
                Divider(color: isDarkMode ? Colors.white10 : Colors.black12),
                const SizedBox(height: 16),

                _buildSwitchTile(
                  "Workout Reminders",
                  "Get reminded to log your workouts",
                  settings.workoutReminders,
                  settings.notificationsEnabled
                      ? (v) => ref
                            .read(appSettingsProvider.notifier)
                            .toggleWorkoutReminders(v)
                      : null,
                  isDarkMode,
                ),

                _buildSwitchTile(
                  "Diet Reminders",
                  "Get reminded to log your meals",
                  settings.dietReminders,
                  settings.notificationsEnabled
                      ? (v) => ref
                            .read(appSettingsProvider.notifier)
                            .toggleDietReminders(v)
                      : null,
                  isDarkMode,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Future<void> showPrivacySheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final isDarkMode = ref.watch(themeProvider);
          final settings = ref.watch(appSettingsProvider);

          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Privacy Level",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Control who can see your fitness data",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildRadioTile(
                    "Public",
                    "Everyone can see your data",
                    "public",
                    settings.privacyLevel,
                    (v) => ref
                        .read(appSettingsProvider.notifier)
                        .updatePrivacyLevel(v!),
                    isDarkMode,
                  ),
                  _buildRadioTile(
                    "Friends",
                    "Only friends can see",
                    "friends",
                    settings.privacyLevel,
                    (v) => ref
                        .read(appSettingsProvider.notifier)
                        .updatePrivacyLevel(v!),
                    isDarkMode,
                  ),
                  _buildRadioTile(
                    "Private",
                    "Only you can see",
                    "private",
                    settings.privacyLevel,
                    (v) => ref
                        .read(appSettingsProvider.notifier)
                        .updatePrivacyLevel(v!),
                    isDarkMode,
                  ),

                  const SizedBox(height: 16),
                  Divider(color: isDarkMode ? Colors.white10 : Colors.black12),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: Text(
                      "Clear All Data",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Data cleared locally")),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<void> showUnitsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final isDarkMode = ref.watch(themeProvider);
          final currentUnits =
              ref.watch(userProfileProvider).value?.preferredUnits ??
              UnitPreference.metric;

          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white24 : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Measurement Units",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: _buildUnitCard(
                        "Metric",
                        "kg, cm, ml",
                        UnitPreference.metric,
                        currentUnits,
                        (v) => ref
                            .read(userProfileProvider.notifier)
                            .updateUnitPreference(v),
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildUnitCard(
                        "Imperial",
                        "lbs, ft, oz",
                        UnitPreference.imperial,
                        currentUnits,
                        (v) => ref
                            .read(userProfileProvider.notifier)
                            .updateUnitPreference(v),
                        isDarkMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  static void showInfoSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final updatedContent = '''Welcome to Stride!

Frequently Asked Questions:

Q: How do I log a workout?
A: Navigate to the Workout page and tap the "+" button to add a new workout.

Q: How do I track my diet?
A: Go to the Diet page and add meals throughout the day.

Q: What are XP points?
A: XP points are earned by completing workouts and logging meals. They help you level up!
''';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    updatedContent,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool)? onChanged,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  static Widget _buildRadioTile(
    String title,
    String subtitle,
    String value,
    String groupValue,
    Function(String?) onChanged,
    bool isDarkMode,
  ) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.1)
              : (isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.orange.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Colors.orange
                  : (isDarkMode ? Colors.white38 : Colors.black38),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildUnitCard(
    String title,
    String subtitle,
    UnitPreference value,
    UnitPreference groupValue,
    Function(UnitPreference) onTap,
    bool isDarkMode,
  ) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.15)
              : (isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              value == UnitPreference.metric
                  ? Icons.straighten
                  : Icons.square_foot,
              size: 32,
              color: isSelected
                  ? Colors.blueAccent
                  : (isDarkMode ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.blueAccent
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
