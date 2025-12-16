import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/size_config.dart';
import 'onboarding/age_page.dart';
import 'onboarding/fitness_level_page.dart';
import 'onboarding/gender_page.dart';
import 'onboarding/get_started_page.dart';
import 'onboarding/goal_page.dart';
import 'onboarding/height_page.dart';
import 'onboarding/weight_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;
  late Animation<double> _radiusAnimation;
  late Animation<Color?> _colorAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;
  bool _isGoingForward = true;

  int selectedAge = 0;
  double selectedWeight = 0;
  double selectedHeight = 0;
  String selectedGender = "";
  String selectedFitnessLevel = "";

  void updateAge(int value) => setState(() => selectedAge = value);
  void updateWeight(double value) => setState(() => selectedWeight = value);
  void updateHeight(double value) => setState(() => selectedHeight = value);
  void updateGender(String value) => setState(() => selectedGender = value);
  void updateFitnessLevel(String value) =>
      setState(() => selectedFitnessLevel = value);

  final List<Color> _pageColors = const [
    Colors.black,
    Color.fromARGB(255, 255, 129, 18),
    Color.fromARGB(255, 231, 0, 0),
    Color.fromARGB(255, 0, 9, 176),
    Color.fromARGB(255, 170, 0, 255),
    Colors.green,
    Colors.black,
  ];

  Color? _targetColor;

  @override
  void initState() {
    super.initState();
    final screen =
        WidgetsBinding.instance.window.physicalSize /
        WidgetsBinding.instance.window.devicePixelRatio;
    final maxRadius = sqrt(pow(screen.width, 2) + pow(screen.height, 2));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _radiusAnimation = Tween<double>(begin: 0.0, end: maxRadius).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );

    _pageController.addListener(() {
      final newPage = _pageController.page!.round();
      if (_currentIndex != newPage) setState(() => _currentIndex = newPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _animateToPage(int targetIndex) async {
    if (_isAnimating || targetIndex < 0 || targetIndex >= _pageColors.length) {
      return;
    }

    _isGoingForward = targetIndex > _currentIndex;
    setState(() {
      _isAnimating = true;
      _targetColor = _pageColors[targetIndex];
    });

    _colorAnimation =
        ColorTween(
          begin: _pageColors[_currentIndex],
          end: _targetColor,
        ).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
          ),
        );

    await _animController.forward();
    _pageController.jumpToPage(targetIndex);
    await _animController.reverse();

    setState(() {
      _currentIndex = targetIndex;
      _isAnimating = false;
    });
  }

  Future<void> goToNext() async => _animateToPage(_currentIndex + 1);
  Future<void> goBack() async => _animateToPage(_currentIndex - 1);

  Future<void> _handleBackPressed() async {
    if (_currentIndex == 0) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/startup', (route) => false);
    } else {
      goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: _currentIndex == 6
              ? null
              : AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      size: SizeConfig.w(30),
                      color: _pageColors[_currentIndex],
                    ),
                    padding: const EdgeInsets.only(left: 0),
                    onPressed: _handleBackPressed,
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
          body: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                if (_currentIndex > 0 && _currentIndex != 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: 6,
                      effect: ExpandingDotsEffect(
                        expansionFactor: 2,
                        spacing: 8,
                        radius: 8,
                        dotWidth: 16,
                        dotHeight: 6,
                        activeDotColor: _pageColors[_currentIndex],
                        dotColor: Colors.grey.shade400,
                      ),
                    ),
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      GetStartedPage(),
                      AgePage(),
                      WeightPage(),
                      FitnessLevelPage(),
                      GenderPage(),
                      HeightPage(),
                      GoalPage(
                        selectedAge: selectedAge,
                        selectedWeight: selectedWeight,
                        selectedHeight: selectedHeight,
                        selectedGender: selectedGender,
                        selectedFitnessLevel: selectedFitnessLevel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_currentIndex == 6)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            child: IconButton(
              iconSize: SizeConfig.w(30),
              padding: const EdgeInsets.only(left: 20),
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                size: SizeConfig.w(30),
                color: Colors.white,
              ),
              onPressed: _handleBackPressed,
            ),
          ),

        if (_isAnimating)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final isShrinking =
                    _animController.status == AnimationStatus.reverse;
                return CustomPaint(
                  painter: _CirclePainter(
                    radius: _radiusAnimation.value,
                    color: isShrinking
                        ? _targetColor!
                        : (_colorAnimation.value ?? _pageColors[_currentIndex]),
                    isFromRight: _isGoingForward,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double radius;
  final Color color;
  final bool isFromRight;

  _CirclePainter({
    required this.radius,
    required this.color,
    required this.isFromRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(isFromRight ? size.width : 0, size.height / 2);
    final paint = Paint()..color = color;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) =>
      oldDelegate.radius != radius ||
      oldDelegate.color != color ||
      oldDelegate.isFromRight != isFromRight;
}
