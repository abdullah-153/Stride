import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../onboarding_page.dart';

class FitnessLevelPage extends StatefulWidget {
  const FitnessLevelPage({super.key});

  @override
  State<FitnessLevelPage> createState() => _FitnessLevelPageState();
}

class _FitnessLevelPageState extends State<FitnessLevelPage>
    with SingleTickerProviderStateMixin {
  final List<String> _fitnessLevels = [
    '1-2 days/week',
    '3-4 days/week',
    '5-7 days/week',
  ];

  final List<String> _fitnessImages = [
    'lib/assets/images/fitness_beginner.png',
    'lib/assets/images/fitness_intermediate.png',
    'lib/assets/images/fitness_advanced.png',
  ];

  int _selectedLevel = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      lowerBound: 0.85,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    final newLevel = value.round();
    if (newLevel != _selectedLevel) {
      setState(() {
        _selectedLevel = newLevel;
        _controller.forward(from: 0.85);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.07,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.02),

              Text(
                "How often do you work out?",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.085,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 0, 9, 176),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.04),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        _fitnessImages[_selectedLevel],
                        height: SizeConfig.screenHeight * 0.35,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.02),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color.fromARGB(
                          255,
                          220,
                          171,
                          255,
                        ),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: const Color.fromARGB(255, 0, 9, 176),
                        overlayColor: const Color.fromARGB(80, 212, 124, 236),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _selectedLevel.toDouble(),
                        min: 0,
                        max: (_fitnessLevels.length - 1).toDouble(),
                        divisions: _fitnessLevels.length - 1,
                        onChanged: _onSliderChanged,
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.01),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _fitnessLevels.asMap().entries.map((entry) {
                        final index = entry.key;
                        final label = entry.value;
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: SizeConfig.screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: index == _selectedLevel
                                ? const Color.fromARGB(255, 0, 9, 176)
                                : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.04),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final onboardingState = context
                        .findAncestorStateOfType<OnboardingPageState>();
                    if (onboardingState != null) {
                      String activityLevel;
                      switch (_selectedLevel) {
                        case 0:
                          activityLevel = 'inactive';
                          break;
                        case 1:
                          activityLevel = 'moderate';
                          break;
                        default:
                          activityLevel = 'active';
                      }
                      onboardingState.updateFitnessLevel(activityLevel);
                      onboardingState.goToNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: const Color.fromARGB(255, 0, 9, 176),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.08,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
