import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import 'package:flutter/services.dart';

class StreakCelebrationOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAnimationComplete;

  const StreakCelebrationOverlay({
    super.key,
    required this.child,
    this.onAnimationComplete,
  });

  static StreakCelebrationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<StreakCelebrationOverlayState>();
  }

  @override
  State<StreakCelebrationOverlay> createState() => StreakCelebrationOverlayState();
}

class StreakCelebrationOverlayState extends State<StreakCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          for (var particle in _particles) {
            particle.update(_controller.value);
          }
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isAnimating = false;
            _particles.clear();
          });
          widget.onAnimationComplete?.call();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void celebrate() {
    if (_isAnimating) return;

    // Heavy haptic feedback for streak increase
    HapticFeedback.heavyImpact();

    final random = Random();
    _particles.clear();
    
    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: random.nextDouble() * SizeConfig.screenWidth,
        y: SizeConfig.screenHeight + 20, // Start below screen
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
        size: random.nextDouble() * 10 + 5,
        speed: random.nextDouble() * 5 + 5,
        angle: (random.nextDouble() - 0.5) * 0.5, // Slight spread
      ));
    }

    setState(() {
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isAnimating)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: _CelebrationPainter(_particles),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  final double angle;
  double opacity = 1.0;

  _Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
  });

  void update(double t) {
    y -= speed;
    x += sin(y * 0.01) * 2 + angle * 5; // Wavy motion
    opacity = (1.0 - t).clamp(0.0, 1.0);
  }
}

class _CelebrationPainter extends CustomPainter {
  final List<_Particle> particles;

  _CelebrationPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) => true;
}
