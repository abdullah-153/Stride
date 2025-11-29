import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/animations.dart';
import '../../utils/wave_painter.dart';

class WorkoutCard extends StatefulWidget {
  final String time;
  final String title;
  final int points;
  final int kcal;
  final bool isDarkMode;
  final bool isPlaying;
  final bool isCompleted;
  final String heroTag;
  final VoidCallback? onPressed;

  const WorkoutCard({
    super.key,
    required this.time,
    required this.title,
    required this.points,
    required this.kcal,
    this.isDarkMode = false,
    this.isPlaying = false,
    this.isCompleted = false,
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
    if (oldWidget.isCompleted != widget.isCompleted) {
      if (widget.isCompleted) {
        _rotateCtrl.forward(from: 0.0);
        _fillCtrl.forward();
      } else {
        _rotateCtrl.reverse();
        _fillCtrl.reverse();
      }
    } else if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _fillCtrl.forward();
      } else {
        _fillCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _fillCtrl.dispose();
    _waveCtrl.dispose();
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

    final activeText = dark ? Colors.black : Colors.white;
    final activeSubText = dark ? Colors.black54 : Colors.white70;
    final activeBorder = const Color.fromRGBO(206, 242, 75, 0.3);
    final waveColor = dark
        ? const Color.fromRGBO(206, 235, 75, 0.8)
        : Colors.black87;

    final cardWidth = width * 0.42;
    final cardHeight = width * 0.58;

    return AnimatedBuilder(
      animation: Listenable.merge([_fillCtrl, _rotateCtrl]),
      builder: (context, _) {
        final t = _fillCtrl.value.clamp(0.0, 1.0);

        final textColor = Color.lerp(idleText, activeText, t)!;
        final subTextColor = Color.lerp(idleSubText, activeSubText, t)!;

        final borderColor = widget.isCompleted
            ? Colors.transparent
            : Color.lerp(idleBorder, activeBorder, t)!;
        final borderWidth = 1.0 + (t * 3.0);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: idleBg,
            borderRadius: BorderRadius.circular(width * 0.08),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              if (t > 0.5)
                const BoxShadow(
                  color: Color.fromRGBO(206, 242, 75, 0.6),
                  blurRadius: 9,
                  spreadRadius: 1,
                )
              else
                BoxShadow(
                  color: idleShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.06),
            child: Stack(
              children: [
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
                                  final accent = const Color.fromRGBO(
                                    206,
                                    242,
                                    75,
                                    1,
                                  );
                                  final circleBg = widget.isCompleted
                                      ? Colors.grey.shade800
                                      : widget.isPlaying
                                      ? dark
                                            ? Colors.white
                                            : accent
                                      : (dark
                                            ? const Color(0xFF121212)
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
                                      ? Colors.grey.shade500
                                      : (widget.isPlaying
                                            ? Colors.black
                                            : (dark
                                                  ? Colors.white
                                                  : Colors.black));

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
                                "${widget.points} pts  •  ~${widget.kcal} kcal",
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
          ),
        );
      },
    );
  }
}
