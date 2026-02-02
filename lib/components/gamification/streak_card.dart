import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class StreakCard extends StatefulWidget {
  final int streakDays;
  final bool isDarkMode;
  final String title;
  final int currentLevel;
  final int currentXp;
  final int nextLevelXp;
  final List<Color>? gradientColors;
  final Color? textColor;
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.isDarkMode,
    this.title = 'Current Streak',
    this.currentLevel = 1,
    this.currentXp = 0,
    this.nextLevelXp = 100,
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
    final defaultGradient = widget.isDarkMode
        ? [const Color(0xFFFF512F), const Color(0xFFDD2476)]
        : [Colors.white, Colors.white];

    final colors = widget.gradientColors ?? defaultGradient;

    final effectiveTextColor =
        widget.textColor ?? (widget.isDarkMode ? Colors.white : Colors.black);
    final secondaryTextColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.9)
        : Colors.black87;

    final double levelProgress = (widget.currentXp / widget.nextLevelXp).clamp(
      0.0,
      1.0,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: SizeConfig.h(110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: widget.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            widget.isDarkMode
                ? BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  )
                : BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
          child: Stack(
            children: [
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(20)),
                child: Row(
                  children: [
                    SizedBox(
                      width: SizeConfig.w(54),
                      height: SizeConfig.w(54),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: SizeConfig.w(54),
                            height: SizeConfig.w(54),
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.w(54),
                            height: SizeConfig.w(54),
                            child: CircularProgressIndicator(
                              value: levelProgress,
                              strokeWidth: 5,
                              strokeCap: StrokeCap.round,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "LVL",
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(10),
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDarkMode
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black54,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                "${widget.currentLevel}",
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(18),
                                  fontWeight: FontWeight.bold,
                                  color: effectiveTextColor,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: SizeConfig.w(16)),

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
                                  color: effectiveTextColor,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(width: SizeConfig.w(4)),
                              Text(
                                'Day Streak',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(16),
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.h(6)),

                          Row(
                            children: [
                              Text(
                                '${widget.currentXp} / ${widget.nextLevelXp} XP',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(12),
                                  color: secondaryTextColor,
                                ),
                              ),
                              SizedBox(width: SizeConfig.w(8)),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: SizeConfig.w(8)),
                              Text(
                                'to Level ${widget.currentLevel + 1}',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(12),
                                  color: widget.isDarkMode
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black54,
                                  fontWeight: FontWeight.w400,
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
      ),
    );
  }
}
