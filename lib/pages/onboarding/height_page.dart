import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../onboarding_page.dart';

class HeightPage extends StatefulWidget {
  const HeightPage({super.key});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  bool _isCm = true;
  final double _minCm = 100;
  final double _maxCm = 220;
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 50;
    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.08,
    );
  }

  double get selectedHeightCm {
    if (_isCm) return _minCm + _selectedIndex;
    final minInches = (_minCm / 2.54).round();
    final totalInches = minInches + _selectedIndex;
    return totalInches * 2.54;
  }

  int get totalItemCount {
    if (_isCm) return (_maxCm - _minCm).toInt() + 1;
    final minInches = (_minCm / 2.54).round();
    final maxInches = (_maxCm / 2.54).round();
    return maxInches - minInches + 1;
  }

  void _switchUnit(bool toCm) {
    if (_isCm == toCm) return;
    final currentCm = selectedHeightCm;
    setState(() {
      _isCm = toCm;
      if (toCm) {
        _selectedIndex = (currentCm - _minCm).round();
      } else {
        final inches = (currentCm / 2.54).round();
        final minInches = (_minCm / 2.54).round();
        _selectedIndex = inches - minInches;
      }
      _pageController.jumpToPage(_selectedIndex);
    });
  }

  double _calculateBarHeight(int value, bool isSelected) {
    if (_isCm) {
      return value % 10 == 0
          ? (isSelected ? 120 : 100)
          : (isSelected ? 80 : 50);
    }
    return value % 12 == 0 ? (isSelected ? 120 : 100) : (isSelected ? 80 : 50);
  }

  double _calculateBarWidth(bool isSelected) => isSelected ? 14 : 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.green;
    final cmValue = selectedHeightCm.round();
    final feetValue = (cmValue / 30.48).floor();
    final inchValue = ((cmValue / 2.54) - feetValue * 12).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.07,
          ),
          child: Column(
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.02),

              Text(
                "What's your height?",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.09,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.015),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: totalItemCount,
                          onPageChanged: (index) =>
                              setState(() => _selectedIndex = index),
                          itemBuilder: (context, index) {
                            final value =
                                index +
                                (_isCm
                                    ? _minCm.toInt()
                                    : (_minCm / 2.54).round());
                            final isSelected = index == _selectedIndex;
                            final displayLabel = _isCm
                                ? (value % 10 == 0 ? "$value" : "")
                                : (value % 12 == 0 ? "${value ~/ 12}" : "");

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (displayLabel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: RotatedBox(
                                      quarterTurns: 1,
                                      child: Text(
                                        displayLabel,
                                        style: TextStyle(
                                          fontSize: isSelected ? 14 : 10,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? accent
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: _calculateBarWidth(isSelected),
                                  height: _calculateBarHeight(
                                    value,
                                    isSelected,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accent
                                        : Colors.grey[500],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: _isCm
                              ? Row(
                                  key: const ValueKey('cm'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$cmValue",
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        "cm",
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.screenWidth * 0.05,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('ftin'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "$feetValue",
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        "ft",
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.screenWidth * 0.05,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$inchValue",
                                      style: TextStyle(
                                        fontSize: SizeConfig.screenWidth * 0.12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        "in",
                                        style: TextStyle(
                                          fontSize:
                                              SizeConfig.screenWidth * 0.05,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: SizeConfig.screenHeight * 0.012,
                  bottom: SizeConfig.screenHeight * 0.02,
                ),
                child: ToggleButtons(
                  isSelected: [_isCm, !_isCm],
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: accent,
                  color: Colors.grey[600],
                  constraints: BoxConstraints(
                    minHeight: SizeConfig.screenHeight * 0.05,
                    minWidth: SizeConfig.screenWidth * 0.18,
                  ),
                  onPressed: (index) => _switchUnit(index == 0),
                  children: [
                    Text(
                      "cm",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.screenWidth * 0.045,
                      ),
                    ),
                    Text(
                      "ft/in",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: SizeConfig.screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final onboardingState = context
                        .findAncestorStateOfType<OnboardingPageState>();
                    if (onboardingState != null) {
                      onboardingState.updateHeight(selectedHeightCm);
                      onboardingState.goToNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: accent,
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
