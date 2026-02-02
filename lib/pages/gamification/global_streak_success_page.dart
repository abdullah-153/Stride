import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/size_config.dart';

class GlobalStreakSuccessPage extends StatefulWidget {
  final int globalStreak;
  final Color themeColor;
  final String title;
  final String subtitle;

  const GlobalStreakSuccessPage({
    super.key,
    required this.globalStreak,
    required this.themeColor,
    this.title = 'Perfect Day!',
    this.subtitle = 'You completed both workout and diet goals today',
  });

  @override
  State<GlobalStreakSuccessPage> createState() =>
      _GlobalStreakSuccessPageState();
}

class _GlobalStreakSuccessPageState extends State<GlobalStreakSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late AnimationController _contentController;
  late AnimationController _numberController;
  late AnimationController _confettiController;

  late Animation<double> _fillAnimation;
  late Animation<double> _numberFadeAnimation;
  late Animation<double> _numberScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonSlideAnimation;

  final List<_ConfettiParticle> _confetti = [];

  @override
  void initState() {
    super.initState();

    HapticFeedback.heavyImpact();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            setState(() {
              for (var p in _confetti) {
                p.update(SizeConfig.screenHeight);
              }
            });
          })
          ..repeat();

    _numberFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _numberController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _numberScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _numberController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _fillController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _numberController.forward();
    _contentController.forward();

    _generateConfetti();
  }

  void _generateConfetti() {
    final random = Random();
    for (int i = 0; i < 60; i++) {
      _confetti.add(
        _ConfettiParticle(
          x: random.nextDouble() * SizeConfig.screenWidth,
          y: -random.nextDouble() * 200 - 50,
          color: [
            widget.themeColor,
            widget.themeColor.withOpacity(0.7),
            Colors.white,
            Colors.white.withOpacity(0.7),
          ][random.nextInt(4)],
          size: random.nextDouble() * 8 + 4,
          speed: random.nextDouble() * 3 + 2,
          wobble: random.nextDouble() * 2 - 1,
          rotation: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _waveController.dispose();
    _fillController.dispose();
    _contentController.dispose();
    _numberController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final textOnWave = widget.themeColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _waveController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _PremiumWavePainter(
                  progress: _fillAnimation.value,
                  phase: _waveController.value * 2 * pi,
                  color: widget.themeColor,
                ),
              );
            },
          ),

          if (_confetti.isNotEmpty)
            IgnorePointer(
              child: CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(_confetti),
              ),
            ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                AnimatedBuilder(
                  animation: _numberController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _numberFadeAnimation.value,
                      child: Transform.scale(
                        scale: _numberScaleAnimation.value,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(SizeConfig.w(20)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: textOnWave.withOpacity(0.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: textOnWave.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: SizeConfig.sp(50),
                                color: textOnWave,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(24)),
                            Text(
                              '${widget.globalStreak}',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(120),
                                fontWeight: FontWeight.w900,
                                color: textOnWave,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: textOnWave.withOpacity(0.5),
                                    blurRadius: 40,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(8)),
                            Text(
                              'DAY STREAK',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(16),
                                fontWeight: FontWeight.w700,
                                color: textOnWave.withOpacity(0.8),
                                letterSpacing: 4.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: SizeConfig.h(40)),

                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: SizeConfig.sp(32),
                              fontWeight: FontWeight.w800,
                              color: textOnWave,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(40),
                            ),
                            child: Text(
                              widget.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.sp(16),
                                fontWeight: FontWeight.w400,
                                color: textOnWave.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(flex: 3),

                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _buttonSlideAnimation.value),
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(32),
                            vertical: SizeConfig.h(32),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: SizeConfig.h(60),
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: textOnWave,
                                foregroundColor: widget.themeColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(18),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumWavePainter extends CustomPainter {
  final double progress;
  final double phase;
  final Color color;

  _PremiumWavePainter({
    required this.progress,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        color,
        color.withOpacity(0.9),
        HSLColor.fromColor(color)
            .withLightness(
              (HSLColor.fromColor(color).lightness + 0.1).clamp(0, 1),
            )
            .toColor(),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    if (progress >= 0.99) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final fillHeight = size.height * progress;
    final waveTop = size.height - fillHeight;

    const waveAmplitude = 25.0;
    const waveCount = 2.5;
    const steps = 60;

    final path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i <= steps; i++) {
      final x = (i / steps) * size.width;
      final nx = x / size.width;
      final wave = sin(phase + nx * waveCount * 2 * pi);
      final y = waveTop + (wave * waveAmplitude * (1 - progress * 0.5));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PremiumWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  final double wobble;
  double rotation;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.wobble,
    required this.rotation,
  });

  void update(double screenHeight) {
    y += speed * 2;
    x += sin(y * 0.01) * wobble;
    rotation += 0.05;

    if (y > screenHeight + 50) {
      y = -20;
      x = Random().nextDouble() * SizeConfig.screenWidth;
    }
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
