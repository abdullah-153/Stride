import 'package:flutter/material.dart';
import '../onboarding_page.dart';

import '../../utils/size_config.dart';

class WeightPage extends StatefulWidget {
  const WeightPage({super.key});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  final double _minWeightKg = 30;
  final double _maxWeightKg = 200;
  late int _itemCount;
  int _selectedIndex = 30;
  late PageController _pageController;
  bool _isKg = true;

  @override
  void initState() {
    super.initState();
    _itemCount = (_maxWeightKg - _minWeightKg + 1).toInt();
    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.1,
    );
  }

  double get selectedWeight {
    double base = _minWeightKg + _selectedIndex;
    return _isKg ? base : base * 2.20462;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _calculateHeight(int value, bool isSelected) {
    if (value % 10 == 0) {
      return isSelected
          ? SizeConfig.screenHeight * 0.15
          : SizeConfig.screenHeight * 0.12;
    }
    return isSelected
        ? SizeConfig.screenHeight * 0.15
        : SizeConfig.screenHeight * 0.07;
  }

  double _calculateWidth(int value, bool isSelected) {
    if (value % 10 == 0) {
      return isSelected
          ? SizeConfig.screenWidth * 0.04
          : SizeConfig.screenWidth * 0.02;
    }
    return isSelected
        ? SizeConfig.screenWidth * 0.035
        : SizeConfig.screenWidth * 0.015;
  }

  void _switchUnit(bool toKg) {
    if (_isKg == toKg) return;
    double currentWeight = selectedWeight;
    setState(() {
      _isKg = toKg;
      double newKg = toKg ? currentWeight / 2.20462 : currentWeight;
      _selectedIndex = (newKg - _minWeightKg).round();
      _pageController.jumpToPage(_selectedIndex);
    });
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
                "What's your weight?",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.09,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 231, 0, 0),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${selectedWeight.toInt()}",
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Force visible color
                    ),
                  ),
                  SizedBox(width: SizeConfig.screenWidth * 0.02),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: SizeConfig.screenHeight * 0.015,
                    ),
                    child: Text(
                      _isKg ? "kg" : "lbs",
                      style: TextStyle(
                        fontSize: SizeConfig.screenWidth * 0.06,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.025),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    isSelected: [_isKg, !_isKg],
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 231, 0, 0),
                    color: Colors.grey[600],
                    constraints: BoxConstraints(
                      minHeight: SizeConfig.screenHeight * 0.07,
                      minWidth: SizeConfig.screenWidth * 0.3,
                    ),
                    onPressed: (index) => _switchUnit(index == 0),
                    children: [
                      Text(
                        "kg",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.screenWidth * 0.06,
                        ),
                      ),
                      Text(
                        "lbs",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: SizeConfig.screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.04),

              SizedBox(
                height: SizeConfig.screenHeight * 0.25,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _itemCount,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final rawValue = (_minWeightKg + index).toInt();
                    final displayValue = _isKg
                        ? rawValue
                        : (rawValue * 2.20462).round();
                    final isSelected = index == _selectedIndex;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (rawValue % 10 == 0)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: SizeConfig.screenHeight * 0.01,
                            ),
                            child: Text(
                              "$displayValue",
                              style: TextStyle(
                                fontSize: isSelected
                                    ? SizeConfig.screenWidth * 0.04
                                    : SizeConfig.screenWidth * 0.03,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color.fromARGB(255, 231, 0, 0)
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _calculateWidth(rawValue, isSelected),
                          height: _calculateHeight(rawValue, isSelected),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(255, 231, 0, 0)
                                : Colors.grey[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final onboardingState = context
                        .findAncestorStateOfType<OnboardingPageState>();
                    if (onboardingState != null) {
                      final double weightInKg = _isKg
                          ? selectedWeight
                          : (selectedWeight / 2.20462);
                      onboardingState.updateWeight(weightInKg);
                      onboardingState.goToNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: const Color.fromARGB(255, 231, 0, 0),
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
