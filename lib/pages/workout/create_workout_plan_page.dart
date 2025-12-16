import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_tracker_frontend/services/workout_plan_builder_service.dart';
import 'package:fitness_tracker_frontend/services/firestore/workout_plan_service.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/providers/theme_provider.dart';
import 'package:fitness_tracker_frontend/components/shared/bouncing_dots_indicator.dart';
import 'package:fitness_tracker_frontend/components/workout/planner/weekly_planner_view.dart';
import 'plan_generation_error_screen.dart';

class CreateWorkoutPlanPage extends ConsumerStatefulWidget {
  const CreateWorkoutPlanPage({super.key});

  @override
  ConsumerState<CreateWorkoutPlanPage> createState() => _CreateWorkoutPlanPageState();
}

class _CreateWorkoutPlanPageState extends ConsumerState<CreateWorkoutPlanPage> with SingleTickerProviderStateMixin {
  final WorkoutPlanBuilderService _builderService = WorkoutPlanBuilderService();
  
  // State
  String _selectedGoal = 'muscle_gain';
  int _daysPerWeek = 4;
  int _durationWeeks = 4;
  String _fitnessLevel = 'Intermediate'; // Default
  String _equipmentLevel = 'gym'; // 'none', 'basic', 'gym'
  final Set<String> _selectedMuscles = {};
  bool _isLoading = false;
  Map<String, dynamic>? _generatedPlan;

  // Animations
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, String>> _goals = [
    {'id': 'muscle_gain', 'label': 'Muscle Gain', 'emoji': '💪'},
    {'id': 'weight_loss', 'label': 'Weight Loss', 'emoji': '🔥'},
    {'id': 'strength', 'label': 'Strength', 'emoji': '🏋️'},
    {'id': 'endurance', 'label': 'Endurance', 'emoji': '🏃'},
  ];

  final List<String> _allMuscles = [
    'chest', 'back', 'legs', 'shoulders', 'biceps', 'triceps', 'abs', 'cardio'
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generatePlan() async {
    if (_selectedMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one target muscle', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final plan = await _builderService.generateWorkoutPlan(
        goal: _selectedGoal,
        daysPerWeek: _daysPerWeek,
        durationWeeks: _durationWeeks,
        targetMuscles: _selectedMuscles.toList(),
        fitnessLevel: _fitnessLevel,
        equipment: _getEquipmentList(),
      );
      
      if (mounted) {
        setState(() {
          _generatedPlan = plan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to Error Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlanGenerationErrorScreen(
              errorMessage: e.toString(),
              onRetry: () {
                Navigator.pop(context); // Close error screen
                _generatePlan(); // Retry
              },
            ),
          ),
        );
      }
    }
  }

  void _saveAndActivatePlan() async {
    if (_generatedPlan == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Save the plan to Firestore
      final planId = await WorkoutPlanService().createWorkoutPlan(userId, _generatedPlan!);
      
      // Activate the plan
      await WorkoutPlanService().setActiveWorkoutPlan(userId, planId, DateTime.now());

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate back and show success
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan activated successfully!'),
            backgroundColor: Color(0xFFCEF24B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission or Network Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isDarkMode = ref.watch(themeProvider);
    
    // Premium App Theme Colors
    final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final accentColor = const Color(0xFFCEF24B); // Lime Green
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryText = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: null, // Removed title as requested
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent, // Fix tint issue
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [

          // Ambient Background Glow
          if (isDarkMode)
            Positioned(
              top: -100,
              right: -100,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.15),
                  ),
                ),
              ),
            ),


          SafeArea(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BouncingDotsIndicator(color: accentColor),
                        SizedBox(height: SizeConfig.h(20)),
                        Text(
                          "Designing your perfect plan...",
                          style: TextStyle(color: secondaryText, fontSize: SizeConfig.sp(14)),
                        ),
                      ],
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
                      physics: const BouncingScrollPhysics(),
                      child: _generatedPlan == null
                          ? _buildInputForm(textColor, secondaryText!, cardColor, accentColor, isDarkMode)
                          : _buildPlanPreview(textColor, secondaryText!, cardColor, accentColor, isDarkMode),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(Color textColor, Color secondaryText, Color cardColor, Color accentColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.h(10)),
        Text(
          "Generate\nWorkout Plan",
          style: TextStyle(
            fontSize: SizeConfig.sp(32),
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Text(
          " AI-powered personalization based on your goals.",
          style: TextStyle(color: secondaryText, fontSize: SizeConfig.sp(16)),
        ),
        SizedBox(height: SizeConfig.h(32)),

        // 1. Goal Selection
        _buildSectionHeader("Primary Goal", textColor),
        SizedBox(height: SizeConfig.h(16)),
        SizedBox(
          height: SizeConfig.h(110),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _goals.length,
            separatorBuilder: (_, __) => SizedBox(width: SizeConfig.w(12)),
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final isSelected = _selectedGoal == goal['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: SizeConfig.w(100),
                  padding: EdgeInsets.all(SizeConfig.w(12)),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black12),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        goal['emoji']!,
                        style: TextStyle(fontSize: SizeConfig.sp(28)),
                      ),
                      SizedBox(height: SizeConfig.h(8)),
                      Text(
                        goal['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.black : textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.sp(12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: SizeConfig.h(32)),

        // 2. Frequency Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader("Frequency", textColor),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$_daysPerWeek Days / Week",
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: SizeConfig.sp(12)),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(16)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
               SliderTheme(
                 data: SliderTheme.of(context).copyWith(
                   activeTrackColor: accentColor,
                   inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
                   thumbColor: Colors.white, // White thumb for contrast
                   thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                   overlayColor: accentColor.withOpacity(0.2),
                   trackHeight: 6,
                 ),
                 child: Slider(
                    value: _daysPerWeek.toDouble(),
                    min: 3,
                    max: 7,
                    divisions: 4,
                    onChanged: (val) => setState(() => _daysPerWeek = val.toInt()),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 10),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text("3 Days", style: TextStyle(color: secondaryText, fontSize: 12)),
                     Text("7 Days", style: TextStyle(color: secondaryText, fontSize: 12)),
                   ],
                 ),
               ),
            ],
          ),
        ),

        SizedBox(height: SizeConfig.h(32)),

        // 3. Equipment Selection
        _buildSectionHeader("Equipment Access", textColor),
        SizedBox(height: SizeConfig.h(16)),
        Row(
          children: [
            Expanded(
              child: _buildEquipmentOption('none', '🏠', 'None\n(Bodyweight)', accentColor, cardColor, isDark, textColor),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: _buildEquipmentOption('basic', '🏋️', 'Basic\n(Dumbbells)', accentColor, cardColor, isDark, textColor),
            ),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: _buildEquipmentOption('gym', '💪', 'Full\nGym', accentColor, cardColor, isDark, textColor),
            ),
          ],
        ),

        SizedBox(height: SizeConfig.h(32)),

        // 4. Muscle Selection
        _buildSectionHeader("Target Muscles", textColor),
        SizedBox(height: SizeConfig.h(16)),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allMuscles.map((muscle) {
            final isSelected = _selectedMuscles.contains(muscle);
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected ? _selectedMuscles.remove(muscle) : _selectedMuscles.add(muscle);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : cardColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black12),
                  ),
                ),
                child: Text(
                  muscle.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.sp(12),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: SizeConfig.h(50)),

        // Generate Button
        SizedBox(
          width: double.infinity,
          height: SizeConfig.h(56),
          child: ElevatedButton(
            onPressed: _generatePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              elevation: 8,
              shadowColor: accentColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              "Generate Plan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.sp(16)),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.h(40)),
      ],
    );
  }

  Widget _buildPlanPreview(Color textColor, Color secondaryText, Color cardColor, Color accentColor, bool isDark) {
    if (_generatedPlan == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeConfig.h(10)),
        Text(
          "Your Plan",
          style: TextStyle(fontSize: SizeConfig.sp(32), fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(height: SizeConfig.h(16)),
        
        // Plan Header Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(SizeConfig.w(24)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.9), accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _generatedPlan!['name'],
                style: TextStyle(
                  fontSize: SizeConfig.sp(26), 
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              if (_generatedPlan!['description'] != null && _generatedPlan!['description'].isNotEmpty) ...[
                SizedBox(height: SizeConfig.h(12)),
                Text(
                  _generatedPlan!['description'],
                  style: TextStyle(
                    fontSize: SizeConfig.sp(14), 
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        SizedBox(height: SizeConfig.h(30)),

        // NEW: Weekly Planner View
        WeeklyPlannerView(
          generatedPlan: _generatedPlan!,
          isDark: isDark, // Pass the theme state
          onPlanUpdated: (updatedPlan) {
            setState(() {
              _generatedPlan = updatedPlan;
            });
          },
        ),

        SizedBox(height: SizeConfig.h(40)),
        
        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _generatedPlan = null),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                  side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Discard", style: TextStyle(color: textColor)),
              ),
            ),
            SizedBox(width: SizeConfig.w(16)),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveAndActivatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text("Save & Activate", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.h(40)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: SizeConfig.sp(12),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: textColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildEquipmentOption(String value, String emoji, String label, Color accentColor, Color cardColor, bool isDark, Color textColor) {
    final isSelected = _equipmentLevel == value;
    return GestureDetector(
      onTap: () => setState(() => _equipmentLevel = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? Colors.white10 : Colors.black12),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: SizeConfig.sp(28))),
            SizedBox(height: SizeConfig.h(8)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : textColor,
                fontWeight: FontWeight.w600,
                fontSize: SizeConfig.sp(11),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getEquipmentList() {
    switch (_equipmentLevel) {
      case 'none':
        return ['bodyweight'];
      case 'basic':
        return ['dumbbells', 'resistance bands', 'bodyweight'];
      case 'gym':
        return ['full gym access'];
      default:
        return ['full gym access'];
    }
  }
}

