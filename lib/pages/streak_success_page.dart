import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class StreakSuccessPage extends StatefulWidget {
  final int newStreak;
  final Color themeColor;
  final IconData icon;
  final String title;

  const StreakSuccessPage({
    super.key,
    required this.newStreak,
    required this.themeColor,
    required this.icon,
    required this.title,
  });

  @override
  State<StreakSuccessPage> createState() => _StreakSuccessPageState();
}

class _StreakSuccessPageState extends State<StreakSuccessPage>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _slamController;
  late AnimationController _celebrationController;
  late AnimationController _backgroundController;
  late AnimationController _fireController;

  // Animations
  late Animation<double> _slamScale;
  late Animation<double> _slamOpacity;
  late Animation<double> _buttonSlide;

  final List<_Ember> _embers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Slam Animation (0.0s - 0.8s)
    _slamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slamScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 5.0, end: 0.8)
            .chain(CurveTween(curve: Curves.easeInQuint)),
        weight: 80,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_slamController);

    _slamOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slamController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 2. Fire Animation (Looping)
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 3. Celebration & Reveal (2.0s - 3.0s)
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _buttonSlide = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Background Loop
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initEmbers();
    _startSequence();
  }

  void _initEmbers() {
    for (int i = 0; i < 30; i++) {
      _embers.add(_Ember(_random));
    }
  }

  // Removed explosion particle generation

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _slamController.forward();
    
    // Slot machine duration is 800ms (highly optimized)
    await Future.delayed(const Duration(milliseconds: 800)); 
    
    // Start celebration animation (pulse/glow effect)
    _celebrationController.forward();
  }

  @override
  void dispose() {
    _slamController.dispose();
    _celebrationController.dispose();
    _backgroundController.dispose();
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Dynamic Background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _BackgroundPainter(
                  color: widget.themeColor,
                  embers: _embers,
                  animationValue: _backgroundController.value,
                ),
              );
            },
          ),

          // 2. Removed explosion particles

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(flex: 2),

                // 3. The Fire Icon (no glow)
                AnimatedBuilder(
                  animation: _slamController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slamOpacity.value,
                      child: Transform.scale(
                        scale: _slamScale.value,
                        child: Text(
                          '🔥',
                          style: TextStyle(
                            fontSize: SizeConfig.w(140),
                            height: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: SizeConfig.h(20)),

                // Motivational text
                AnimatedBuilder(
                  animation: _slamController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _slamOpacity.value,
                      child: Text(
                        'Keep your momentum going!',
                        style: TextStyle(
                          fontSize: SizeConfig.sp(16),
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: SizeConfig.h(40)),

                // 4. The Slot Machine Counter with celebration effect
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    final scale = 1.0 + (_celebrationController.value * 0.1);
                    return Transform.scale(
                      scale: scale,
                      child: SlotMachineCounter(
                        targetValue: widget.newStreak,
                        themeColor: widget.themeColor,
                        celebrationProgress: _celebrationController.value,
                      ),
                    );
                  },
                ),

                SizedBox(height: SizeConfig.h(16)),
                
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: SizeConfig.sp(24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 4.0,
                  ),
                ),

                const Spacer(flex: 3),

                // 5. The Button - Always present but animated
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(32),
                    vertical: SizeConfig.h(32),
                  ),
                  child: AnimatedBuilder(
                    animation: _celebrationController,
                    builder: (context, child) {
                      final isReady = _celebrationController.value > 0.5;
                      
                      return Transform.translate(
                        offset: Offset(0, isReady ? 0 : _buttonSlide.value),
                        child: Opacity(
                          opacity: isReady ? 1.0 : 0.3,
                          child: SizedBox(
                            width: double.infinity,
                            height: SizeConfig.h(60),
                            child: ElevatedButton(
                              onPressed: isReady ? () => Navigator.pop(context) : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: widget.themeColor,
                                disabledBackgroundColor: Colors.white.withOpacity(0.3),
                                disabledForegroundColor: Colors.white.withOpacity(0.5),
                                elevation: isReady ? 10 : 0,
                                shadowColor: widget.themeColor.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(20),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Slot Machine Components ---

class SlotMachineCounter extends StatelessWidget {
  final int targetValue;
  final Color themeColor;
  final double celebrationProgress;

  const SlotMachineCounter({
    super.key,
    required this.targetValue,
    required this.themeColor,
    this.celebrationProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final digits = targetValue.toString().split('').map(int.parse).toList();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: digits.asMap().entries.map((entry) {
        return RollingDigit(
          targetDigit: entry.value,
          duration: const Duration(milliseconds: 800),
          themeColor: themeColor,
          delay: Duration(milliseconds: entry.key * 50),
          celebrationProgress: celebrationProgress,
        );
      }).toList(),
    );
  }
}

class RollingDigit extends StatefulWidget {
  final int targetDigit;
  final Duration duration;
  final Duration delay;
  final Color themeColor;
  final double celebrationProgress;

  const RollingDigit({
    super.key,
    required this.targetDigit,
    required this.duration,
    required this.delay,
    required this.themeColor,
    this.celebrationProgress = 0.0,
  });

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Minimal spins (just 3 + target) for smooth performance
    final totalSteps = 3 + widget.targetDigit; 
    
    _animation = Tween<double>(begin: 0, end: totalSteps.toDouble()).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, // Smoother, more linear curve
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentValue = (_animation.value % 10).floor();
        // Calculate offset for smooth scrolling effect
        final offset = (_animation.value % 1); 
        
        return Container(
          height: SizeConfig.h(120),
          width: SizeConfig.w(80),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Previous Number (fading out/sliding up)
              Transform.translate(
                offset: Offset(0, -offset * SizeConfig.h(120)),
                child: Opacity(
                  opacity: 1.0 - offset,
                  child: _buildDigit(currentValue),
                ),
              ),
              // Next Number (fading in/sliding up)
              Transform.translate(
                offset: Offset(0, (1.0 - offset) * SizeConfig.h(120)),
                child: Opacity(
                  opacity: offset,
                  child: _buildDigit((currentValue + 1) % 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDigit(int digit) {
    // Add celebration glow when animation completes
    final glowIntensity = widget.celebrationProgress;
    
    // Simplified shadows - only add extra glow during celebration
    final shadows = <Shadow>[
      Shadow(
        color: widget.themeColor,
        blurRadius: 20 + (glowIntensity * 30),
        offset: const Offset(0, 4),
      ),
      if (glowIntensity > 0.3) // Only add celebration glow after animation starts
        Shadow(
          color: widget.themeColor.withOpacity(0.5 * glowIntensity),
          blurRadius: 50 * glowIntensity,
          offset: Offset.zero,
        ),
    ];
    
    return Container(
      height: SizeConfig.h(120),
      width: SizeConfig.w(80),
      alignment: Alignment.center,
      child: Text(
        '$digit',
        style: TextStyle(
          fontSize: SizeConfig.sp(100),
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          color: Colors.white,
          height: 1.0,
          shadows: shadows,
        ),
      ),
    );
  }

}

// --- Painters ---

// Removed _EnhancedFirePainter - no longer needed

// Removed explosion particle classes

// Reusing Ember and BackgroundPainter from previous step (included for completeness)
class _Ember {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _Ember(Random random)
      : x = random.nextDouble() * SizeConfig.screenWidth,
        y = SizeConfig.screenHeight + random.nextDouble() * 200,
        size = random.nextDouble() * 4 + 2,
        speed = random.nextDouble() * 2 + 1,
        opacity = random.nextDouble() * 0.5 + 0.1;

  void update() {
    y -= speed;
    if (y < -50) {
      y = SizeConfig.screenHeight + 50;
      x = Random().nextDouble() * SizeConfig.screenWidth;
    }
  }
}

class _BackgroundPainter extends CustomPainter {
  final Color color;
  final List<_Ember> embers;
  final double animationValue;

  _BackgroundPainter({
    required this.color,
    required this.embers,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.8),
        Colors.black,
      ],
      stops: const [0.0, 0.8],
    );
    
    canvas.drawRect(
      rect, 
      Paint()..shader = gradient.createShader(rect),
    );

    for (var ember in embers) {
      ember.update();
      canvas.drawCircle(
        Offset(ember.x, ember.y),
        ember.size,
        Paint()..color = Colors.white.withOpacity(ember.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => true;
}
