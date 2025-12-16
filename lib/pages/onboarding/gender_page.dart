import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../onboarding_page.dart';

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  int? _selectedIndex;
  final Color accentColor = const Color.fromARGB(255, 170, 0, 255);

  final List<Map<String, dynamic>> _genders = [
    {'label': 'Male', 'icon': Icons.male},
    {'label': 'Female', 'icon': Icons.female},
  ];

  @override
  Widget build(BuildContext context) {
    double circleSize = SizeConfig.screenHeight * 0.22;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.07,
          ),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.01),

              Text(
                "Choose your gender",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.09,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_genders.length, (index) {
                    final bool isSelected = _selectedIndex == index;

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.screenHeight * 0.01,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: isSelected
                                    ? Border.all(color: accentColor, width: 4)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _genders[index]['icon'],
                                    size: circleSize * 0.4,
                                    color: isSelected
                                        ? accentColor
                                        : Colors.grey,
                                  ),
                                  SizedBox(height: circleSize * 0.05),
                                  Text(
                                    _genders[index]['label'],
                                    style: TextStyle(
                                      fontSize: SizeConfig.screenWidth * 0.05,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? accentColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              top: circleSize * -0.05,
                              right: circleSize * -0.05,
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: AnimatedScale(
                                  scale: isSelected ? 1 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.05),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedIndex != null
                      ? () {
                          final onboardingState = context
                              .findAncestorStateOfType<OnboardingPageState>();
                          if (onboardingState != null) {
                            onboardingState.updateGender(
                              _genders[_selectedIndex!]['label'],
                            );
                            onboardingState.goToNext();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: accentColor,
                    disabledBackgroundColor: Colors.grey[400],
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
