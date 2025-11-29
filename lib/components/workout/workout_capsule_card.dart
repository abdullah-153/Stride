import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../utils/size_config.dart';
import '../../utils/animations.dart';

class WorkoutCapsuleCard extends StatefulWidget {
  final bool isDarkMode;
  final bool hasOngoing;
  final String workoutName;
  final int minutes;
  final int kcal;
  final int points;
  final bool isPlaying;
  final bool isCompleted;
  final String heroTag;
  final VoidCallback onToggle;
  final int? remainingSeconds;
  final Color? activeColor;

  const WorkoutCapsuleCard({
    super.key,
    required this.isDarkMode,
    required this.hasOngoing,
    required this.workoutName,
    required this.minutes,
    required this.kcal,
    required this.points,
    required this.isPlaying,
    required this.isCompleted,
    required this.heroTag,
    required this.onToggle,
    this.remainingSeconds,
    this.activeColor,
  });

  @override
  State<WorkoutCapsuleCard> createState() => _WorkoutCapsuleCardState();
}

class _WorkoutCapsuleCardState extends State<WorkoutCapsuleCard>
    with TickerProviderStateMixin {
  late final AnimationController _fillCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _rotateCtrl;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // Slowed down
    _rotateCtrl = AnimationController(vsync: this, duration: kAnimMedium);

    if (widget.isCompleted) {
      _rotateCtrl.value = 1.0;
      _fillCtrl.value = 1.0;
    } else if (widget.isPlaying) {
      _fillCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutCapsuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _fillCtrl.forward();
      } else {
        _fillCtrl.reverse();
      }
    }
    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _rotateCtrl.forward(from: 0.0);
        _fillCtrl.forward();
      } else {
        _rotateCtrl.reverse();
        _fillCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fillCtrl.dispose();
    _waveCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;

    final idleCard = dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final playCard = dark ? Colors.white : Colors.black;

    final idleTitle = dark ? Colors.white : Colors.black87;
    final playTitle = dark ? Colors.black : Colors.white;
    final idleSubtitle = dark ? Colors.white70 : Colors.grey.shade700;
    final playSubtitle = dark ? Colors.black54 : Colors.white70;

    // Vibrant accent color for waves in dark mode
    final waveColor = dark
        ? const Color.fromRGBO(206, 235, 75, 1)
        : Colors.black87;
    final waveOpacity = dark ? 0.8 : 1.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_fillCtrl, _waveCtrl, _rotateCtrl]),
      builder: (context, _) {
        final t = _fillCtrl.value.clamp(0.0, 1.0);
        final phase = _waveCtrl.value * 2 * pi;
        final rotateT = _rotateCtrl.value;

        final titleColor = Color.lerp(idleTitle, playTitle, t)!;
        final subtitleColor = Color.lerp(idleSubtitle, playSubtitle, t)!;

        // core follows soft with a slight delay
        const coreDelay = 0.28;
        final coreProgress = ((t - coreDelay) / (1 - coreDelay)).clamp(
          0.0,
          1.0,
        );

        return Container(
          margin: EdgeInsets.only(bottom: SizeConfig.h(18)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: dark ? Colors.black26 : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: dark ? Colors.white12 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Background Color
                Positioned.fill(child: Container(color: idleCard)),

                // Soft wash layer (Waves)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WaveFillPainter(
                      progress: t,
                      phase: phase,
                      color: waveColor.withValues(alpha: waveOpacity),
                      borderRadius: 0, // Clipped by parent
                      waveAmplitude: 14,
                      waveCount: 2,
                      originRight: true,
                    ),
                  ),
                ),

                // Solid core layer (Waves)
                if (coreProgress > 0.01)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WaveFillPainter(
                        progress: coreProgress,
                        phase: phase + 1.2,
                        color: playCard.withValues(alpha: 0.1),
                        borderRadius: 0, // Clipped by parent
                        waveAmplitude: 10,
                        waveCount: 2,
                        originRight: true,
                        originInsetPx: 0.0,
                      ),
                    ),
                  ),

                // Content on top
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(14),
                    vertical: SizeConfig.h(12),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: SizeConfig.w(85),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) =>
                                        FadeTransition(
                                          opacity: anim,
                                          child: child,
                                        ),
                                    child: Text(
                                      widget.remainingSeconds != null
                                          ? '${(widget.remainingSeconds! ~/ 60).toString().padLeft(2, '0')}:${(widget.remainingSeconds! % 60).toString().padLeft(2, '0')}'
                                          : widget.minutes.toString(),
                                      key: ValueKey<String>(
                                        widget.remainingSeconds != null
                                            ? 'timer_${widget.remainingSeconds}'
                                            : 'static',
                                      ),
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize:
                                            widget.remainingSeconds != null
                                            ? 42
                                            : 48,
                                        fontWeight: FontWeight.w900,
                                        height: 1.0,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: SizeConfig.h(6)),
                                Text(
                                  widget.remainingSeconds != null
                                      ? 'left'
                                      : 'mins',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: SizeConfig.sp(14),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: SizeConfig.w(12)),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hasOngoing
                                  ? 'Continue your workout'
                                  : 'Recommended Workout',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(12),
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(6)),
                            Text(
                              widget.workoutName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: SizeConfig.sp(18),
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(8)),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: SizeConfig.sp(12),
                                  color: subtitleColor,
                                ),
                                SizedBox(width: SizeConfig.w(6)),
                                Text(
                                  '${widget.points} pts',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(12),
                                    color: subtitleColor,
                                  ),
                                ),
                                SizedBox(width: SizeConfig.w(12)),
                                Icon(
                                  Icons.local_fire_department,
                                  size: SizeConfig.sp(12),
                                  color: subtitleColor,
                                ),
                                SizedBox(width: SizeConfig.w(6)),
                                Text(
                                  '${widget.kcal} kcal',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(12),
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: SizeConfig.w(12)),

                      Hero(
                        tag: widget.heroTag,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onToggle();
                            },
                            borderRadius: BorderRadius.circular(
                              coreProgress > 0.98 ? 12 : 30,
                            ), // Match animated container
                            child: Transform.rotate(
                              angle: rotateT * pi,
                              child: AnimatedContainer(
                                duration: kAnimMedium,
                                curve: kCurveFastOutSlowIn,
                                padding: EdgeInsets.all(SizeConfig.w(10)),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (coreProgress > 0.5)
                                      ? (dark ? Colors.white : Colors.black)
                                      : dark
                                      ? Colors.black
                                      : Colors.white,
                                  boxShadow: (coreProgress > 0.5)
                                      ? [
                                          BoxShadow(
                                            color: const Color.fromRGBO(
                                              206,
                                              242,
                                              75,
                                              0.5,
                                            ),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: const Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.04,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                  border: !(coreProgress > 0.5)
                                      ? Border.all(
                                          color: dark
                                              ? Colors.black45
                                              : Colors.grey.shade300,
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: AnimatedSwitcher(
                                  duration: kAnimShort,
                                  transitionBuilder: (child, anim) =>
                                      RotationTransition(
                                        turns: Tween<double>(
                                          begin: 0.8,
                                          end: 1.0,
                                        ).animate(anim),
                                        child: ScaleTransition(
                                          scale: anim,
                                          child: child,
                                        ),
                                      ),
                                  child: Icon(
                                    widget.isCompleted
                                        ? Icons.restart_alt_rounded
                                        : widget.isPlaying
                                        ? Icons.pause_rounded
                                        : (widget.remainingSeconds != null &&
                                              widget.remainingSeconds! < 10)
                                        ? Icons.check_rounded
                                        : Icons.play_arrow_rounded,
                                    key: ValueKey<String>(
                                      widget.isCompleted
                                          ? 'restart'
                                          : widget.isPlaying
                                          ? 'pause'
                                          : (widget.remainingSeconds != null &&
                                                widget.remainingSeconds! < 10)
                                          ? 'complete'
                                          : 'play',
                                    ),
                                    color: (coreProgress > 0.5)
                                        ? (dark ? Colors.black : Colors.white)
                                        : (dark
                                              ? Colors.white70
                                              : Colors.black87),
                                    size: SizeConfig.sp(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WaveFillPainter extends CustomPainter {
  final double progress; // 0..1
  final double phase; // radians for wave
  final Color color;
  final double borderRadius;
  final double waveAmplitude;
  final int waveCount;
  final bool originRight;
  final double originInsetPx;

  _WaveFillPainter({
    required this.progress,
    required this.phase,
    required this.color,
    required this.borderRadius,
    this.waveAmplitude = 12.0,
    this.waveCount = 2,
    this.originRight = true,
    this.originInsetPx = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final paint = Paint()..color = color;

    // Optimization: If progress is full, just draw a rect and exit.
    // This ensures no wave calculation artifacts and a solid fill.
    if (progress >= 0.99) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final fullW = size.width;
    final fillW = fullW * progress;
    final inset = originInsetPx.clamp(0.0, fullW * 0.45);
    final leftBase = originRight ? (fullW - inset - fillW) : inset;

    final path = Path();
    // Start path far enough to the left/right to cover any wave amplitude
    path.moveTo(fullW + waveAmplitude, 0);

    final int steps = 40;
    for (int i = 0; i <= steps; i++) {
      final y = (i / steps) * size.height;
      final ny = y / size.height;
      final wave = sin(phase + ny * waveCount * 2 * pi);
      // Amplitude goes to 0 as progress goes to 1
      final amp = waveAmplitude * (1 - progress);
      final dx = amp * wave;
      final x = originRight
          ? (leftBase + dx)
          : (leftBase + (progress * fullW) - dx);
      path.lineTo(x, y);
    }

    path.lineTo(fullW + waveAmplitude, size.height);
    path.close();

    // No need to clip here as the parent Stack has a ClipRRect
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}
