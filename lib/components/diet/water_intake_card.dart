import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../../pages/water_goal_success_page.dart';

class WaterIntakeSliderCard extends StatefulWidget {
  final bool isDarkMode;

  const WaterIntakeSliderCard({super.key, this.isDarkMode = false});

  @override
  State<WaterIntakeSliderCard> createState() => _WaterIntakeSliderCardState();
}

class _WaterIntakeSliderCardState extends State<WaterIntakeSliderCard>
    with TickerProviderStateMixin {
  double currentIntake = 2000;
  double dailyGoal = 3500;
  double displayedIntake = 2000;
  late AnimationController _waveController;
  late AnimationController _intakeController;
  late Animation<double> _intakeAnimation;

  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _intakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _intakeAnimation =
        Tween<double>(begin: displayedIntake, end: displayedIntake).animate(
          CurvedAnimation(parent: _intakeController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {
            displayedIntake = _intakeAnimation.value;
          });
        });

    _bubbles = List.generate(
      4,
      (index) => Bubble(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        radius: 2 + Random().nextDouble() * 3,
        speed: 0.002 + Random().nextDouble() * 0.003,
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _intakeController.dispose();
    super.dispose();
  }

  void changeIntake(double delta) {
    final newValue = (currentIntake + delta).clamp(0, dailyGoal);

    // Check for goal completion
    if (newValue >= dailyGoal && currentIntake < dailyGoal) {
      _showGoalReached();
    }

    _intakeAnimation =
        Tween<double>(begin: displayedIntake, end: newValue as double).animate(
          CurvedAnimation(parent: _intakeController, curve: Curves.easeOut),
        )..addListener(() {
          setState(() {
            displayedIntake = _intakeAnimation.value;
          });
        });
    _intakeController.forward(from: 0);
    currentIntake = newValue;
  }

  void _showGoalReached() {
    // Navigate to Success Page with Wave Animation
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WaterGoalSuccessPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildQuickAddButton(
    String label,
    double amount,
    Color bg,
    Color textColor,
    double elevation,
  ) {
    // Minimal modern design
    final bool isLightMode = !widget.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => changeIntake(amount),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: isLightMode
                ? Colors.grey.shade50
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLightMode
                  ? Colors.grey.shade200
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isLightMode
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 14,
                  color: isLightMode ? Colors.blue : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLightMode ? Colors.black87 : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final bool dark = widget.isDarkMode;

    double percentage = (displayedIntake / dailyGoal).clamp(0.0, 1.0);

    final Color cardBg = Colors.blue;
    final Color mainTextColor = Colors.white;
    final Color subTextColor = Colors.white70;
    final Color dividerColor = dark
        ? Colors.white24
        : Colors.grey.withOpacity(0.4);

    final Color bottleBg = dark ? const Color(0xFF0B1720) : Colors.white;
    final Color bottleBorderColor = dark ? Colors.white : Colors.black;
    final Color capsuleTextColor = dark ? Colors.white : Colors.black;

    final Color fabBg = dark ? Colors.white10 : Colors.white;
    final Color fabIconColor = dark ? Colors.white : Colors.black87;
    final double fabElevation = dark ? 0 : 2;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left info with fixed width
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: SizeConfig.w(140)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${displayedIntake.toInt()} ml',
                      style: TextStyle(
                        fontSize: 32,
                        color: mainTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal ${dailyGoal.toInt()} ml (${(percentage * 100).toInt()}%)', // Added percentage
                      style: TextStyle(fontSize: 16, color: subTextColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        height: 1,
                        width: double.infinity,
                        color: dividerColor,
                      ),
                    ),
                    Text(
                      'Prepare your stomach \nfor a meal with \n1 or 2 glasses of water',
                      style: TextStyle(fontSize: 13, color: subTextColor),
                    ),
                  ],
                ),
              ),

              SizedBox(width: SizeConfig.w(16)),

              // Bottle + percent capsule
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: SizeConfig.w(60),
                    height: 180,
                    decoration: BoxDecoration(
                      color: bottleBg,
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(color: bottleBorderColor, width: 5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomPaint(
                        painter: _WavePainter(
                          animation: _waveController,
                          percentage: percentage,
                          bubbles: _bubbles,
                          darkMode: dark,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(percentage * 100).toInt()}',
                            style: TextStyle(
                              color: capsuleTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                          Text('%', style: TextStyle(color: capsuleTextColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: SizeConfig.w(16)),

              // + / - buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: FloatingActionButton(
                      mini: true,
                      elevation: fabElevation,
                      backgroundColor: fabBg,
                      onPressed: () => changeIntake(100),
                      child: Icon(Icons.add, size: 25, color: fabIconColor),
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(10)),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: FloatingActionButton(
                      mini: true,
                      elevation: fabElevation,
                      backgroundColor: fabBg,
                      onPressed: () => changeIntake(-100),
                      child: Icon(
                        Icons.remove_outlined,
                        size: 25,
                        color: fabIconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(12)),

          // Quick add buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickAddButton(
                  '250ml',
                  250,
                  fabBg,
                  mainTextColor,
                  fabElevation,
                ),
              ),
              SizedBox(width: SizeConfig.w(8)),
              Expanded(
                child: _buildQuickAddButton(
                  '500ml',
                  500,
                  fabBg,
                  mainTextColor,
                  fabElevation,
                ),
              ),
              SizedBox(width: SizeConfig.w(8)),
              Expanded(
                child: _buildQuickAddButton(
                  '1L',
                  1000,
                  fabBg,
                  mainTextColor,
                  fabElevation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Bubble model
class Bubble {
  double x;
  double y;
  double radius;
  double speed;

  Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });
}

// Custom Painter for Wave + Bubbles
class _WavePainter extends CustomPainter {
  final Animation<double> animation;
  final double percentage;
  final List<Bubble> bubbles;
  final bool darkMode;

  _WavePainter({
    required this.animation,
    required this.percentage,
    required this.bubbles,
    this.darkMode = false,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(size.width / 2),
    );
    canvas.clipRRect(rrect);

    final Paint paintBg = Paint()
      ..color = darkMode
          ? Colors.blue.shade700.withOpacity(0.45)
          : Colors.lightBlue.shade100;
    final Paint paintFg = Paint()..color = Colors.blue;

    final double waveHeight = size.height * (1 - percentage);

    // Background wave
    final Path pathBg = Path();
    pathBg.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double y =
          waveHeight +
          6 * sin((x / size.width * 2 * pi) + (animation.value * pi));
      pathBg.lineTo(x, y);
    }
    pathBg.lineTo(size.width, size.height);
    pathBg.close();
    canvas.drawPath(pathBg, paintBg);

    // Foreground wave
    final Path pathFg = Path();
    pathFg.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double y =
          waveHeight +
          8 * sin((x / size.width * 2 * pi) + (animation.value * 2 * pi));
      pathFg.lineTo(x, y);
    }
    pathFg.lineTo(size.width, size.height);
    pathFg.close();
    canvas.drawPath(pathFg, paintFg);

    // Bubbles
    final Paint bubblePaint = Paint()
      ..color = (darkMode
          ? Colors.white.withOpacity(0.15)
          : Colors.white.withOpacity(0.8));

    for (var bubble in bubbles) {
      final double bx = bubble.x * size.width;
      final double by = waveHeight + bubble.y * (size.height - waveHeight);
      canvas.drawCircle(Offset(bx, by), bubble.radius, bubblePaint);

      bubble.y -= bubble.speed;
      if (bubble.y < 0) bubble.y = 1.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
