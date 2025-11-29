import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validators.dart';

class ProfileBottomSheets {
  // Edit Weight Bottom Sheet
  static Future<void> showEditWeight(
    BuildContext context, {
    required double currentWeight,
    required Function(double) onSave,
  }) async {
    bool isKg = true; // Default to kg
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

                  // Unit Toggle
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
                              // Convert lbs to kg
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
                              // Convert kg to lbs
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
                          // Convert to kg if currently in lbs
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

  // Edit Height Bottom Sheet
  static Future<void> showEditHeight(
    BuildContext context, {
    required double currentHeight,
    required Function(double) onSave,
  }) async {
    bool isCm = true; // Default to cm
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

                  // Unit Toggle
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
                              // Convert ft to cm
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
                              // Convert cm to ft
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
                          // Convert to cm if currently in ft
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

  // Edit Date of Birth Bottom Sheet
  static Future<void> showEditDateOfBirth(
    BuildContext context, {
    DateTime? currentDOB,
    required Function(DateTime) onSave,
  }) async {
    final now = DateTime.now();
    final minDate = DateTime(
      now.year - 100,
      now.month,
      now.day,
    ); // Max 100 years old
    final maxDate = DateTime(
      now.year - 13,
      now.month,
      now.day,
    ); // Min 13 years old

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

  // Info Bottom Sheet (for Terms, Privacy, etc.)
  static Future<void> showInfoSheet(
    BuildContext context, {
    required String title,
    required String content,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
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
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
