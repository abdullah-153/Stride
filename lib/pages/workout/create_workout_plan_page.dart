import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_tracker_frontend/services/workout_plan_builder_service.dart';
import 'package:fitness_tracker_frontend/services/firestore/workout_plan_service.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:fitness_tracker_frontend/providers/theme_provider.dart';
import 'package:fitness_tracker_frontend/providers/user_profile_provider.dart';
import 'package:fitness_tracker_frontend/components/shared/bouncing_dots_indicator.dart';
import 'package:fitness_tracker_frontend/components/workout/planner/weekly_planner_view.dart';
import 'plan_generation_error_screen.dart';

class CreateWorkoutPlanPage extends ConsumerStatefulWidget {
  const CreateWorkoutPlanPage({super.key});

  @override
  ConsumerState<CreateWorkoutPlanPage> createState() =>
      _CreateWorkoutPlanPageState();
}

class _CreateWorkoutPlanPageState extends ConsumerState<CreateWorkoutPlanPage>
    with SingleTickerProviderStateMixin {
  final WorkoutPlanBuilderService _builderService = WorkoutPlanBuilderService();

  String _selectedGoal = 'muscle_gain';
  int _daysPerWeek = 4;
  int _durationWeeks = 4;
  final String _fitnessLevel = 'Intermediate';
  String _equipmentLevel = 'gym';
  final Set<String> _selectedMuscles = {};
  bool _isLoading = false;
  Map<String, dynamic>? _generatedPlan;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Map<String, String>> _goals = [
    {
      'id': 'muscle_gain',
      'label': 'Muscle Gain',
      'emoji': 'Ã°Å¸â€™Âª',
      'desc': 'Build lean mass & strength',
    },
    {
      'id': 'weight_loss',
      'label': 'Weight Loss',
      'emoji': 'Ã°Å¸â€Â¥',
      'desc': 'Burn calories & tone up',
    },
    {
      'id': 'strength',
      'label': 'Strength',
      'emoji': 'Ã°Å¸Ââ€¹Ã¯Â¸Â',
      'desc': 'Focus on power lifting',
    },
    {
      'id': 'endurance',
      'label': 'Endurance',
      'emoji': 'Ã°Å¸ÂÆ’',
      'desc': 'Improve cardio & stamina',
    },
  ];

  final List<String> _allMuscles = [
    'chest',
    'back',
    'legs',
    'shoulders',
    'biceps',
    'triceps',
    'abs',
    'cardio',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
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
          content: Text(
            'Please select at least one target muscle',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    HapticFeedback.mediumImpact();

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
        _animController.reset();
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlanGenerationErrorScreen(
              errorMessage: e.toString(),
              onRetry: () {
                Navigator.pop(context);
                _generatePlan();
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
    HapticFeedback.heavyImpact();

    try {
      final planId = await WorkoutPlanService().createWorkoutPlan(
        userId,
        _generatedPlan!,
      );
      await WorkoutPlanService().setActiveWorkoutPlan(
        userId,
        planId,
        DateTime.now(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ã°Å¸Å¡â‚¬ Plan activated successfully! Let\'s go!',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Color(0xFFCEF24B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isDarkMode = ref.watch(themeProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final userName = userProfile?.name ?? 'Athlete';

    final bgColor = isDarkMode
        ? const Color(0xFF0F0F0F)
        : const Color(0xFFFAFAFA);
    final accentColor = const Color(0xFFCEF24B); // Lime Green
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
    final cardColor = isDarkMode
        ? const Color(0xFF1E1E1E).withOpacity(0.6)
        : Colors.white.withOpacity(0.8);
    final glassBorder = isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDarkMode
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: textColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlurBlob(
              isDarkMode
                  ? accentColor.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.1),
            ),
          ),
          Positioned(
            top: SizeConfig.h(300),
            left: -50,
            child: _buildBlurBlob(
              isDarkMode
                  ? Colors.blue.withOpacity(0.1)
                  : accentColor.withOpacity(0.1),
            ),
          ),

          SafeArea(
            child: _isLoading
                ? _buildLoadingState(accentColor, textColor)
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(24, 10, 24, 40),
                        physics: const BouncingScrollPhysics(),
                        child: _generatedPlan == null
                            ? _buildInputForm(
                                textColor,
                                cardColor,
                                accentColor,
                                glassBorder,
                                isDarkMode,
                                userName,
                              )
                            : _buildPlanPreview(
                                textColor,
                                cardColor,
                                accentColor,
                                glassBorder,
                                isDarkMode,
                              ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildLoadingState(Color accentColor, Color textColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BouncingDotsIndicator(color: accentColor),
          SizedBox(height: 30),
          Text(
            "AI IS CRAFTING YOUR PLAN",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Analyzing biometric data...",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(
    Color textColor,
    Color cardColor,
    Color accentColor,
    Color borderColor,
    bool isDark,
    String userName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ready, $userName? Ã°Å¸Å¡â‚¬",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Let's design a program tailored to your goals.",
          style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.4),
        ),
        SizedBox(height: 40),

        _buildSectionTitle("Primary Goal", textColor),
        SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _goals.length,
            separatorBuilder: (_, __) => SizedBox(width: 14),
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final isSelected = _selectedGoal == goal['id'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedGoal = goal['id']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  width: 120,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? accentColor : borderColor,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(goal['emoji']!, style: TextStyle(fontSize: 32)),
                      SizedBox(height: 12),
                      Text(
                        goal['label']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.black : textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 40),

        _buildSectionTitle("Weekly Schedule", textColor),
        SizedBox(height: 16),
        _buildGlassCard(
          cardColor,
          borderColor,
          child: Column(
            children: [
              _buildSliderRow(
                "Days / Week",
                _daysPerWeek,
                3.0,
                7.0,
                7,
                (v) => setState(() => _daysPerWeek = v.toInt()),
                "days",
                accentColor,
                textColor,
                isDark,
              ),
              Divider(
                height: 24,
                color: isDark ? Colors.white10 : Colors.black12,
              ),
              _buildSliderRow(
                "Program Duration",
                _durationWeeks,
                4.0,
                12.0,
                8,
                (v) => setState(() => _durationWeeks = v.toInt()),
                "weeks",
                accentColor,
                textColor,
                isDark,
              ),
            ],
          ),
        ),

        SizedBox(height: 40),

        _buildSectionTitle("Available Equipment", textColor),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildEquipmentCard(
                'none',
                'Ã°Å¸ÂÂ ',
                'Home',
                accentColor,
                cardColor,
                borderColor,
                textColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEquipmentCard(
                'basic',
                'Ã°Å¸â€â€',
                'Basic',
                accentColor,
                cardColor,
                borderColor,
                textColor,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEquipmentCard(
                'gym',
                'Ã¢Å¡Â¡',
                'Gym',
                accentColor,
                cardColor,
                borderColor,
                textColor,
              ),
            ),
          ],
        ),

        SizedBox(height: 40),

        _buildSectionTitle("Target Muscles", textColor),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _allMuscles.map((muscle) {
            final isSelected = _selectedMuscles.contains(muscle);
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  isSelected
                      ? _selectedMuscles.remove(muscle)
                      : _selectedMuscles.add(muscle);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark ? Colors.white24 : Colors.black26),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  muscle.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 50),

        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _generatePlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              elevation: 4,
              shadowColor: accentColor.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20),
                SizedBox(width: 12),
                Text(
                  "GENERATE MY PLAN",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(
    Color bgColor,
    Color borderColor, {
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    int value,
    double min,
    double max,
    int divisions,
    Function(double) onChanged,
    String unit,
    Color accent,
    Color textColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "$value $unit",
                style: TextStyle(
                  color: isDark ? accent : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            activeTrackColor: accent,
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
            thumbColor: Colors.white,
            overlayColor: accent.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCard(
    String val,
    String emoji,
    String label,
    Color accent,
    Color bg,
    Color border,
    Color text,
  ) {
    final isSelected = _equipmentLevel == val;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _equipmentLevel = val);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? accent : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accent : border, width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : text,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color.withOpacity(0.9), // Increased opacity for readability
        fontSize: 16, // Pro size
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPlanPreview(
    Color textColor,
    Color cardColor,
    Color accentColor,
    Color borderColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.2),
            ),
            child: Icon(Icons.check_circle, color: accentColor, size: 40),
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            "PLAN GENERATED",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: accentColor,
            ),
          ),
        ),
        SizedBox(height: 24),

        Text(
          _generatedPlan!['name'],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.1,
          ),
        ),
        SizedBox(height: 12),
        Text(
          _generatedPlan!['description'] ??
              "Your personalized routine is ready.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
        ),

        SizedBox(height: 40),

        WeeklyPlannerView(
          generatedPlan: _generatedPlan!,
          isDark: isDark,
          onPlanUpdated: (updatedPlan) {
            setState(() {
              _generatedPlan = updatedPlan;
            });
          },
        ),

        SizedBox(height: 40),

        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _generatedPlan = null),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  foregroundColor: Colors.redAccent,
                ),
                child: Text(
                  "Discard Plan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _saveAndActivatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "ACTIVATE PLAN",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
