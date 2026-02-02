import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../components/onboarding/weight_selector.dart';
import '../components/onboarding/height_selector.dart';
import '../components/onboarding/age_selector.dart';
import '../models/user_profile_model.dart';

class BodyUpdateSheet extends StatefulWidget {
  final double currentWeight;
  final double currentHeight;
  final int currentAge;
  final bool isDarkMode;

  const BodyUpdateSheet({
    super.key,
    required this.currentWeight,
    required this.currentHeight,
    required this.currentAge,
    required this.isDarkMode,
    required this.preferredUnits,
  });

  final UnitPreference preferredUnits;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required double currentWeight,
    required double currentHeight,
    required int currentAge,
    required bool isDarkMode,
    required UnitPreference preferredUnits,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BodyUpdateSheet(
        currentWeight: currentWeight,
        currentHeight: currentHeight,
        currentAge: currentAge,
        isDarkMode: isDarkMode,
        preferredUnits: preferredUnits,
      ),
    );
  }

  @override
  State<BodyUpdateSheet> createState() => _BodyUpdateSheetState();
}

class _BodyUpdateSheetState extends State<BodyUpdateSheet> {
  late PageController _pageController;
  int _currentPage = 0;

  late double _weight;
  late double _height;
  late int _age;
  late bool _isMetric;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _weight = widget.currentWeight;
    _height = widget.currentHeight;
    _age = widget.currentAge;
    _isMetric = widget.preferredUnits == UnitPreference.metric;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context, {
        'weight': _weight,
        'height': _height,
        'age': _age,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      height: SizeConfig.screenHeight * 0.85,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(SizeConfig.w(24)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _currentPage == 0
                      ? "Update Weight"
                      : _currentPage == 1
                      ? "Update Height"
                      : "Update Age",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(20),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 4,
                  color: index <= _currentPage
                      ? (_currentPage == 0
                            ? Colors.orange
                            : _currentPage == 1
                            ? Colors.green
                            : const Color(0xFFFF7700))
                      : Colors.grey[300],
                ),
              ),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                Center(
                  child: WeightSelector(
                    initialWeight: _weight,
                    isKg: _isMetric,
                    onWeightChanged: (val) => _weight = val,
                  ),
                ),
                Center(
                  child: HeightSelector(
                    initialHeight: _height,
                    isCm: _isMetric,
                    onHeightChanged: (val) => _height = val,
                  ),
                ),
                Center(
                  child: AgeSelector(
                    initialAge: _age,
                    onAgeChanged: (val) => _age = val,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(SizeConfig.w(24)),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentPage == 0
                      ? Colors.orange
                      : _currentPage == 1
                      ? Colors.green
                      : const Color(0xFFFF7700),
                  padding: EdgeInsets.symmetric(vertical: SizeConfig.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == 2 ? "Save Updates" : "Next",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
