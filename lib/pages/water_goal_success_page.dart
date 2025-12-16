import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/size_config.dart';

class WaterGoalSuccessPage extends StatefulWidget {
  final VoidCallback? onClose; // Optional callback

  const WaterGoalSuccessPage({super.key, this.onClose});

  @override
  State<WaterGoalSuccessPage> createState() => _WaterGoalSuccessPageState();
}

class _WaterGoalSuccessPageState extends State<WaterGoalSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _waveController;
  late Animation<double> _fillAnimation;
  late Animation<double> _textFadeAnimation;

  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();

    // Wave motion controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Fill up controller (bottom to top)
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Fill animation: 0.0 (empty/bottom) -> 1.2 (slightly over full/top)
    _fillAnimation = Tween<double>(begin: 0.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Text fade in: Starts halfway through fill
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fillController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Initial Bubbles
    for (int i = 0; i < 15; i++) {
      _bubbles.add(Bubble(
        x: Random().nextDouble(),
        y: Random().nextDouble(), // Relative to wave height
        radius: 4 + Random().nextDouble() * 8,
        speed: 0.005 + Random().nextDouble() * 0.01,
      ));
    }

    // Start animation
    _fillController.forward();
  }

  @override
  void dispose() {
    _fillController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
      body: Stack(
        children: [
          // Wave Background
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _waveController]),
            builder: (context, child) {
              return CustomPaint(
                painter: FullScreenWavePainter(
                  waveAnimation: _waveController,
                  fillPercent: _fillAnimation.value,
                  bubbles: _bubbles,
                  color: const Color(0xFF3B82F6), // Blue 500
                ),
                size: Size.infinite,
              );
            },
          ),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _textFadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textFadeAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.water_drop_rounded, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Hydration Goal Met!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        shadows: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You've reached your daily water intake target. Stay hydrated and keep glowing!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                          widget.onClose?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "CONTINUE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
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
    );
  }
}

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

class FullScreenWavePainter extends CustomPainter {
  final Animation<double> waveAnimation;
  final double fillPercent;
  final List<Bubble> bubbles;
  final Color color;

  FullScreenWavePainter({
    required this.waveAnimation,
    required this.fillPercent,
    required this.bubbles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Fill percent 0 -> Height (Bottom)
    // Fill percent 1 -> 0 (Top)
    
    // Logic: 
    // If fillPercent <= 1.0, we draw a wave at height * (1 - fillPercent).
    // If fillPercent > 1.0, we just draw full rect (screen covered).
    
    if (fillPercent >= 1.2) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = color,
      );
      return;
    }

    final double baseHeight = size.height * (1 - fillPercent);
    
    // Paint Setup
    final Paint wavePaint = Paint()..color = color;
    final Paint bgWavePaint = Paint()..color = color.withOpacity(0.6);

    // Draw Background Wave (Offset phase)
    final Path bgPath = Path();
    bgPath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double y = baseHeight + 
          (15 * sin((x / size.width * 2 * pi) + (waveAnimation.value * 2 * pi) + 2)); 
      // + 2 radian phase shift for background
      bgPath.lineTo(x, y);
    }
    bgPath.lineTo(size.width, size.height);
    bgPath.close();
    canvas.drawPath(bgPath, bgWavePaint);

    // Draw Foreground Wave
    final Path fgPath = Path();
    fgPath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final double y = baseHeight + 
          (20 * sin((x / size.width * 2 * pi) + (waveAnimation.value * 2 * pi)));
      fgPath.lineTo(x, y);
    }
    fgPath.lineTo(size.width, size.height);
    fgPath.close();
    canvas.drawPath(fgPath, wavePaint);

    // Draw Bubbles (Rising in the water)
    // Bubbles exist BELOW the wave line (y > waveY)
    final Paint bubblePaint = Paint()..color = Colors.white.withOpacity(0.2);
    
    for (var bubble in bubbles) {
      // Update bubble position
      bubble.y -= bubble.speed;
      if (bubble.y < 0) bubble.y = 1.0; // Reset to bottom relative

      // Map 0..1 bubbleY to (WaveHeight)..Size.Height
      final double waterDepth = size.height - baseHeight;
      if (waterDepth <= 0) continue;

      final double by = baseHeight + (bubble.y * waterDepth);
      final double bx = bubble.x * size.width;

      // Only draw if sufficiently below the surface
      if (by > baseHeight + 10) {
        canvas.drawCircle(Offset(bx, by), bubble.radius, bubblePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FullScreenWavePainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
