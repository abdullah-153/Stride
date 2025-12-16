import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui'; // Required for FontFeature
import '../../utils/size_config.dart';
import '../../utils/animations.dart'; // Assuming this exists, otherwise replace kAnim constants

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
  final VoidCallback? onComplete;
  final VoidCallback? onNext; // Added missing property
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
    this.onComplete,
    this.onNext,
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

  // Local state to handle "Optimistic UI" updates (instant feedback)
  bool _optimisticCompleted = false;

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

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

    // 1. Detect if the workout content has changed (e.g. via Next button)
    if (widget.workoutName != oldWidget.workoutName) {
      // Reset state for the new workout
      if (mounted) {
         _optimisticCompleted = false;
         _rotateCtrl.value = 0.0;
         // Reset wave based on initial state of new workout
         _fillCtrl.value = widget.isPlaying ? 1.0 : 0.0; 
      }
    }

    // 2. Sync Optimistic state with Reality
    // If the parent widget confirms completion, we reset our local flag
    // so strictly internal logic doesn't drift.
    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        // Confirmed complete by parent
        _optimisticCompleted = false; 
        _rotateCtrl.forward(from: 0.0);
        _fillCtrl.reverse();
      } else {
        // Reset (e.g. user restarted workout)
        _optimisticCompleted = false;
        _rotateCtrl.reverse();
        if (widget.isPlaying) {
          _fillCtrl.forward();
        } else {
          _fillCtrl.reverse();
        }
      }
    }

    // 3. Handle playing state changes
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _fillCtrl.forward();
      } else {
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

  // Helper to determine if we should show completed state visually
  bool get _effectiveCompleted => widget.isCompleted || _optimisticCompleted;

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;

    // --- Color Palette (Lime / Black / Grey) ---
    // --- Color Palette (Lime / Black / Grey) ---
    final idleCard = dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    
    // Play Card Background - Used for Wave now
    final playCard = const Color(0xFFCEF24B); 

    // Completed state - Subtle Minimal Premium
    // Dark Grey Background (instead of harsh black)
    final completedBg = dark 
        ? const Color(0xFF2C2C2E) 
        : const Color(0xFF2C2C2E); 
    
    final completedText = Colors.white; // Clean white text
    final completedBorder = Colors.transparent; // No border for cleaner look

    // Text Colors
    final idleTitle = dark ? Colors.white : Colors.black87;
    final idleSubtitle = dark ? Colors.white70 : Colors.grey.shade700;
    
    // When playing (Lime Background via Wave), text should be Black for contrast
    final playTitle = Colors.black; 
    final playSubtitle = Colors.black87;

    final waveColor = const Color(0xFFCEF24B); // Lime Wave
    final waveOpacity = 1.0; 

    return AnimatedBuilder(
      animation: Listenable.merge([_fillCtrl, _waveCtrl, _rotateCtrl]),
      builder: (context, _) {
        final t = _fillCtrl.value.clamp(0.0, 1.0);
        final phase = _waveCtrl.value * 2 * pi;
        final rotateT = _rotateCtrl.value;

        // NO FADE ANIMATION for background
        final cardBgColor = _effectiveCompleted 
            ? completedBg 
            : idleCard;

        // Text colors interpolate
        final titleColor = _effectiveCompleted
            ? completedText
            : Color.lerp(idleTitle, playTitle, t)!;
        final subtitleColor = _effectiveCompleted
            ? completedText.withOpacity(0.7)
            : Color.lerp(idleSubtitle, playSubtitle, t)!;
            
        // Border Color
        final idleBorder = dark ? Colors.white12 : Colors.grey.shade300;
        final activeBorder = const Color(0xFFB5D93B);
        
        final borderColor = _effectiveCompleted
            ? completedBorder
            : Color.lerp(idleBorder, activeBorder, t)!;

        // Restore coreProgress calculation
        const coreDelay = 0.28;
        final coreProgress = ((t - coreDelay) / (1 - coreDelay)).clamp(
          0.0,
          1.0,
        );

        // LOGIC FOR TICK BUTTON VISIBILITY
        final showTickButton = !widget.isPlaying && 
                               !_effectiveCompleted && 
                               widget.remainingSeconds != null && 
                               widget.onComplete != null;

        return Container(
          margin: EdgeInsets.only(bottom: SizeConfig.h(18)),
          decoration: BoxDecoration(
            color: cardBgColor, 
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (_effectiveCompleted)
                 // No shadow for completed state
                 BoxShadow(color: Colors.transparent)
              else if (t > 0.01) 
                 BoxShadow(
                  color: const Color(0xFFCEF24B).withOpacity(0.15), 
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: dark ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
            border: Border.all(
              color: borderColor,
              width: _effectiveCompleted ? 1.5 : 1,
            ),
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  
                  // Wave Animation (Handles the "Fill")
                  // We use a single opaque wave for the fill effect
                  if (!_effectiveCompleted && t > 0)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _WaveFillPainter(
                          progress: t,
                          phase: phase,
                          color: waveColor.withOpacity(waveOpacity),
                          borderRadius: 0,
                          waveAmplitude: 14,
                          waveCount: 2,
                          originRight: true,
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
                      crossAxisAlignment: CrossAxisAlignment.center, // Revert to center
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
                                            const FontFeature.tabularFigures(),
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

                        // Animated Button Column
                        Padding(
                          padding: EdgeInsets.only(bottom: SizeConfig.h(6)), // Subtle lift for optical centering
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            // ----------------------------------------------------
                            // NEXT BUTTON (Expands when Completed)
                            // ----------------------------------------------------
                            AnimatedContainer(
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 350),
                              alignment: Alignment.bottomCenter,
                              height: (_effectiveCompleted && widget.onNext != null) ? SizeConfig.h(50) : 0,
                              margin: (_effectiveCompleted && widget.onNext != null)
                                  ? EdgeInsets.only(bottom: SizeConfig.h(12))
                                  : EdgeInsets.zero,
                              child: AnimatedOpacity(
                                opacity: (_effectiveCompleted && widget.onNext != null) ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onNext,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: EdgeInsets.all(SizeConfig.w(10)),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFCEF24B), // Premium Lime
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(206, 242, 75, 0.5),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.skip_next_rounded,
                                          color: Colors.black,
                                          size: SizeConfig.sp(20),
                                          // ...
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // ... (Complete Button) ...

                            
                            // ----------------------------------------------------
                            // COMPLETE BUTTON (Optimized Animation & Response)
                            // ----------------------------------------------------
                            // Only show if NOT completed and Paused/Acting
                            AnimatedContainer(
                              // Use symmetric curve for smooth Forward & Reverse
                              curve: Curves.easeInOutCubic, 
                              duration: const Duration(milliseconds: 350),
                              // Shrink to bottom so it merges into the Play button
                              alignment: Alignment.bottomCenter,
                              height: (showTickButton && !_effectiveCompleted) ? SizeConfig.h(50) : 0,
                              // Animate margin to avoid jumpiness
                              margin: (showTickButton && !_effectiveCompleted) 
                                  ? EdgeInsets.only(bottom: SizeConfig.h(12)) 
                                  : EdgeInsets.zero,
                              child: AnimatedOpacity(
                                opacity: (showTickButton && !_effectiveCompleted) ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        // 1. OPTIMISTIC UPDATE: Instant UI feedback
                                        setState(() {
                                          _optimisticCompleted = true;
                                        });

                                        HapticFeedback.mediumImpact();
                                        
                                        // 2. Trigger Main Animations locally immediately
                                        // Don't wait for parent rebuild
                                        _rotateCtrl.forward(from: 0.0);
                                        _fillCtrl.reverse();

                                        // 3. Fire API call (Background)
                                        widget.onComplete?.call();
                                      },
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: EdgeInsets.all(SizeConfig.w(10)),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFCEF24B), // Lime accent
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  206, 242, 75, 0.5),
                                              blurRadius: 12,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: Colors.black,
                                          size: SizeConfig.sp(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Pause/Play/Restart button
                            Hero(
                              tag: widget.heroTag,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  // Enable onTap for Restart even if completed
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    widget.onToggle();
                                  },
                                  borderRadius: BorderRadius.circular(
                                    coreProgress > 0.98 ? 12 : 30,
                                  ),
                                  child: Transform.rotate(
                                    angle: rotateT * pi,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300), 
                                      curve: Curves.fastOutSlowIn, 
                                      padding: EdgeInsets.all(SizeConfig.w(10)), // Standard padding
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle, 
                                        // Button Color Logic
                                        color: _effectiveCompleted
                                            ? (dark ? const Color(0xFF2C2C2E) : Colors.white) // Dark grey / White for Restart
                                            : (coreProgress > 0.5)
                                                ? Colors.black // Black button on Lime
                                                : (dark ? const Color(0xFF2C2C2E) : Colors.white), // Idle
                                        boxShadow: _effectiveCompleted
                                            ? [
                                                BoxShadow( // Add shadow for depth
                                                  color: dark ? Colors.black26 : Colors.black12,
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                )
                                              ]
                                            : (coreProgress > 0.5)
                                                ? [
                                                    const BoxShadow(
                                                      color: Color.fromRGBO(
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
                                                      color: dark ? Colors.black26 : Colors.black12,
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                        border: !(coreProgress > 0.5) 
                                            ? Border.all(
                                                color: dark
                                                    ? Colors.white12
                                                    : Colors.grey.shade300,
                                                width: 1,
                                              )
                                            : null,
                                      ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 200),
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
                                            _effectiveCompleted
                                                ? Icons.restart_alt_rounded
                                                : widget.isPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                            key: ValueKey<String>(
                                              _effectiveCompleted
                                                  ? 'restart'
                                                  : widget.isPlaying
                                                      ? 'pause'
                                                      : 'play',
                                            ),
                                            color: _effectiveCompleted
                                                ? (dark ? const Color(0xFFCEF24B) : const Color(0xFF5A701E))
                                                : (coreProgress > 0.5)
                                                    ? const Color(0xFFCEF24B) // Lime icon on Black button
                                                    : (dark
                                                        ? Colors.white
                                                        : Colors.black),
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
                      ), // Close Padding
                      ],
                    ),
                  ),
                ],
              ),
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
    if (progress >= 0.99) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final fullW = size.width;
    final fillW = fullW * progress;
    final inset = originInsetPx.clamp(0.0, fullW * 0.45);
    final leftBase = originRight ? (fullW - inset - fillW) : inset;

    final path = Path();
    path.moveTo(fullW + waveAmplitude, 0);

    final int steps = 40;
    for (int i = 0; i <= steps; i++) {
      final y = (i / steps) * size.height;
      final ny = y / size.height;
      final wave = sin(phase + ny * waveCount * 2 * pi);
      final amp = waveAmplitude * (1 - progress);
      final dx = amp * wave;
      final x = originRight
          ? (leftBase + dx)
          : (leftBase + (progress * fullW) - dx);
      path.lineTo(x, y);
    }

    path.lineTo(fullW + waveAmplitude, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}