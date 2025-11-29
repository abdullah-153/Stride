import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/size_config.dart';

class GlobalStreakSuccessPage extends StatefulWidget {
  final int globalStreak;
  final Color themeColor;

  const GlobalStreakSuccessPage({
    super.key,
    required this.globalStreak,
    required this.themeColor,
  });

  @override
  State<GlobalStreakSuccessPage> createState() => _GlobalStreakSuccessPageState();
}

class _GlobalStreakSuccessPageState extends State<GlobalStreakSuccessPage>
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
    
    // Hide system UI for full immersion
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Wave animation (continuous)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Fill animation (bottom to top)
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fillAnimation = CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeInOut,
    );
    
    // Content animations
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _numberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Number animations
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
    
    // Text fade animation
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Button slide animation
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
          // Dynamic theme color wave fill animation
          AnimatedBuilder(
            animation: Listenable.merge([_fillController, _waveController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _FullScreenWavePainter(
                  progress: _fillAnimation.value,
                  phase: _waveController.value * 2 * pi,
                  color: widget.themeColor,
                ),
              );
            },
          ),
          
          // Content overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // Animated streak number
                AnimatedBuilder(
                  animation: _numberController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _numberFadeAnimation.value,
                      child: Transform.scale(
                        scale: _numberScaleAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              '${widget.globalStreak}',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(120),
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
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
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.7),
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
                
                // Motivational text
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFadeAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'Perfect Day!',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(32),
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(12)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(40),
                            ),
                            child: Text(
                              'You completed both workout and diet goals today',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.sp(16),
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.8),
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
                
                // Continue button
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
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
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

class _FullScreenWavePainter extends CustomPainter {
  final double progress; // 0..1 (bottom to top)
  final double phase; // wave animation phase
  final Color color;

  _FullScreenWavePainter({
    required this.progress,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // If fully filled, just draw a rectangle
    if (progress >= 0.99) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
      return;
    }

    // Calculate fill height (from bottom)
    final fillHeight = size.height * progress;
    final waveTop = size.height - fillHeight;

    // Wave parameters
    const waveAmplitude = 20.0;
    const waveCount = 3;
    final steps = 60;

    final path = Path();
    
    // Start from bottom left
    path.moveTo(0, size.height);
    
    // Draw wave along the top edge of the fill
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
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FullScreenWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase;
  }
}
