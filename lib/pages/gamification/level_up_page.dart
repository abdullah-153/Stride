import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/size_config.dart';

class LevelUpPage extends StatefulWidget {
  final int newLevel;
  final int xpGained;
  final int totalXP;

  const LevelUpPage({
    super.key,
    required this.newLevel,
    required this.xpGained,
    required this.totalXP,
  });

  @override
  State<LevelUpPage> createState() => _LevelUpPageState();
}

class _LevelUpPageState extends State<LevelUpPage>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late AnimationController _contentController;
  late AnimationController _numberController;

  late Animation<double> _fillAnimation;
  late Animation<double> _numberFadeAnimation;
  late Animation<double> _numberScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonSlideAnimation;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _waveController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _LevelUpWavePainter(
                  progress: _fillAnimation.value,
                  phase: _waveController.value * 2 * pi,
                ),
              );
            },
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
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(24),
                                vertical: SizeConfig.h(8),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'LEVEL',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(14),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(16)),
                            Text(
                              '${widget.newLevel}',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(140),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: const Color(
                                      0xFF8B5CF6,
                                    ).withOpacity(0.5),
                                    blurRadius: 40,
                                    offset: Offset.zero,
                                  ),
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
                            'LEVEL UP!',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(36),
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(16)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(20),
                              vertical: SizeConfig.h(12),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFF59E0B),
                                  size: SizeConfig.sp(20),
                                ),
                                SizedBox(width: SizeConfig.w(8)),
                                Text(
                                  '+${widget.xpGained} XP',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(16),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: SizeConfig.w(12)),
                                Text(
                                  'Ã¢â‚¬Â¢',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                                SizedBox(width: SizeConfig.w(12)),
                                Text(
                                  '${widget.totalXP} Total',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(14),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(16)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(40),
                            ),
                            child: Text(
                              'Keep pushing your limits and achieving greatness!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.sp(16),
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.9),
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
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF8B5CF6),
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

class _LevelUpWavePainter extends CustomPainter {
  final double progress; // 0..1 (bottom to top)
  final double phase; // wave animation phase

  _LevelUpWavePainter({required this.progress, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        const Color(0xFF8B5CF6), // Purple
        const Color(0xFFA855F7), // Light purple
        const Color(0xFFF59E0B), // Gold
      ],
      stops: const [0.0, 0.5, 1.0],
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
    const waveCount = 3;
    final steps = 60;

    final path = Path();

    path.moveTo(0, size.height);

    for (int i = 0; i <= steps; i++) {
      final x = (i / steps) * size.width;
      final nx = x / size.width;
      final wave = sin(phase + nx * waveCount * 2 * pi);
      final y = waveTop + (wave * waveAmplitude * (1 - progress * 0.5));

      if (i == 0) {
        path.lineTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LevelUpWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phase != phase;
  }
}
