import 'package:flutter/material.dart';
import 'dart:math';
import '../shared/bouncing_dots_indicator.dart';

enum ShapeType { circle, square, triangle, hexagon }

class AnimatedBackground extends StatefulWidget {
  final int stepIndex;
  final bool isLoading;

  const AnimatedBackground({
    super.key,
    this.stepIndex = 0,
    this.isLoading = false,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _physicsController;
  late AnimationController _burstController;

  final List<_Orb> _orbs = [];
  final Random _random = Random();

  ShapeType _currentShape = ShapeType.circle;

  double _shakeIntensity = 0.0;
  double _scaleFactor = 1.0;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _physicsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _physicsController.addListener(_updatePhysics);

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _burstController.addListener(_handleBurstAnimation);

    _initOrbs();
    _updateShapeType();
  }

  void _handleBurstAnimation() {
    final val = _burstController.value;
    setState(() {
      if (val < 0.4) {
        _shakeIntensity = (val / 0.4) * 10.0;
        _scaleFactor = 1.0 + (val / 0.4) * 0.2;
        _opacity = 1.0;
      } else if (val < 0.6) {
        double progress = (val - 0.4) / 0.2;
        _shakeIntensity = 10.0 + progress * 5.0;
        _scaleFactor = 1.2 + progress * 0.5;
        _opacity = 1.0 - progress;

        if (progress > 0.5 && _currentShape != _targetShape()) {
          _updateShapeType();
        }
      } else {
        double progress = (val - 0.6) / 0.4;
        _shakeIntensity = 0.0;
        _opacity = 1.0;
        double elastic =
            pow(2, -10 * progress) *
                sin((progress * 10 - 0.75) * (2 * pi) / 3) +
            1;
        if (progress < 0.1) elastic = progress * 10;
        _scaleFactor = elastic;
      }
    });
  }

  ShapeType _targetShape() {
    switch (widget.stepIndex % 4) {
      case 0:
        return ShapeType.circle;
      case 1:
        return ShapeType.square;
      case 2:
        return ShapeType.triangle;
      case 3:
        return ShapeType.hexagon;
      default:
        return ShapeType.circle;
    }
  }

  void _updatePhysics() {
    for (var orb in _orbs) {
      orb.update(_shakeIntensity);
    }
    for (int i = 0; i < _orbs.length; i++) {
      for (int j = i + 1; j < _orbs.length; j++) {
        _resolveCollision(_orbs[i], _orbs[j]);
      }
    }
  }

  void _resolveCollision(_Orb a, _Orb b) {
    double screenScale = 400.0;
    double rA = a.radius / screenScale;
    double rB = b.radius / screenScale;
    Offset posA = Offset(a.alignment.x, a.alignment.y);
    Offset posB = Offset(b.alignment.x, b.alignment.y);
    double dx = posB.dx - posA.dx;
    double dy = posB.dy - posA.dy;
    double dist = sqrt(dx * dx + dy * dy);

    if (dist < (rA + rB)) {
      double overlap = (rA + rB) - dist;
      if (dist == 0) dist = 0.001;
      double nx = dx / dist;
      double ny = dy / dist;
      a.alignment = Alignment(
        a.alignment.x - nx * overlap * 0.5,
        a.alignment.y - ny * overlap * 0.5,
      );
      b.alignment = Alignment(
        b.alignment.x + nx * overlap * 0.5,
        b.alignment.y + ny * overlap * 0.5,
      );
      Alignment temp = a.velocity;
      a.velocity = b.velocity;
      b.velocity = temp;
    }
  }

  void _initOrbs() {
    _orbs.clear();
    List<Color> vibrantColors = [
      Colors.purpleAccent.shade400,
      Colors.deepPurpleAccent,
      Colors.pinkAccent.shade400,
      Colors.cyanAccent.shade700,
      Colors.amberAccent.shade700, // Gold/Yellow
      Colors.blueAccent.shade700,
      Colors.tealAccent.shade400,
    ];

    for (int i = 0; i < 5; i++) {
      _orbs.add(_generateOrb(vibrantColors));
    }
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stepIndex != oldWidget.stepIndex) {
      setState(() => _currentShape = _targetShape()); // Immediate switch
      _burstController.forward(from: 0.0);
    }
  }

  void _updateShapeType() {
    _currentShape = _targetShape();
  }

  _Orb _generateOrb(List<Color> colors) {
    return _Orb(
      color: colors[_random.nextInt(colors.length)],
      radius: _random.nextDouble() * 80 + 40, // 40-120
      alignment: _randomEdgeAlignment(),
      velocity: Alignment(
        (_random.nextDouble() * 0.006 - 0.003),
        (_random.nextDouble() * 0.006 - 0.003),
      ),
      rotationSpeed: (_random.nextDouble() * 0.02 - 0.01),
    );
  }

  @override
  void dispose() {
    _physicsController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_physicsController, _burstController]),
          builder: (context, child) {
            return CustomPaint(
              painter: _OrbPainter(
                orbs: _orbs,
                shapeType: _currentShape,
                scale: _scaleFactor,
                opacity: _opacity,
              ),
              child: Container(),
            );
          },
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black12,
              child: Center(
                child: BouncingDotsIndicator(color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Alignment _randomEdgeAlignment() {
    double x, y;
    if (_random.nextBool()) {
      x = _random.nextBool()
          ? (_random.nextDouble() * 0.4 + 0.6)
          : -(_random.nextDouble() * 0.4 + 0.6);
      y = _random.nextDouble() * 2.0 - 1.0;
    } else {
      y = _random.nextBool()
          ? (_random.nextDouble() * 0.4 + 0.6)
          : -(_random.nextDouble() * 0.4 + 0.6);
      x = _random.nextDouble() * 2.0 - 1.0;
    }
    return Alignment(x, y);
  }
}

class _Orb {
  Color color;
  double radius;
  Alignment alignment;
  Alignment velocity;
  double rotationSpeed;
  double currentRotation = 0;
  double shakeX = 0;
  double shakeY = 0;

  _Orb({
    required this.color,
    required this.radius,
    required this.alignment,
    required this.velocity,
    required this.rotationSpeed,
  });

  void update(double shakeIntensity) {
    double nextX = alignment.x + velocity.x;
    double nextY = alignment.y + velocity.y;
    if (nextX < -1.1 || nextX > 1.1)
      velocity = Alignment(-velocity.x, velocity.y);
    if (nextY < -1.1 || nextY > 1.1)
      velocity = Alignment(velocity.x, -velocity.y);
    alignment = alignment + velocity;
    currentRotation += rotationSpeed;
    if (shakeIntensity > 0) {
      shakeX = (Random().nextDouble() - 0.5) * shakeIntensity * 0.005;
      shakeY = (Random().nextDouble() - 0.5) * shakeIntensity * 0.005;
    } else {
      shakeX = 0;
      shakeY = 0;
    }
  }
}

class _OrbPainter extends CustomPainter {
  final List<_Orb> orbs;
  final ShapeType shapeType;
  final double scale;
  final double opacity;

  _OrbPainter({
    required this.orbs,
    required this.shapeType,
    required this.scale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF5F7FA),
    );

    if (opacity <= 0.05) return;

    for (var orb in orbs) {
      final center = Offset(
        (orb.alignment.x + orb.shakeX + 1) / 2 * size.width,
        (orb.alignment.y + orb.shakeY + 1) / 2 * size.height,
      );

      final double sRadius = orb.radius * scale;
      if (sRadius <= 0) continue;

      canvas.drawCircle(
        center + const Offset(8, 15),
        sRadius * 0.9,
        Paint()
          ..color = orb.color.withOpacity(0.3 * opacity)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            10,
          ), // Reduced blur
      );

      final shader = RadialGradient(
        colors: [
          orb.color.withOpacity(opacity * 0.9), // Nearly solid center
          orb.color.withOpacity(opacity * 0.6),
          orb.color.withOpacity(0.0), // Fade at very edge
        ],
        stops: const [0.3, 0.75, 1.0], // Larger core
        center: const Alignment(-0.2, -0.2),
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: center, radius: sRadius));

      final paint = Paint()..shader = shader;

      final highlightPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withOpacity(0.9 * opacity),
                Colors.white.withOpacity(0.0),
              ],
              center: Alignment.topLeft,
              radius: 0.8,
            ).createShader(
              Rect.fromCircle(
                center: center - Offset(sRadius * 0.3, sRadius * 0.3),
                radius: sRadius * 0.6,
              ),
            );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(orb.currentRotation);

      switch (shapeType) {
        case ShapeType.circle:
          canvas.drawCircle(Offset.zero, sRadius, paint);
          canvas.drawCircle(
            Offset(-sRadius * 0.3, -sRadius * 0.3),
            sRadius * 0.35,
            highlightPaint,
          );
          break;

        case ShapeType.square:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: sRadius * 1.6,
                height: sRadius * 1.6,
              ),
              Radius.circular(sRadius * 0.4),
            ),
            paint,
          );
          canvas.drawCircle(
            Offset(-sRadius * 0.4, -sRadius * 0.4),
            sRadius * 0.35,
            highlightPaint,
          );
          break;

        case ShapeType.triangle:
          final path = Path();
          double h = sRadius * 1.6;
          path.moveTo(0, -h);
          path.lineTo(h * 0.866, h * 0.5);
          path.lineTo(-h * 0.866, h * 0.5);
          path.close();

          paint.strokeJoin = StrokeJoin.miter;
          paint.strokeWidth = 0;
          paint.style = PaintingStyle.fill;

          canvas.drawPath(path, paint);
          canvas.drawCircle(
            Offset(0, -sRadius * 0.5),
            sRadius * 0.3,
            highlightPaint,
          );
          break;

        case ShapeType.hexagon:
          final path = Path();
          double hSize = sRadius * 1.2;
          for (int i = 0; i < 6; i++) {
            double angle = (pi / 3) * i;
            double x = hSize * cos(angle);
            double y = hSize * sin(angle);
            if (i == 0) {
              path.moveTo(x, y);
            } else {
              path.lineTo(x, y);
            }
          }
          path.close();

          paint.strokeJoin = StrokeJoin.miter;
          paint.strokeWidth = 0;
          paint.style = PaintingStyle.fill;

          canvas.drawPath(path, paint);
          canvas.drawCircle(
            Offset(-sRadius * 0.3, -sRadius * 0.5),
            sRadius * 0.3,
            highlightPaint,
          );
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}
