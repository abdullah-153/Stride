import 'package:flutter/material.dart';

class FluidWaveProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color color;
  final Color backgroundColor;
  final bool isDarkMode;
  final double? borderRadius;

  const FluidWaveProgress({
    super.key,
    required this.value,
    this.height = 12,
    required this.color,
    required this.backgroundColor,
    this.isDarkMode = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? height / 2;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: _FluidWavePainter(
            value: value.clamp(0.0, 1.0),
            color: color,
            isDarkMode: isDarkMode,
          ),
        ),
      ),
    );
  }
}

class _FluidWavePainter extends CustomPainter {
  final double value;
  final Color color;
  final bool isDarkMode;

  _FluidWavePainter({
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0) return;

    final width = size.width;
    final height = size.height;
    final progressWidth = width * value;

    final paint = Paint()..style = PaintingStyle.fill;

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withOpacity(0.85), color],
    );

    final rect = Rect.fromLTWH(0, 0, progressWidth, height);
    paint.shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);

    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    if (progressWidth > height * 2) {
      canvas.drawCircle(
        Offset(progressWidth * 0.7, height * 0.35),
        height * 0.15,
        bubblePaint,
      );

      canvas.drawCircle(
        Offset(progressWidth * 0.5, height * 0.65),
        height * 0.12,
        bubblePaint,
      );

      canvas.drawCircle(
        Offset(progressWidth * 0.85, height * 0.6),
        height * 0.08,
        bubblePaint,
      );

      if (progressWidth > height * 3) {
        canvas.drawCircle(
          Offset(progressWidth * 0.3, height * 0.45),
          height * 0.06,
          bubblePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FluidWavePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.isDarkMode != isDarkMode;
  }
}
