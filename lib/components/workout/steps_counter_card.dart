import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';

class StepCounterCard extends StatefulWidget {
  final int steps;
  final int maxSteps;
  final double distanceKm;
  final bool isDarkMode;

  const StepCounterCard({
    super.key,
    required this.steps,
    required this.maxSteps,
    required this.distanceKm,
    this.isDarkMode = false,
  });

  @override
  State<StepCounterCard> createState() => _StepCounterCardState();
}

class _StepCounterCardState extends State<StepCounterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Slow, continuous rotation
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final accentColor = const Color(0xFFCEF24B); // Lime accent
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white54 : Colors.black54;

    final double progress = (widget.steps / widget.maxSteps).clamp(0.0, 1.0);

    return Container(
      width: SizeConfig.w(300),
      height: SizeConfig.h(300),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: CustomPaint(
                  size: Size(SizeConfig.w(280), SizeConfig.h(280)),
                  painter: _DashedRingPainter(
                    color: isDark
                        ? Colors.white.withOpacity(0.03)
                        : Colors.black.withOpacity(0.03),
                    strokeWidth: 15,
                    dashWidth: 4,
                    dashSpace: 8,
                  ),
                ),
              );
            },
          ),

          CustomPaint(
            size: Size(SizeConfig.w(240), SizeConfig.h(240)),
            painter: _SleekProgressPainter(
              progress: progress,
              trackColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.08),
              progressColor: accentColor,
              strokeWidth: 8,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_walk_rounded,
                color: accentColor,
                size: SizeConfig.w(28),
              ),
              SizedBox(height: SizeConfig.h(4)),

              Text(
                '${widget.steps}',
                style: TextStyle(
                  fontSize: SizeConfig.sp(48),
                  fontWeight: FontWeight.w300, // Thinner, more modern
                  color: textColor,
                  letterSpacing: -1.0,
                  height: 1.0,
                ),
              ),
              Text(
                'STEPS',
                style: TextStyle(
                  fontSize: SizeConfig.sp(10),
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                  letterSpacing: 2.0,
                ),
              ),

              SizedBox(height: SizeConfig.h(16)),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(16),
                  vertical: SizeConfig.h(8),
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(SizeConfig.w(30)),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatItem(
                        value: widget.distanceKm.toStringAsFixed(1),
                        unit: 'km',
                        color: textColor,
                        subColor: subTextColor,
                      ),
                      VerticalDivider(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 20,
                        thickness: 1,
                      ),
                      _buildStatItem(
                        value: (widget.steps * 0.04)
                            .toInt()
                            .toString(), // Improved Calorie Estimate
                        unit: 'kcal',
                        color: textColor,
                        subColor: subTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String unit,
    required Color color,
    required Color subColor,
  }) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.sp(14),
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(width: SizeConfig.w(2)),
        Text(
          unit,
          style: TextStyle(
            fontSize: SizeConfig.sp(10),
            color: subColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SleekProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _SleekProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SleekProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Thin lines for the ring

    double startAngle = 0;
    final circumference = 2 * pi * radius;
    final dashAngle = (dashWidth / circumference) * 2 * pi;
    final spaceAngle = (dashSpace / circumference) * 2 * pi;

    while (startAngle < 2 * pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) => false;
}
