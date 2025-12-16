import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/animations.dart';
import '../../utils/wave_painter.dart';

class WorkoutCard extends StatefulWidget {
  final String time;
  final String title;
  final int points;
  final String metricValue; // Was kcal, now generic value
  final String metricLabel; // e.g. "kcal", "reps", "mins"
  final bool isDarkMode;
  final bool isPlaying;
  final bool isCompleted;
  final bool isPaused; // New property
  final String heroTag;
  final VoidCallback? onPressed;

  const WorkoutCard({
    super.key,
    required this.time,
    required this.title,
    required this.points,
    required this.metricValue,
    this.metricLabel = "kcal",
    this.isDarkMode = false,
    this.isPlaying = false,
    this.isCompleted = false,
    this.isPaused = false,
    this.heroTag = '',
    this.onPressed,
  });

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl = AnimationController(
    vsync: this,
    duration: kAnimMedium,
  );

  late final AnimationController _fillCtrl;
  late final AnimationController _waveCtrl;
  late final AnimationController _pulseCtrl; // New controller for paused state

  @override
  void initState() {
    super.initState();
    _fillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isCompleted) {
      _rotateCtrl.value = 1.0;
      _fillCtrl.value = 1.0;
    } else if (widget.isPlaying) {
      _fillCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPaused && !oldWidget.isPaused) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }

    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _rotateCtrl.forward(from: 0.0);
        _fillCtrl.forward();
      } else {
        _rotateCtrl.reverse();
        if (widget.isPlaying) {
          _fillCtrl.forward();
        } else {
          _fillCtrl.reverse();
        }
      }
    } else if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _fillCtrl.forward();
      } else {
        if (!widget.isCompleted) {
          _fillCtrl.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _fillCtrl.dispose();
    _waveCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool dark = widget.isDarkMode;

    final idleBg = dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final idleText = dark ? Colors.white : Colors.black87;
    final idleSubText = dark ? Colors.white70 : Colors.grey.shade700;
    final idleBorder = dark ? Colors.white12 : Colors.grey.shade300;
    final idleShadow = dark
        ? const Color.fromRGBO(0, 0, 0, 0.7)
        : const Color.fromRGBO(0, 0, 0, 0.05);

    final completedBg = dark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFF2C2C2E);

    final completedText = Colors.white; // Clean white text
    final completedBorder = Colors.transparent;
    final completedShadow = Colors.black.withOpacity(0.2);

    final idleTitle = dark ? Colors.white : Colors.black87;
    final playTitle = Colors.black;

    final idleSubtitle = dark ? Colors.white70 : Colors.grey.shade700;
    final playSubtitle = Colors.black87;

    final waveColor = const Color(0xFFCEF24B);
    final waveOpacity = 1.0;

    final cardWidth = width * 0.42;
    final cardHeight = width * 0.58;

    return AnimatedBuilder(
      animation: Listenable.merge([_fillCtrl, _waveCtrl, _pulseCtrl]),
      builder: (context, _) {
        final t = _fillCtrl.value.clamp(0.0, 1.0);
        final phase = _waveCtrl.value * 2 * pi;

        final bgColor = widget.isCompleted ? completedBg : idleBg;

        Color textColor;
        Color subTextColor;

        if (widget.isCompleted) {
          textColor = completedText;
          subTextColor = completedText.withOpacity(0.7);
        } else {
          textColor = Color.lerp(idleTitle, playTitle, t)!;
          subTextColor = Color.lerp(idleSubtitle, playSubtitle, t)!;
        }

        final idleBorder = dark ? Colors.white12 : Colors.grey.shade300;
        final activeBorder = const Color(0xFFB5D93B);
        final pausedBorderColor = const Color(0xFFCEF24B); // Lime

        Color borderColor;
        double borderWidth;

        if (widget.isCompleted) {
          borderColor = completedBorder;
          borderWidth = 1.5;
        } else if (widget.isPaused) {
          final pulse = _pulseCtrl.value; // 0..1..0
          borderColor = pausedBorderColor.withOpacity(0.4 + (0.6 * pulse));
          borderWidth = 1.0 + (pulse * 2.5); // 1.0 to 3.5
        } else {
          borderColor = Color.lerp(idleBorder, activeBorder, t)!;
          borderWidth = 1.0 + (t * 1.5);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          width: cardWidth,
          height: cardHeight, // Fixed height for consistency
          decoration: BoxDecoration(
            color: bgColor, // Static background (unless completed)
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: widget.isCompleted
                    ? completedShadow
                    : (dark ? Colors.black26 : Colors.black12),
                blurRadius: widget.isCompleted ? 8 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias, // Clip the wave
          child: Stack(
            children: [
              if (!widget.isCompleted && t > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: WaveFillPainter(
                      progress: t,
                      phase: _waveCtrl.value * 2 * pi,
                      color: waveColor,
                      borderRadius: 0,
                      waveAmplitude: 10,
                      waveCount: 2,
                      direction: WaveDirection.topToBottom,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width * 0.04,
                  width * 0.045,
                  width * 0.04,
                  width * 0.05,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fontScale = constraints.maxWidth / 160;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.time,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 52 * fontScale,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2 * fontScale),
                                  Text(
                                    "Minutes",
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 20 * fontScale,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: _rotateCtrl,
                              builder: (context, child) {

                                final circleBg = widget.isCompleted
                                    ? (dark
                                          ? Colors.yellow.withOpacity(0.1)
                                          : Colors.white)
                                    : widget.isPlaying
                                    ? Colors
                                          .black // Black button on Lime
                                    : (dark
                                          ? const Color(0xFF2C2C2E)
                                          : Colors.white);

                                final circleBorder =
                                    (!widget.isPlaying && !widget.isCompleted)
                                    ? Border.all(
                                        color: dark
                                            ? Colors.white12
                                            : Colors.grey.shade300,
                                        width: 1,
                                      )
                                    : null;

                                final iconColor = widget.isCompleted
                                    ? (dark
                                          ? const Color(0xFFCEF24B)
                                          : const Color(0xFF5A701E))
                                    : widget.isPlaying
                                    ? const Color(
                                        0xFFCEF24B,
                                      ) // Lime icon on Black
                                    : (dark ? Colors.white : Colors.black);

                                return Transform.rotate(
                                  angle: _rotateCtrl.value * pi,
                                  child: Hero(
                                    tag: widget.heroTag,
                                    child: Container(
                                      width: constraints.maxWidth * 0.35,
                                      height: constraints.maxWidth * 0.35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: circleBg,
                                        border: circleBorder,
                                        boxShadow: widget.isPlaying
                                            ? [
                                                const BoxShadow(
                                                  color: Color.fromRGBO(
                                                    206,
                                                    242,
                                                    75,
                                                    0.5,
                                                  ),
                                                  blurRadius: 15,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: IconButton(
                                        icon: AnimatedSwitcher(
                                          duration: kAnimShort,
                                          transitionBuilder: (child, anim) =>
                                              ScaleTransition(
                                                scale: anim,
                                                child: child,
                                              ),
                                          child: Icon(
                                            widget.isCompleted
                                                ? Icons.restart_alt_rounded
                                                : widget.isPlaying
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            key: ValueKey(
                                              '${widget.isPlaying}_${widget.isCompleted}',
                                            ),
                                            color: iconColor,
                                            size: 32 * fontScale,
                                          ),
                                        ),
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          widget.onPressed?.call();
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20 * fontScale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2 * fontScale),
                            Text(
                              "${widget.points} pts  Ã¢â‚¬Â¢  ~${widget.metricValue} ${widget.metricLabel}",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 16 * fontScale,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
