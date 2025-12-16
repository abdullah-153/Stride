import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/workout_model.dart';
import 'workout_card.dart';

class InteractiveWorkoutCard extends StatefulWidget {
  final Workout workout;
  final int index;
  final bool isPlaying;
  final bool isCompleted;
  final bool isPaused;
  final bool isDarkMode;
  final VoidCallback onPressed;
  final VoidCallback onDelete;

  const InteractiveWorkoutCard({
    super.key,
    required this.workout,
    required this.index,
    required this.isPlaying,
    required this.isCompleted,
    this.isPaused = false,
    required this.isDarkMode,
    required this.onPressed,
    required this.onDelete,
  });

  @override
  State<InteractiveWorkoutCard> createState() => _InteractiveWorkoutCardState();
}

class _InteractiveWorkoutCardState extends State<InteractiveWorkoutCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _blastController;
  late AnimationController _exitController;

  Offset _touchPosition = Offset.zero;
  bool _isHolding = false;
  bool _showDeleteOption = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _startBlast();
      }
    });

    _blastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _blastController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showDeleteOption = true;
          _isHolding = false; // Stop holding logic
        });
      }
    });

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Start fully visible
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _blastController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_showDeleteOption) return; // Don't restart if already in delete mode

    setState(() {
      _isHolding = true;
      _touchPosition = details.localPosition;
    });
    _pulseController.forward(from: 0.0);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_showDeleteOption) return; // Ignore if delete mode is active

    _isHolding = false;
    _pulseController.reverse();
  }

  void _onLongPressCancel() {
    if (_showDeleteOption) return;

    _isHolding = false;
    _pulseController.reverse();
  }

  void _startBlast() {
    _blastController.forward(from: 0.0);
  }

  void _cancelDeleteMode() {
    setState(() {
      _showDeleteOption = false;
      _isHolding = false;
    });
    _blastController.reverse();
    _pulseController.reset();
  }

  void _confirmDelete() async {
    await _exitController.reverse();
    widget.onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(screenWidth * 0.08);
    final cardMargin = const EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    return SizeTransition(
      sizeFactor: _exitController,
      axis: Axis.horizontal,
      axisAlignment: -1.0, // Shrink towards the left
      child: GestureDetector(
        onTap: _showDeleteOption ? _cancelDeleteMode : null,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onLongPressCancel: _onLongPressCancel,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            WorkoutCard(
              time: "${widget.workout.durationMinutes}",
              title: widget.workout.title,
              points: widget.workout.points,
              metricValue: widget.workout.caloriesBurned.toString(),
              metricLabel: "kcal",
              isPlaying: widget.isPlaying,
              isCompleted: widget.isCompleted,
              isPaused: widget.isPaused,
              isDarkMode: widget.isDarkMode,
              heroTag: 'workout_${widget.workout.id}_${widget.index}',
              onPressed: _showDeleteOption ? null : widget.onPressed,
            ),

            Positioned.fill(
              child: Padding(
                padding: cardMargin,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    children: [
                      if (_isHolding && !_showDeleteOption)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final localTouchPosition =
                                  _touchPosition -
                                  Offset(
                                    cardMargin.horizontal / 2,
                                    cardMargin.vertical / 2,
                                  );
                              return CustomPaint(
                                painter: GrowingPulsePainter(
                                  progress: _pulseController.value,
                                  color: Colors.red,
                                  center: localTouchPosition,
                                ),
                              );
                            },
                          ),
                        ),

                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _blastController,
                          builder: (context, child) {
                            if (_blastController.value == 0 &&
                                !_showDeleteOption) {
                              return const SizedBox();
                            }
                            final localTouchPosition =
                                _touchPosition -
                                Offset(
                                  cardMargin.horizontal / 2,
                                  cardMargin.vertical / 2,
                                );
                            return CustomPaint(
                              painter: BlastFillPainter(
                                progress: _blastController.value,
                                color: Colors.red,
                                center: localTouchPosition,
                              ),
                            );
                          },
                        ),
                      ),

                      if (_showDeleteOption)
                        Positioned.fill(
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: _confirmDelete,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
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
      ),
    );
  }
}

class GrowingPulsePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Offset center;

  GrowingPulsePainter({
    required this.progress,
    required this.color,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill; // Changed to fill

    final maxBaseRadius = 60.0;
    final currentBaseRadius = 20.0 + (maxBaseRadius - 20.0) * progress;

    paint.color = color.withOpacity(0.3 * progress);
    canvas.drawCircle(center, currentBaseRadius, paint);

    final pulseCount = 3;
    for (int i = 0; i < pulseCount; i++) {
      final pulseStart = i / pulseCount;
      if (progress > pulseStart) {
        final pulseProgress = (progress - pulseStart) / (1.0 - pulseStart);
        final pulseRadius = currentBaseRadius + (40.0 * pulseProgress);
        final pulseOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0);

        paint.color = color.withOpacity(
          0.4 * pulseOpacity,
        ); // Lower opacity for filled pulses
        canvas.drawCircle(center, pulseRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GrowingPulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.center != center;
  }
}

class BlastFillPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Offset center;

  BlastFillPainter({
    required this.progress,
    required this.color,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.9 * progress);

    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];

    double maxDist = 0;
    for (final corner in corners) {
      final dist = (corner - center).distance;
      if (dist > maxDist) maxDist = dist;
    }

    final currentRadius = maxDist * progress;
    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(BlastFillPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.center != center;
  }
}
