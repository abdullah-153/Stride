import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class StreakCard extends StatefulWidget {
  final int streakDays;
  final bool isDarkMode;
  final String title;
  final IconData icon;
  final List<Color>? gradientColors; // Custom gradient
  final Color? textColor;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.isDarkMode,
    this.title = 'Current Streak',
    this.icon = Icons.local_fire_department_rounded,
    this.gradientColors,
    this.textColor,
    this.onTap,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getNextMilestone(int current) {
    if (current < 7) return 7;
    if (current < 14) return 14;
    if (current < 30) return 30;
    if (current < 60) return 60;
    if (current < 100) return 100;
    return ((current ~/ 100) + 1) * 100;
  }

  @override
  Widget build(BuildContext context) {
    // Default gradients if none provided
    final defaultGradient = widget.isDarkMode
        ? [const Color(0xFFFF512F), const Color(0xFFDD2476)]
        : [const Color(0xFFFF512F), const Color(0xFFDD2476)];

    final colors = widget.gradientColors ?? defaultGradient;
    final milestone = _getNextMilestone(widget.streakDays);
    final progress = widget.streakDays / milestone;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: SizeConfig.h(110), // Slightly taller for milestone info
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern (Subtle Circles)
            Positioned(
              right: -SizeConfig.w(20),
              top: -SizeConfig.h(20),
              child: Container(
                width: SizeConfig.w(100),
                height: SizeConfig.w(100),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -SizeConfig.h(30),
              left: SizeConfig.w(40),
              child: Container(
                width: SizeConfig.w(80),
                height: SizeConfig.w(80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Shimmer Effect
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: 1.5,
                  child: Transform.translate(
                    offset: Offset(
                      (2 * SizeConfig.screenWidth * _controller.value) -
                          SizeConfig.screenWidth,
                      0,
                    ),
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: Container(
                        width: SizeConfig.w(50),
                        height: SizeConfig.h(200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.2),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(20)),
              child: Row(
                children: [
                  // Icon with Glow
                  Container(
                    padding: EdgeInsets.all(SizeConfig.w(10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: SizeConfig.w(32),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(16)),

                  // Text Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.streakDays}',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(32),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            SizedBox(width: SizeConfig.w(4)),
                            Text(
                              'Day Streak',
                              style: TextStyle(
                                fontSize: SizeConfig.sp(16),
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.h(8)),
                        
                        // Milestone Progress
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Next Milestone: $milestone Days',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(11),
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(11),
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: SizeConfig.h(4)),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.black.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: SizeConfig.h(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
