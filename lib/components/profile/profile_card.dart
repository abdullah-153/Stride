import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zo_animated_border/zo_animated_border.dart';
import '../../utils/size_config.dart';

class ProfileSetupCard extends StatelessWidget {
  final String name;
  final double progress;

  const ProfileSetupCard({
    super.key,
    required this.name,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final percent = (progress * 100).toInt();

    return Column(
      children: [
        ZoAnimatedGradientBorder(
          borderRadius: SizeConfig.w(140) / 2,
          borderThickness: 4,
          glowOpacity: 0.25,
          gradientColor: [Colors.orange, Colors.yellow],
          animationDuration: const Duration(seconds: 3),
          animationCurve: Curves.linear,
          child: ClipOval(
            child: Container(
              width: SizeConfig.w(130),
              height: SizeConfig.w(130),
              color: Colors.white,
              child: Image.asset(
                "lib/assets/images/profile_placeholder.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(height: SizeConfig.h(10)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
          child: Transform.translate(
            offset: Offset(0, -SizeConfig.h(25)), // slight overlap
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig.w(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(20),
                    vertical: SizeConfig.h(20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(SizeConfig.w(24)),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: SizeConfig.w(1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: SizeConfig.w(8),
                        offset: Offset(0, SizeConfig.h(4)),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Name Row ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: SizeConfig.h(22),
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                                letterSpacing: 0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: SizeConfig.w(42),
                            height: SizeConfig.w(42),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: SizeConfig.w(6),
                                  offset: Offset(0, SizeConfig.h(3)),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.black,
                              size: SizeConfig.w(22),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: SizeConfig.h(14)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Newbie Badge',
                            style: TextStyle(
                              fontSize: SizeConfig.h(13),
                              fontWeight: FontWeight.w300,
                              color: Colors.black54,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            "$percent%",
                            style: TextStyle(
                              fontSize: SizeConfig.h(18),
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: SizeConfig.h(2)),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth * progress;
                          return Stack(
                            children: [
                              Container(
                                height: SizeConfig.h(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.w(12),
                                  ),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: SizeConfig.h(8),
                                width: barWidth,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(
                                    SizeConfig.w(12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
