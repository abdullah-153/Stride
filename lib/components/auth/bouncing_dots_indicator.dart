import 'package:flutter/material.dart';

class BouncingDotsIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const BouncingDotsIndicator({
    super.key,
    this.color = Colors.black,
    this.size = 10.0,
  });

  @override
  State<BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<BouncingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final double delay = index * 0.2;
            final double value = _controller.value;
            double yOffset = 0.0;

            double t = (value - delay) % 1.0;
            if (t < 0) t += 1.0;

            if (t < 0.5) {
              yOffset =
                  -10.0 *
                  (1.0 - (2 * (0.25 - (t - 0.25).abs())).abs()); // Bounce up
            }

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size / 4),
              width: widget.size,
              height: widget.size,
              transform: Matrix4.translationValues(0, yOffset, 0),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
