import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/size_config.dart';

class EditGoalsBottomSheet {
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required bool isDarkMode,
    required int currentWeeklyWorkoutGoal,
    required int currentDailyCalorieGoal,
    double? currentWeightGoal,
  }) async {
    return await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditGoalsContent(
        isDarkMode: isDarkMode,
        initialWeeklyWorkoutGoal: currentWeeklyWorkoutGoal,
        initialDailyCalorieGoal: currentDailyCalorieGoal,
        initialWeightGoal: currentWeightGoal,
      ),
    );
  }
}

class _EditGoalsContent extends StatefulWidget {
  final bool isDarkMode;
  final int initialWeeklyWorkoutGoal;
  final int initialDailyCalorieGoal;
  final double? initialWeightGoal;

  const _EditGoalsContent({
    required this.isDarkMode,
    required this.initialWeeklyWorkoutGoal,
    required this.initialDailyCalorieGoal,
    this.initialWeightGoal,
  });

  @override
  State<_EditGoalsContent> createState() => _EditGoalsContentState();
}

class _EditGoalsContentState extends State<_EditGoalsContent> {
  late double _weeklyWorkoutGoal;
  late double _dailyCalorieGoal;
  late double? _weightGoal;
  late bool _hasWeightGoal;
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weeklyWorkoutGoal = widget.initialWeeklyWorkoutGoal.toDouble();
    _dailyCalorieGoal = widget.initialDailyCalorieGoal.toDouble();
    _weightGoal = widget.initialWeightGoal;
    _hasWeightGoal = _weightGoal != null;
    if (_hasWeightGoal) {
      _weightController.text = _weightGoal!.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDarkMode 
              ? const Color(0xFF1E1E1E).withOpacity(0.9) 
              : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.w(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: SizeConfig.w(40),
                    height: SizeConfig.h(5),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.h(24)),
                
                Text(
                  'Adjust Your Goals',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(24),
                    fontWeight: FontWeight.w800,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: SizeConfig.h(8)),
                Text(
                  'Set realistic targets to keep pushing forward.',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(14),
                    fontWeight: FontWeight.w400,
                    color: widget.isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),

                SizedBox(height: SizeConfig.h(32)),

                // Weekly Workouts Slider
                _buildSectionHeader('WEEKLY WORKOUTS', Icons.fitness_center, const Color(0xFFCEF24B)),
                SizedBox(height: SizeConfig.h(20)),
                _buildPremiumSlider(
                  value: _weeklyWorkoutGoal,
                  min: 1,
                  max: 7,
                  divisions: 6,
                  color: const Color(0xFFCEF24B),
                  label: '${_weeklyWorkoutGoal.toInt()} workouts',
                  onChanged: (val) => setState(() => _weeklyWorkoutGoal = val),
                 ),

                SizedBox(height: SizeConfig.h(32)),

                // Daily Calories Slider
                _buildSectionHeader('DAILY CALORIES', Icons.local_fire_department, Colors.orange),
                SizedBox(height: SizeConfig.h(20)),
                 _buildPremiumSlider(
                  value: _dailyCalorieGoal,
                  min: 500,
                  max: 5000,
                  divisions: 90, // increments of 50
                  color: Colors.orange,
                  label: '${_dailyCalorieGoal.toInt()} kcal',
                  onChanged: (val) => setState(() => _dailyCalorieGoal = val),
                ),

                SizedBox(height: SizeConfig.h(32)),

                // Weight Goal Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('WEIGHT GOAL', Icons.monitor_weight_rounded, Colors.purple),
                     Switch.adaptive(
                        value: _hasWeightGoal,
                        onChanged: (val) {
                          setState(() {
                            _hasWeightGoal = val;
                            if (!val) {
                              _weightGoal = null;
                              _weightController.clear();
                            }
                          });
                        },
                        activeColor: Colors.purple,
                      ),
                  ],
                ),
                
                if (_hasWeightGoal) ...[
                  SizedBox(height: SizeConfig.h(16)),
                  _buildPremiumTextField(),
                ],


                SizedBox(height: SizeConfig.h(40)),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: widget.isDarkMode ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(16)),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                           Navigator.pop(context, {
                            'weeklyWorkoutGoal': _weeklyWorkoutGoal.toInt(),
                            'dailyCalorieGoal': _dailyCalorieGoal.toInt(),
                            'weightGoal': _hasWeightGoal ? double.tryParse(_weightController.text) : null,
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.h(16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: SizeConfig.w(10)),
        Text(
          title,
          style: TextStyle(
            fontSize: SizeConfig.sp(12),
            fontWeight: FontWeight.w700,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required String label,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
                min.toInt().toString(),
                style: TextStyle(
                  fontSize: SizeConfig.sp(12),
                  color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                ),
              ),
               Text(
                label,
                style: TextStyle(
                  fontSize: SizeConfig.sp(24),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                max.toInt().toString(),
                style: TextStyle(
                  fontSize: SizeConfig.sp(12),
                  color: widget.isDarkMode ? Colors.white38 : Colors.black38,
                ),
              ),
          ],
        ),
        SizedBox(height: SizeConfig.h(8)),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
             onChanged: onChanged,
          ),
        ),
      ],
    );
  }

   Widget _buildPremiumTextField() {
    return TextField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: widget.isDarkMode ? Colors.white : Colors.black,
        fontSize: SizeConfig.sp(18),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: 'Target Weight (kg)',
        labelStyle: TextStyle(
           color: widget.isDarkMode ? Colors.white60 : Colors.black45,
        ),
        suffixIcon: const Icon(Icons.edit, size: 18),
        filled: true,
        fillColor: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
           horizontal: SizeConfig.w(20),
           vertical: SizeConfig.h(16),
        ),
      ),
    );
  }
}
