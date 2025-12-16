import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class ActivityStatsCard extends StatefulWidget {
  final bool isDarkMode;
  final int weeklyWorkouts;
  final int weeklyMeals;
  final int weeklyCaloriesBurned;
  final int monthlyWorkouts;
  final int monthlyMeals;
  final int monthlyCaloriesBurned;
  final int totalWorkouts;
  final int totalMeals;
  final int totalXP;

  const ActivityStatsCard({
    super.key,
    required this.isDarkMode,
    required this.weeklyWorkouts,
    required this.weeklyMeals,
    required this.weeklyCaloriesBurned,
    required this.monthlyWorkouts,
    required this.monthlyMeals,
    required this.monthlyCaloriesBurned,
    required this.totalWorkouts,
    required this.totalMeals,
    required this.totalXP,
  });

  @override
  State<ActivityStatsCard> createState() => _ActivityStatsCardState();
}

class _ActivityStatsCardState extends State<ActivityStatsCard> {
  bool _weeklyExpanded = true;
  bool _monthlyExpanded = false;
  bool _allTimeExpanded = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final labelColor = widget.isDarkMode ? Colors.white60 : Colors.black54;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(24)),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Stats Section
          _buildSectionHeader(
            'THIS WEEK',
            _weeklyExpanded,
            () => setState(() => _weeklyExpanded = !_weeklyExpanded),
            labelColor,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _weeklyExpanded
                ? Column(
                    children: [
                      SizedBox(height: SizeConfig.h(12)),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              label: 'Workouts',
                              value: widget.weeklyWorkouts.toString(),
                              icon: Icons.fitness_center_rounded,
                              iconColor: const Color(0xFFCEF24B),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Meals',
                              value: widget.weeklyMeals.toString(),
                              icon: Icons.restaurant_menu_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Calories',
                              value: '${(widget.weeklyCaloriesBurned / 1000).toStringAsFixed(1)}k',
                              icon: Icons.local_fire_department,
                              iconColor: Colors.orange,
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: SizeConfig.h(20)),
          Divider(color: borderColor, thickness: 1),
          SizedBox(height: SizeConfig.h(16)),

          // Monthly Stats Section
          _buildSectionHeader(
            'THIS MONTH',
            _monthlyExpanded,
            () => setState(() => _monthlyExpanded = !_monthlyExpanded),
            labelColor,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _monthlyExpanded
                ? Column(
                    children: [
                      SizedBox(height: SizeConfig.h(12)),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              label: 'Workouts',
                              value: widget.monthlyWorkouts.toString(),
                              icon: Icons.fitness_center_rounded,
                              iconColor: const Color(0xFFCEF24B),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Meals',
                              value: widget.monthlyMeals.toString(),
                              icon: Icons.restaurant_menu_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Calories',
                              value: '${(widget.monthlyCaloriesBurned / 1000).toStringAsFixed(1)}k',
                              icon: Icons.local_fire_department,
                              iconColor: Colors.orange,
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: SizeConfig.h(20)),
          Divider(color: borderColor, thickness: 1),
          SizedBox(height: SizeConfig.h(16)),

          // All Time Stats Section
          _buildSectionHeader(
            'ALL TIME',
            _allTimeExpanded,
            () => setState(() => _allTimeExpanded = !_allTimeExpanded),
            labelColor,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _allTimeExpanded
                ? Column(
                    children: [
                      SizedBox(height: SizeConfig.h(12)),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              label: 'Workouts',
                              value: widget.totalWorkouts.toString(),
                              icon: Icons.fitness_center_rounded,
                              iconColor: const Color(0xFFCEF24B),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Meals',
                              value: widget.totalMeals.toString(),
                              icon: Icons.restaurant_menu_rounded,
                              iconColor: const Color(0xFF0EA5E9),
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                            VerticalDivider(color: borderColor, indent: 4, endIndent: 4),
                            _buildStatItem(
                              label: 'Total XP',
                              value: '${(widget.totalXP / 1000).toStringAsFixed(1)}k',
                              icon: Icons.star_rounded,
                              iconColor: Colors.amber,
                              textColor: textColor,
                              labelColor: labelColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isExpanded,
    VoidCallback onTap,
    Color labelColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: SizeConfig.sp(11),
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 1.2,
            ),
          ),
          Icon(
            isExpanded ? Icons.expand_less : Icons.expand_more,
            color: labelColor,
            size: SizeConfig.sp(20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(SizeConfig.w(10)),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(SizeConfig.w(10)),
          ),
          child: Icon(
            icon,
            size: SizeConfig.sp(20),
            color: iconColor,
          ),
        ),
        SizedBox(height: SizeConfig.h(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.sp(20),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        SizedBox(height: SizeConfig.h(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(12),
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
