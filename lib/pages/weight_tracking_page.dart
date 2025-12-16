import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/size_config.dart';
import '../models/weight_entry_model.dart';
import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';
import '../providers/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/body_update_sheet.dart';

class WeightTrackingPage extends ConsumerStatefulWidget {
  const WeightTrackingPage({super.key});

  @override
  ConsumerState<WeightTrackingPage> createState() => _WeightTrackingPageState();
}

class _WeightTrackingPageState extends ConsumerState<WeightTrackingPage> {
  // Mock data - TODO: Replace with actual service
  final List<WeightEntry> _weightHistory = [
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 30)), weight: 75.0),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 25)), weight: 74.5),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 20)), weight: 74.0),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 15)), weight: 73.5),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 10)), weight: 73.0),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 5)), weight: 72.5),
    WeightEntry(date: DateTime.now(), weight: 72.0),
  ];

  void _showUpdateBodyStats() async {
    final currentWeight = ref.read(userWeightProvider);
    final currentHeight = ref.read(userHeightProvider);
    final currentAge = ref.read(userAgeProvider);
    final isDarkMode = ref.read(themeProvider);

    final result = await BodyUpdateSheet.show(
      context,
      currentWeight: currentWeight,
      currentHeight: currentHeight,
      currentAge: currentAge,
      isDarkMode: isDarkMode,
      preferredUnits: ref.read(userProfileProvider).value?.preferredUnits ?? UnitPreference.metric,
    );

    if (result != null && mounted) {
      final double newWeight = result['weight'];
      final double newHeight = result['height'];
      final int newAge = result['age'];

      // Update Profile Providers
      final notifier = ref.read(userProfileProvider.notifier);
      if (newWeight != currentWeight) {
        await notifier.updateWeight(newWeight);
        // Add to history
        setState(() {
          _weightHistory.add(WeightEntry(
            date: DateTime.now(),
            weight: newWeight,
          ));
        });
      }
      if (newHeight != currentHeight) await notifier.updateHeight(newHeight);
      if (newAge != currentAge) await notifier.updateAge(newAge);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Body stats updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isDarkMode = ref.watch(themeProvider);
    final currentWeight = ref.watch(userWeightProvider);
    final currentHeight = ref.watch(userHeightProvider);
    final currentAge = ref.watch(userAgeProvider);
    final goalWeight = 68.0; // TODO: Get from profile

    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);

    final currentBMI = WeightEntry(date: DateTime.now(), weight: currentWeight)
        .calculateBMI(currentHeight);
    final bmiCategory = WeightEntry(date: DateTime.now(), weight: currentWeight)
        .getBMICategory(currentBMI);

    final weightDifference = currentWeight - goalWeight;
    final startWeight = _weightHistory.isNotEmpty ? _weightHistory.first.weight : currentWeight;
    final totalProgress = startWeight - currentWeight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weight Tracking',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(SizeConfig.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Weight Card
            Container(
              padding: EdgeInsets.all(SizeConfig.w(24)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(SizeConfig.w(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                      'Body Stats', // Changed from "Current Weight"
                      style: TextStyle(
                        fontSize: SizeConfig.sp(14),
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                      _buildStatChip(
                        'Goal: ${goalWeight.toStringAsFixed(1)} kg',
                        Icons.flag_rounded,
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.h(12)),
                  
                  // Weight Display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentWeight.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: SizeConfig.sp(42),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: SizeConfig.w(6)),
                      Padding(
                        padding: EdgeInsets.only(bottom: SizeConfig.h(10)),
                        child: Text(
                          'kg',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(18),
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Height & Age Minis
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${currentHeight.round()} cm",
                             style: TextStyle(
                              fontSize: SizeConfig.sp(16),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Height",
                             style: TextStyle(
                              fontSize: SizeConfig.sp(10),
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(8)),
                           Text(
                            "$currentAge years",
                             style: TextStyle(
                              fontSize: SizeConfig.sp(16),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                           Text(
                            "Age",
                             style: TextStyle(
                              fontSize: SizeConfig.sp(10),
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: SizeConfig.h(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatChip(
                         '${weightDifference > 0 ? '-' : '+'}${weightDifference.abs().toStringAsFixed(1)} kg',
                        weightDifference > 0 ? Icons.trending_down : Icons.trending_up,
                      ),
                        // Edit Button
                        GestureDetector(
                          onTap: _showUpdateBodyStats,
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.w(8)),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, color: Colors.white, size: SizeConfig.sp(16)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.h(24)),

            // BMI Card
            Container(
              padding: EdgeInsets.all(SizeConfig.w(20)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(SizeConfig.w(16)),
                    decoration: BoxDecoration(
                      color: _getBMIColor(currentBMI).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: _getBMIColor(currentBMI),
                      size: SizeConfig.sp(28),
                    ),
                  ),
                  SizedBox(width: SizeConfig.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(12),
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(4)),
                        Text(
                          currentBMI.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: SizeConfig.sp(24),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(12),
                      vertical: SizeConfig.h(6),
                    ),
                    decoration: BoxDecoration(
                      color: _getBMIColor(currentBMI).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(SizeConfig.w(12)),
                    ),
                    child: Text(
                      bmiCategory,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w600,
                        color: _getBMIColor(currentBMI),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.h(24)),

            // Progress Stats
            Container(
              padding: EdgeInsets.all(SizeConfig.w(20)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressStat(
                    'Start',
                    '${startWeight.toStringAsFixed(1)} kg',
                    textColor,
                    subTextColor,
                  ),
                  Container(width: 1, height: 40, color: borderColor),
                  _buildProgressStat(
                    'Progress',
                    '${totalProgress.toStringAsFixed(1)} kg',
                    textColor,
                    subTextColor,
                  ),
                  Container(width: 1, height: 40, color: borderColor),
                  _buildProgressStat(
                    'To Goal',
                    '${weightDifference.abs().toStringAsFixed(1)} kg',
                    textColor,
                    subTextColor,
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.h(24)),

            // Weight Chart
            Text(
              'PROGRESS CHART',
              style: TextStyle(
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w700,
                color: subTextColor,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: SizeConfig.h(16)),
            Container(
              height: SizeConfig.h(200),
              padding: EdgeInsets.all(SizeConfig.w(16)),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(SizeConfig.w(20)),
                border: Border.all(color: borderColor),
              ),
              child: _buildWeightChart(textColor, subTextColor),
            ),

            SizedBox(height: SizeConfig.h(24)),

            // Recent Entries
            Text(
              'RECENT ENTRIES',
              style: TextStyle(
                fontSize: SizeConfig.sp(12),
                fontWeight: FontWeight.w700,
                color: subTextColor,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: SizeConfig.h(16)),
            ..._weightHistory.reversed.take(5).map((entry) => _buildHistoryItem(
              entry,
              cardBg,
              borderColor,
              textColor,
              subTextColor,
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUpdateBodyStats,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.update, color: Colors.white),
        label: const Text(
          'Update Stats',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(12),
        vertical: SizeConfig.h(8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SizeConfig.w(12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: SizeConfig.sp(16), color: Colors.white),
          SizedBox(width: SizeConfig.w(6)),
          Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.sp(12),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: SizeConfig.sp(18),
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
        SizedBox(height: SizeConfig.h(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.sp(11),
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
      ],
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildWeightChart(Color textColor, Color subTextColor) {
    final spots = _weightHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: subTextColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _weightHistory.length) return const Text('');
                final date = _weightHistory[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_weightHistory.length - 1).toDouble(),
        minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2,
        maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFF6F00)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF9800).withOpacity(0.3),
                  const Color(0xFFFF9800).withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    WeightEntry entry,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeConfig.h(12)),
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(10)),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monitor_weight_rounded,
              color: Colors.orange,
              size: SizeConfig.sp(20),
            ),
          ),
          SizedBox(width: SizeConfig.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(16),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: SizeConfig.h(4)),
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(12),
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
