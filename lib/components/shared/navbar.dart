import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart';
import 'dart:math' as math;

class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<Color> pageColors;
  final bool isDarkMode;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.pageColors,
    required this.isDarkMode,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with TickerProviderStateMixin {
  Color _currentColor = Colors.black;
  final List<GlobalKey> _itemKeys = List.generate(4, (_) => GlobalKey());

  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  OverlayEntry? _rippleOverlay;
  bool _isAnimating = false;
  int? _targetIndex;

  @override
  void initState() {
    super.initState();
    _currentColor = _computeNavbarColor(widget.currentIndex, widget.isDarkMode);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeInOutCubic,
    );
  }

  Color _computeNavbarColor(int index, bool isDarkMode) {
    // Home page special rule:
    if (index == 0) {
      return isDarkMode ? Colors.white : widget.pageColors[0];
    }
    // Other pages use the page color
    return widget.pageColors[index];
  }

  Color _computeAccentColor(int index, bool isDarkMode) {
    // Accent = selected tile background color
    if (index == 0) {
      // Home page accent: black in dark mode, white in light mode
      return isDarkMode ? Colors.black : Colors.white;
    }
    // Other pages: black in light mode, white in dark mode
    return isDarkMode ? Colors.white : Colors.black;
  }

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync color when currentIndex or theme changes externally (e.g., back navigation, theme toggle)
    if ((oldWidget.currentIndex != widget.currentIndex ||
            oldWidget.isDarkMode != widget.isDarkMode) &&
        !_isAnimating) {
      setState(() {
        _currentColor = _computeNavbarColor(
          widget.currentIndex,
          widget.isDarkMode,
        );
      });
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _rippleOverlay?.remove();
    super.dispose();
  }

  Future<void> _triggerRipple(int index) async {
    if (index == widget.currentIndex || _isAnimating) return;

    setState(() {
      _isAnimating = true;
      _targetIndex = index;
    });

    final key = _itemKeys[index];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // Safety fallback: directly change without ripple
      final target = _computeNavbarColor(index, widget.isDarkMode);
      setState(() => _currentColor = target);
      widget.onTap(index);
      setState(() {
        _isAnimating = false;
        _targetIndex = null;
      });
      return;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final origin = Offset(
      offset.dx + size.width / 2,
      offset.dy + size.height / 2,
    );
    final targetColor = _computeNavbarColor(index, widget.isDarkMode);

    final screenSize = MediaQuery.of(context).size;
    final maxRadius = math.sqrt(
      math.pow(screenSize.width, 2) + math.pow(screenSize.height, 2),
    );

    _rippleOverlay = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _rippleAnimation,
        builder: (context, _) {
          return IgnorePointer(
            child: CustomPaint(
              painter: _FullScreenRipplePainter(
                origin: origin,
                radius: maxRadius * _rippleAnimation.value,
                color: targetColor,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_rippleOverlay!);

    // Forward animation
    await _rippleController.forward();

    // Update navbar color and notify parent immediately (prevents flicker)
    if (mounted) {
      setState(() {
        _currentColor = targetColor;
      });
      widget.onTap(index);
    }

    // Small delay so page can settle, then reverse
    await Future.delayed(const Duration(milliseconds: 40));
    await _rippleController.reverse();

    // Cleanup
    _rippleOverlay?.remove();
    _rippleOverlay = null;

    if (mounted) {
      setState(() {
        _isAnimating = false;
        _targetIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Accent color for currently selected index
    final accentColor = _computeAccentColor(
      widget.currentIndex,
      widget.isDarkMode,
    );

    // Colors for icons: selected icon contrasts with accent; unselected contrast with navbar background
    final selectedIconColor = accentColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final unselectedIconColor = _currentColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: SizeConfig.w(20),
          right: SizeConfig.w(20),
          bottom: SizeConfig.h(18),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.w(5),
            vertical: SizeConfig.h(8),
          ),
          decoration: BoxDecoration(
            color: _currentColor,
            borderRadius: BorderRadius.circular(SizeConfig.w(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.pageColors.length, (index) {
              final selected = widget.currentIndex == index;
              final icons = [
                Icons.home_rounded,
                Icons.restaurant_menu_rounded,
                Icons.fitness_center_rounded,
                Icons.person_rounded,
              ];
              final labels = ['Home', 'Diet', 'Workout', 'Profile'];

              final itemAccent = _computeAccentColor(index, widget.isDarkMode);
              final itemIconColor = selected
                  ? (itemAccent.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : unselectedIconColor;

              return GestureDetector(
                key: _itemKeys[index],
                onTap: () => _triggerRipple(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: selected ? SizeConfig.w(12) : SizeConfig.w(10),
                    vertical: SizeConfig.h(8),
                  ),
                  decoration: BoxDecoration(
                    color: selected ? itemAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(SizeConfig.w(8)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[index],
                        color: itemIconColor,
                        size: SizeConfig.w(24),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeInOut,
                        child: selected
                            ? Padding(
                                padding: EdgeInsets.only(left: SizeConfig.w(6)),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(14),
                                    fontWeight: FontWeight.w600,
                                    color: itemIconColor,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _FullScreenRipplePainter extends CustomPainter {
  final Offset origin;
  final double radius;
  final Color color;

  _FullScreenRipplePainter({
    required this.origin,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, radius, paint);
  }

  @override
  bool shouldRepaint(_FullScreenRipplePainter oldDelegate) =>
      oldDelegate.radius != radius || oldDelegate.color != color;
}
