import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/workout/steps_counter_card.dart';
import '../components/workout/workout_capsule_card.dart';
import '../components/workout/interactive_workout_card.dart';
import '../components/workout/category_chip.dart';
import '../components/workout/workout_discovery_card.dart';
import '../components/workout/workout_detail_sheet.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';
import '../utils/size_config.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../components/gamification/streak_card.dart';
import '../models/gamification_model.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_celebration_overlay.dart';
import 'global_streak_success_page.dart';
import '../providers/theme_provider.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  final WorkoutService _workoutService = WorkoutService();

  // Data
  List<Workout> _todayWorkouts = [];
  List<Workout> _recommendedWorkouts = [];
  List<Workout> _filteredWorkouts = [];
  bool _isLoading = true;

  // Category filter
  WorkoutCategory _selectedCategory = WorkoutCategory.all;

  // Workout playback state
  int _selectedIndex = 0;
  int? _playingIndex;
  final Set<String> _completed = {};

  Timer? _timer;

  int? _remainingSeconds;
  final GlobalKey<StreakCelebrationOverlayState> _celebrationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    try {
      final todayWorkouts = await _workoutService.getTodayWorkouts();
      final recommendedWorkouts =
          await _workoutService.getRecommendedWorkouts();

      if (mounted) {
        setState(() {
          _todayWorkouts = todayWorkouts;
          _recommendedWorkouts = recommendedWorkouts;
          _filteredWorkouts = todayWorkouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onCategorySelected(WorkoutCategory category) async {
    setState(() {
      _selectedCategory = category;
      _isLoading = true;
    });

    try {
      final workouts = await _workoutService.getWorkoutsByCategory(category);
      if (mounted) {
        setState(() {
          _filteredWorkouts = workouts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showWorkoutDetails(Workout workout) {
    WorkoutDetailSheet.show(
      context,
      workout,
      isDarkMode: ref.watch(themeProvider),
      onStartWorkout: () => _startWorkoutFromRecommended(workout),
    );
  }

  void _startWorkoutFromRecommended(Workout workout) {
    if (!_todayWorkouts.any((w) => w.id == workout.id)) {
      setState(() {
        _todayWorkouts.add(workout);
        if (_selectedCategory == WorkoutCategory.all ||
            _selectedCategory == workout.category) {
          _filteredWorkouts.add(workout);
        }
      });
    }
    Navigator.pop(context);
  }

  void _startTimer(int index) {
    if (index >= _filteredWorkouts.length) return;

    _timer?.cancel();
    final workout = _filteredWorkouts[index];

    setState(() {
      _playingIndex = index;
      _selectedIndex = index;
      _completed.remove(workout.id);

      if (_remainingSeconds == null || _selectedIndex != index) {
        _remainingSeconds = 3; // Debug: 3 seconds instead of workout.durationMinutes * 60
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        _timer?.cancel();
        
        // Complete the workout first (this updates the streak)
        await _workoutService.completeWorkout(_filteredWorkouts[index]);
        
        // NOW check if both streaks are completed (after the update)
        final gamificationService = GamificationService();
        final bothCompleted = gamificationService.areBothStreaksCompletedToday();
        
        if (mounted) {
          if (bothCompleted) {
            // Show global streak success page
            final globalStreak = gamificationService.getCurrentData().stats.currentStreak;
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => GlobalStreakSuccessPage(
                  globalStreak: globalStreak,
                  themeColor: const Color(0xFFCEF24B), // Lime green for workout
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          } else {
            // Show simple snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Workout completed! 💪',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.black,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }

        setState(() {
          _completed.add(workout.id);
          _playingIndex = null;
          _remainingSeconds = null;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _playingIndex = null;
    });
  }

  void _onCardPressed(int index) {
    if (_playingIndex == index) {
      _pauseTimer();
    } else {
      if (_selectedIndex != index) {
        _remainingSeconds = null;
      }
      _startTimer(index);
    }
  }

  void _onCardRestarted(int index) {
    _remainingSeconds = null;
    _startTimer(index);
  }

  void _onCapsuleToggle() {
    if (_playingIndex != null) {
      _pauseTimer();
    } else {
      _startTimer(_selectedIndex);
    }
  }

  void _removeWorkoutFromToday(Workout workout) {
    setState(() {
      _todayWorkouts.removeWhere((w) => w.id == workout.id);
      _filteredWorkouts.removeWhere((w) => w.id == workout.id);

      if (_playingIndex != null && _filteredWorkouts.length <= _playingIndex!) {
        _pauseTimer();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${workout.title}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final horizontal = SizeConfig.w(16);
    final headerSize = SizeConfig.sp(48);

    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryText = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;

    final currentWorkout = _filteredWorkouts.isNotEmpty &&
            _selectedIndex < _filteredWorkouts.length
        ? _filteredWorkouts[_selectedIndex]
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: appBarIconColor),
          onPressed: () => Navigator.maybePop(context),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarIconColor),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: appBarIconColor,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: StreakCelebrationOverlay(
        key: _celebrationKey,
        child: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.h(8)),

                    // 1. Page Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Text(
                        "Workouts",
                        style: TextStyle(
                          fontSize: headerSize,
                          fontWeight: FontWeight.w300,
                          color: titleColor,
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    // 2. Steps Counter
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: const StepCounterCard(
                        steps: 8234,
                        maxSteps: 10000,
                        distanceKm: 6.5,
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(20)),

                    // 3. Workout Streak
                    StreamBuilder<GamificationData>(
                      stream: GamificationService().gamificationStream,
                      initialData: GamificationService().getCurrentData(),
                      builder: (context, snapshot) {
                        final data = snapshot.data!;

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontal),
                          child: StreakCard(
                            streakDays: data.stats.workoutStreak,
                            isDarkMode: isDarkMode,
                            title: 'Workout Streak',
                            icon: Icons.fitness_center_rounded,
                            gradientColors: isDarkMode
                                ? [
                                    const Color(0xFFFF416C),
                                    const Color(0xFFFF4B2B)
                                  ]
                                : [
                                    const Color(0xFFFF512F),
                                    const Color(0xFFDD2476)
                                  ],
                          ),
                        );
                      },
                    ),

                    SizedBox(height: SizeConfig.h(30)),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Divider(color: borderColor, thickness: 1),
                    ),

                    SizedBox(height: SizeConfig.h(24)),

                    // 4. Capsule Card
                    if (currentWorkout != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: WorkoutCapsuleCard(
                          isDarkMode: isDarkMode,
                          hasOngoing: _playingIndex != null,
                          workoutName: currentWorkout.title,
                          minutes: currentWorkout.durationMinutes,
                          kcal: currentWorkout.caloriesBurned,
                          isPlaying: _playingIndex != null &&
                              _playingIndex == _selectedIndex,
                          heroTag: 'play_button_$_selectedIndex',
                          onToggle: _onCapsuleToggle,
                          points: currentWorkout.points,
                          isCompleted: _completed.contains(currentWorkout.id),
                          remainingSeconds: _selectedIndex == _playingIndex ||
                                  (_remainingSeconds != null &&
                                      _selectedIndex == _selectedIndex)
                              ? _remainingSeconds
                              : null,
                          activeColor: const Color.fromRGBO(206, 242, 75, 1),
                        ),
                      ),
                      SizedBox(height: SizeConfig.h(24)),
                    ],

                    // 5. Recommended Workouts
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Text(
                        "Recommended Workouts",
                        style: TextStyle(
                          fontSize: SizeConfig.sp(18),
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(12)),

                    // Category chips
                    SizedBox(
                      height: SizeConfig.h(40),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: WorkoutCategory.values.map((category) {
                          final isFirst =
                              category == WorkoutCategory.values.first;
                          final isLast = category == WorkoutCategory.values.last;

                          return Padding(
                            padding: EdgeInsets.only(
                              left: isFirst ? horizontal : SizeConfig.w(8),
                              right: isLast ? horizontal : 0,
                            ),
                            child: CategoryChip(
                              category: category,
                              isSelected: _selectedCategory == category,
                              onTap: () => _onCategorySelected(category),
                              isDarkMode: isDarkMode,
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(16)),

                    // Recommended workout cards
                    if (_recommendedWorkouts.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(horizontal),
                        child: Center(
                          child: Text(
                            "No recommended workouts available",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              fontSize: SizeConfig.sp(14),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: SizeConfig.h(180),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _recommendedWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = _recommendedWorkouts[index];
                            final isFirst = index == 0;
                            final isLast =
                                index == _recommendedWorkouts.length - 1;

                            return Padding(
                              padding: EdgeInsets.only(
                                left: isFirst ? horizontal : SizeConfig.w(8),
                                right: isLast ? horizontal : 0,
                              ),
                              child: WorkoutDiscoveryCard(
                                workout: workout,
                                isDarkMode: isDarkMode,
                                onTap: () => _showWorkoutDetails(workout),
                                onAddToPlan: () =>
                                    _startWorkoutFromRecommended(workout),
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: SizeConfig.h(24)),

                    if (currentWorkout != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: Divider(color: borderColor, thickness: 1),
                      ),
                      SizedBox(height: SizeConfig.h(24)),
                    ],

                    // 6. Today's Workouts
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == WorkoutCategory.all
                                ? "Today's Workouts"
                                : "${_selectedCategory.displayName} Workouts",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(18),
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          Text(
                            "${_filteredWorkouts.length} workouts",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(14),
                              fontWeight: FontWeight.w300,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(12)),

                    // Workout cards
                    if (_filteredWorkouts.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(horizontal),
                        child: Center(
                          child: Text(
                            "No workouts found for this category",
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                              fontSize: SizeConfig.sp(14),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: SizeConfig.h(180),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredWorkouts.length,
                          itemBuilder: (context, index) {
                            final workout = _filteredWorkouts[index];
                            final isPlaying =
                                _playingIndex != null && _playingIndex == index;
                            final isCompleted = _completed.contains(workout.id);

                            return InteractiveWorkoutCard(
                              key: ValueKey('workout_${workout.id}_$index'),
                              workout: workout,
                              index: index,
                              isPlaying: isPlaying,
                              isCompleted: isCompleted,
                              isDarkMode: isDarkMode,
                              onPressed: () {
                                if (isCompleted) {
                                  _onCardRestarted(index);
                                } else if (isPlaying) {
                                  _pauseTimer();
                                } else {
                                  _onCardPressed(index);
                                }
                              },
                              onDelete: () {
                                _removeWorkoutFromToday(workout);
                              },
                            );
                          },
                        ),
                      ),

                    SizedBox(height: SizeConfig.h(80)),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
