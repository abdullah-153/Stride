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
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _progress = Tween<double>(
      begin: 0,
      end: widget.steps / widget.maxSteps,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDarkMode;

    final centerTextColor = dark ? Colors.white : Colors.black87;
    final centerSubTextColor = dark ? Colors.white70 : Colors.black54;

    return AnimatedBuilder(
      animation: _progress,
      builder: (context, _) {
        return SizedBox(
          width: SizeConfig.w(260),
          height: SizeConfig.h(260),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(SizeConfig.w(260), SizeConfig.h(260)),
                painter: StepCounterPainter(
                  progress: _progress.value,
                  distanceKm: widget.distanceKm,
                  isDarkMode: dark,
                ),
              ),

              // Step text in center
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.steps}',
                    style: TextStyle(
                      color: centerTextColor,
                      fontSize: SizeConfig.h(38),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(4)),
                  Text(
                    'steps',
                    style: TextStyle(
                      color: centerSubTextColor,
                      fontSize: SizeConfig.h(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class StepCounterPainter extends CustomPainter {
  final double progress; // between 0 and 1
  final double distanceKm;
  final bool isDarkMode;
  final Color accent = const Color.fromRGBO(206, 242, 75, 1);

  StepCounterPainter({
    required this.progress,
    required this.distanceKm,
    this.isDarkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool dark = isDarkMode;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38; // bigger inner circle

    final fillPaint = Paint()
      ..color = dark ? Colors.black87 : Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = accent
      ..strokeWidth = SizeConfig.w(4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);

    final arcPaint = Paint()
      ..color = dark ? Colors.white24 : Colors.black54
      ..strokeWidth = SizeConfig.w(2.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final outerRadius = radius + SizeConfig.w(14);
    final rect = Rect.fromCircle(center: center, radius: outerRadius);
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    if (progress > 0) {
      final endAngle = startAngle + sweepAngle;
      final tipX = center.dx + outerRadius * cos(endAngle);
      final tipY = center.dy + outerRadius * sin(endAngle);

      final squareSize = SizeConfig.w(55);
      final squareRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(tipX, tipY),
          width: squareSize,
          height: squareSize,
        ),
        Radius.circular(SizeConfig.w(10)),
      );

      final borderPaintSquare = Paint()
        ..color = accent
        ..style = PaintingStyle.fill;

      canvas.drawRRect(squareRect, borderPaintSquare);

      final valueColor = dark ? Colors.black87 : Colors.black87;
      final kmColor = dark
          ? Colors.black87.withOpacity(0.8)
          : Colors.black87.withOpacity(0.8);

      final tpValue = TextPainter(
        text: TextSpan(
          text: distanceKm.toStringAsFixed(1),
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.h(22),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tpKm = TextPainter(
        text: TextSpan(
          text: 'km',
          style: TextStyle(color: kmColor, fontSize: SizeConfig.h(10)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final totalHeight = tpValue.height + tpKm.height + SizeConfig.h(2);

      tpValue.paint(
        canvas,
        Offset(tipX - tpValue.width / 2, tipY - totalHeight / 2),
      );
      tpKm.paint(
        canvas,
        Offset(
          tipX - tpKm.width / 2,
          tipY - totalHeight / 2 + tpValue.height + SizeConfig.h(0),
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StepCounterPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.distanceKm != distanceKm ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
