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
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final start = index * 0.2;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      )..addListener(() {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        double value = _animations[index].value;
        if (value > 5.0) {
          value = 10.0 - value; // This makes it go back down
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          transform: Matrix4.translationValues(0, -value * 2, 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
          width: widget.size,
          height: widget.size,
        );
      }),
    );
  }
}
