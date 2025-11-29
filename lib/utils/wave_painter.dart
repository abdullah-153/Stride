import 'dart:math';
import 'package:flutter/material.dart';

/// Reusable wave fill painter for animated backgrounds
/// Extracted from WorkoutCard for use across multiple components
class WaveFillPainter extends CustomPainter {
  final double progress; // 0..1
  final double phase; // radians for animation
  final Color color;
  final double borderRadius;
  final double waveAmplitude;
  final int waveCount;
  final WaveDirection direction;

  WaveFillPainter({
    required this.progress,
    required this.phase,
    required this.color,
    this.borderRadius = 0,
    this.waveAmplitude = 12.0,
    this.waveCount = 2,
    this.direction = WaveDirection.topToBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.01) return;

    final paint = Paint()..color = color;

    if (progress >= 0.99) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final path = Path();

    switch (direction) {
      case WaveDirection.topToBottom:
        _paintTopToBottom(path, size);
        break;
      case WaveDirection.bottomToTop:
        _paintBottomToTop(path, size);
        break;
      case WaveDirection.leftToRight:
        _paintLeftToRight(path, size);
        break;
      case WaveDirection.rightToLeft:
        _paintRightToLeft(path, size);
        break;
    }

    // Clip to border radius if specified
    if (borderRadius > 0) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      );
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawPath(path, paint);
      canvas.restore();
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _paintTopToBottom(Path path, Size size) {
    final fullH = size.height;
    final fillH = fullH * progress;
    final currentY = fillH;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Wave line from right to left at y = currentY
    for (int i = 0; i <= 40; i++) {
      final x = size.width - (i / 40) * size.width;
      final nx = i / 40;
      final wave = sin(phase + nx * waveCount * 2 * pi);
      final amp = waveAmplitude * (1 - progress);
      final y = currentY + amp * wave;
      path.lineTo(x, y);
    }

    path.close();
  }

  void _paintBottomToTop(Path path, Size size) {
    final fullH = size.height;
    final fillH = fullH * progress;
    final currentY = fullH - fillH;

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Wave line from right to left at y = currentY
    for (int i = 0; i <= 40; i++) {
      final x = size.width - (i / 40) * size.width;
      final nx = i / 40;
      final wave = sin(phase + nx * waveCount * 2 * pi);
      final amp = waveAmplitude * (1 - progress);
      final y = currentY + amp * wave;
      path.lineTo(x, y);
    }

    path.close();
  }

  void _paintLeftToRight(Path path, Size size) {
    final fullW = size.width;
    final fillW = fullW * progress;
    final currentX = fillW;

    path.moveTo(0, 0);
    path.lineTo(0, size.height);

    // Wave line from bottom to top at x = currentX
    for (int i = 0; i <= 40; i++) {
      final y = size.height - (i / 40) * size.height;
      final ny = i / 40;
      final wave = sin(phase + ny * waveCount * 2 * pi);
      final amp = waveAmplitude * (1 - progress);
      final x = currentX + amp * wave;
      path.lineTo(x, y);
    }

    path.close();
  }

  void _paintRightToLeft(Path path, Size size) {
    final fullW = size.width;
    final fillW = fullW * progress;
    final currentX = fullW - fillW;

    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);

    // Wave line from bottom to top at x = currentX
    for (int i = 0; i <= 40; i++) {
      final y = size.height - (i / 40) * size.height;
      final ny = i / 40;
      final wave = sin(phase + ny * waveCount * 2 * pi);
      final amp = waveAmplitude * (1 - progress);
      final x = currentX + amp * wave;
      path.lineTo(x, y);
    }

    path.close();
  }

  @override
  bool shouldRepaint(covariant WaveFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}

enum WaveDirection { topToBottom, bottomToTop, leftToRight, rightToLeft }
