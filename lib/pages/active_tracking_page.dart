import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/activity_service.dart';
import '../services/recording_api_service.dart';
import '../utils/size_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';

class ActiveTrackingPage extends ConsumerStatefulWidget {
  const ActiveTrackingPage({super.key});

  @override
  ConsumerState<ActiveTrackingPage> createState() => _ActiveTrackingPageState();
}

class _ActiveTrackingPageState extends ConsumerState<ActiveTrackingPage>
    with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  final RecordingApiService _recordingApiService = RecordingApiService();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _initialSensorSteps = -1;
  int _sessionSteps = 0;
  int _totalTodaySteps = 0;
  double _distanceKm = 0.0;
  double _calories = 0.0;
  bool _isActive = true;

  StreamSubscription<int>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initTracking();
  }

  Future<void> _initTracking() async {
    final activity = await _activityService.getTodayActivity();
    if (mounted) {
      setState(() {
        _totalTodaySteps = activity.steps;
        _updateMetrics();
      });
    }

    _sensorSubscription = _recordingApiService.stepStream.listen((
      rawSensorSteps,
    ) {
      if (!_isActive) return;

      if (_initialSensorSteps == -1) {
        _initialSensorSteps = rawSensorSteps;
      }

      final stepsDiff = rawSensorSteps - _initialSensorSteps;
      if (stepsDiff > 0 && stepsDiff > _sessionSteps) {
        setState(() {
          _sessionSteps = stepsDiff;
          _updateMetrics();
        });
      }
    });
  }

  void _updateMetrics() {
    final totalSteps = _totalTodaySteps + _sessionSteps;
    _distanceKm = (totalSteps * 0.000762);
    _calories = totalSteps * 0.04;
  }

  void _syncAndClose() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final displayedSteps = _totalTodaySteps + _sessionSteps;

    final isDarkMode = ref.watch(themeProvider);

    final bgColor = isDarkMode ? Colors.black : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFCEF24B);
    final secondaryTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final blobColor = isDarkMode
        ? accentColor.withOpacity(0.15)
        : accentColor.withOpacity(0.3);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: SizeConfig.w(300),
                      height: SizeConfig.w(300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [blobColor, Colors.transparent],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.h(20)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: secondaryTextColor),
                        onPressed: _syncAndClose,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "LIVE",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    Icon(Icons.directions_run, color: accentColor, size: 48),
                    const SizedBox(height: 16),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                      child: Text(
                        "$displayedSteps",
                        key: ValueKey<int>(displayedSteps),
                        style: GoogleFonts.inter(
                          fontSize: 80,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "STEPS TODAY",
                      style: TextStyle(
                        color: secondaryTextColor,
                        letterSpacing: 2.5,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.h(50)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetric(
                      context: context,
                      value: _calories.toStringAsFixed(0),
                      label: "KCAL",
                      icon: Icons.local_fire_department_rounded,
                      isDarkMode: isDarkMode,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: secondaryTextColor.withOpacity(0.2),
                    ),
                    _buildMetric(
                      context: context,
                      value: _distanceKm.toStringAsFixed(2),
                      label: "KM",
                      icon: Icons.map_outlined,
                      isDarkMode: isDarkMode,
                    ),
                  ],
                ),

                const Spacer(),

                GestureDetector(
                  onTap: () {
                    setState(() => _isActive = !_isActive);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(bottom: SizeConfig.h(40)),
                    width: SizeConfig.w(72),
                    height: SizeConfig.w(72),
                    decoration: BoxDecoration(
                      color: _isActive ? bgColor.withOpacity(0.1) : accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isActive
                            ? secondaryTextColor.withOpacity(0.3)
                            : accentColor,
                        width: 2,
                      ),
                      boxShadow: _isActive
                          ? []
                          : [
                              BoxShadow(
                                color: accentColor.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                    ),
                    child: Icon(
                      _isActive
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: _isActive ? textColor : Colors.black,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final labelColor = isDarkMode ? Colors.white54 : Colors.black54;

    return Column(
      children: [
        Icon(icon, color: labelColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
