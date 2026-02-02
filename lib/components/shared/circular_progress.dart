import 'package:flutter/material.dart';
import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';

class DietCircularProgress extends StatefulWidget {
  final double totalKcal;
  final double consumedKcal;
  final double burnedKcal;
  final bool isDarkMode;
  final double? diameter;

  const DietCircularProgress({
    super.key,
    required this.totalKcal,
    required this.consumedKcal,
    required this.burnedKcal,
    this.isDarkMode = false,
    this.diameter,
  });

  @override
  State<DietCircularProgress> createState() => _DietCircularProgressState();
}

class _DietCircularProgressState extends State<DietCircularProgress> {
  late final ValueNotifier<double> valueNotifier;

  @override
  void initState() {
    super.initState();
    valueNotifier = ValueNotifier(0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double total = widget.totalKcal > 0 ? widget.totalKcal : 1;
      double consumed = widget.consumedKcal >= 0 ? widget.consumedKcal : 0;
      double burned = widget.burnedKcal >= 0 ? widget.burnedKcal : 0;

      double remaining = (total - (consumed + burned)).clamp(0, total);
      valueNotifier.value = remaining;
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.totalKcal > 0 ? widget.totalKcal : 1;
    double consumed = widget.consumedKcal >= 0 ? widget.consumedKcal : 0;
    double burned = widget.burnedKcal >= 0 ? widget.burnedKcal : 0;
    double remaining = (total - (consumed + burned)).clamp(0, total);
    double progress = (consumed + burned).clamp(0, total);

    double diameter = widget.diameter ?? SizeConfig.w(180);
    double stroke = SizeConfig.w(16);

    final bool dark = widget.isDarkMode;
    final Color fgColor = Colors.lightBlue;
    final Color bgColor = dark
        ? Colors.white.withOpacity(0.08)
        : Colors.blue.shade50;
    final Color seekColor = dark ? Colors.black : Colors.white;
    final Color valueTextColor = dark ? Colors.white : Colors.black87;
    final Color labelTextColor = dark ? Colors.white70 : Colors.black54;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DashedCircularProgressBar.aspectRatio(
            aspectRatio: 1.2,
            valueNotifier: valueNotifier,
            progress: progress,
            maxProgress: total,
            startAngle: 0,
            sweepAngle: 360,
            foregroundStrokeWidth: stroke,
            backgroundStrokeWidth: stroke,
            foregroundDashSize: 10,
            backgroundDashSize: 100,
            corners: StrokeCap.round,
            foregroundColor: fgColor,
            backgroundColor: bgColor,
            animation: true,
            animationDuration: const Duration(milliseconds: 800),
            seekSize: SizeConfig.w(8),
            seekColor: seekColor,
            child: Center(
              child: ValueListenableBuilder<double>(
                valueListenable: valueNotifier,
                builder: (_, value, __) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        remaining.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: valueTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Left',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: labelTextColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    valueNotifier.dispose();
    super.dispose();
  }
}
