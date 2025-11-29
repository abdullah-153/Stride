// lib/components/weeklyprogresssection.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'package:intl/intl.dart';

class WeeklyPointsCard extends StatelessWidget {
  final List<double> weekData;
  final int totalPoints;
  final double percentChange;

  const WeeklyPointsCard({
    super.key,
    required this.weekData,
    required this.totalPoints,
    required this.percentChange,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isUp = percentChange >= 0;
    final arrow = isUp ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isUp ? Colors.green : Colors.red;

    return Container(
      // let parent control width; use full width available
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(4),
        vertical: SizeConfig.h(6),
      ),
      padding: EdgeInsets.all(SizeConfig.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.w(22)),
        border: Border.all(color: Colors.grey.shade300, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Points",
                style: TextStyle(
                  fontSize: SizeConfig.sp(14),
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black38,
                size: SizeConfig.w(12),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(4)),
          Row(
            children: [
              Text(
                "$totalPoints",
                style: TextStyle(
                  fontSize: SizeConfig.sp(28),
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: SizeConfig.w(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(8),
                  vertical: SizeConfig.h(3),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeConfig.w(16)),
                ),
                child: Row(
                  children: [
                    Icon(arrow, size: SizeConfig.w(13), color: color),
                    SizedBox(width: SizeConfig.w(3)),
                    Text(
                      "${percentChange.abs().toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: SizeConfig.h(14)),
          WeeklyLineChart(data: weekData),
        ],
      ),
    );
  }
}

// rest of the file (WeeklyLineChart & LinePainter) unchanged
class WeeklyLineChart extends StatefulWidget {
  final List<double> data;
  const WeeklyLineChart({super.key, required this.data});

  @override
  State<WeeklyLineChart> createState() => _WeeklyLineChartState();
}

class _WeeklyLineChartState extends State<WeeklyLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = List.generate(
      7,
      (i) => DateFormat(
        'E',
      ).format(DateTime.now().subtract(Duration(days: now.weekday - (i + 1)))),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Column(
          children: [
            AspectRatio(
              aspectRatio: 2.8,
              child: CustomPaint(
                painter: LinePainter(
                  data: widget.data,
                  progress: controller.value,
                  currentIndex: now.weekday - 1,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.h(2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: weekDays
                  .map(
                    (d) => Text(
                      d.substring(0, 3),
                      style: TextStyle(
                        fontSize: SizeConfig.sp(11),
                        color: Colors.black54,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class LinePainter extends CustomPainter {
  final List<double> data;
  final double progress;
  final int currentIndex;

  LinePainter({
    required this.data,
    required this.progress,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dot = Paint()..color = Colors.black;
    final grid = Paint()
      ..color = Colors.grey.withOpacity(0.08)
      ..strokeWidth = 1;

    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = (maxVal - minVal == 0) ? 1 : maxVal - minVal;
    final stepX = size.width / (data.length - 1);
    final h = size.height * 0.8;

    final points = [
      for (int i = 0; i < data.length; i++)
        Offset(i * stepX, h - ((data[i] - minVal) / range) * h),
    ];

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < currentIndex; i++) {
      final midX = (points[i].dx + points[i + 1].dx) / 2;
      path.cubicTo(
        midX,
        points[i].dy,
        midX,
        points[i + 1].dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    final animated = _getAnimatedPath(path, progress);
    canvas.drawPath(animated, line);

    if (progress == 1) {
      final p = points[currentIndex];
      canvas.drawCircle(p, 4.5, dot);
      final glow = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8;
      canvas.drawCircle(p, 4.5, glow);
    }
  }

  Path _getAnimatedPath(Path path, double progress) {
    final animated = Path();
    for (final m in path.computeMetrics()) {
      animated.addPath(m.extractPath(0, m.length * progress), Offset.zero);
    }
    return animated;
  }

  @override
  bool shouldRepaint(covariant LinePainter old) => old.progress != progress;
}
