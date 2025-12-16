import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/workout/steps_counter_card.dart';
import '../components/workout/workout_capsule_card.dart';
import '../components/workout/interactive_workout_card.dart';
import '../components/workout/workout_detail_sheet.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';
import '../services/firestore/workout_plan_service.dart';
import '../utils/size_config.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_celebration_overlay.dart';
import 'gamification/global_streak_success_page.dart';
import 'gamification/level_up_page.dart';
 // Add this import
import '../components/common/global_back_button.dart'; // Added import
import '../providers/theme_provider.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import 'workout/create_workout_plan_page.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  final WorkoutService _workoutService = WorkoutService();

  List<Workout> _todayWorkouts = [];
  List<Workout> _recommendedWorkouts = [];
  List<Workout> _filteredWorkouts = [];
  List<Map<String, dynamic>> _userPlans = [];
  bool _isLoading = true;
  bool _isSubmitting = false; // Page-wide loading state for completion

  WorkoutCategory _selectedCategory = WorkoutCategory.all;

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
    _loadUserPlans();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      final plans = userId != null
          ? await WorkoutPlanService().getUserWorkoutPlans(userId)
          : <Map<String, dynamic>>[];

      List<Workout> todayWorkouts = [];

      if (plans.isNotEmpty) {
        todayWorkouts = await _workoutService.getTodayWorkouts();
      }

      final recommendedWorkouts = await _workoutService
          .getRecommendedWorkouts();

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

  Future<void> _loadUserPlans() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('No user ID - cannot load plans');
      return;
    }

    try {
      print('Loading plans for user: $userId');
      final plans = await WorkoutPlanService().getUserWorkoutPlans(userId);
      print('Loaded ${plans.length} plans');
      if (mounted) {
        setState(() {
          _userPlans = plans;
        });
      }
    } catch (e) {
      print('Error loading user plans: $e');
      if (mounted) {
        setState(() {
          _userPlans = []; // Set to empty list on error
        });
      }
    }
  }

  void _showWorkoutDetails(Workout workout) {
    WorkoutDetailSheet.show(
      context,
      workout,
      isDarkMode: ref.watch(themeProvider),
      onStartWorkout: () =>
          _startWorkoutFromRecommended(workout, closeOnAdd: true),
    );
  }

  void _startWorkoutFromRecommended(
    Workout workout, {
    bool closeOnAdd = false,
  }) {
    if (!_todayWorkouts.any((w) => w.id == workout.id)) {
      setState(() {
        _todayWorkouts.add(workout);
        if (_selectedCategory == WorkoutCategory.all ||
            _selectedCategory == workout.category) {
          _filteredWorkouts.add(workout);
        }
      });
    }

    if (closeOnAdd) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${workout.title} added to today!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color(0xFFCEF24B),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
        _remainingSeconds =
            3; // Debug: 3 seconds instead of workout.durationMinutes * 60
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        await _handleWorkoutCompletion(index);
      }
    });
  }

  Future<void> _handleWorkoutCompletion(int index) async {
    _timer?.cancel();
    final workout = _filteredWorkouts[index];

    setState(() {
      _isSubmitting = true; // Start loading
    });

    try {
      final gamificationService = GamificationService();
      final isFirstWorkoutOfDay = await gamificationService.isFirstOfDayForType(
        StreakType.workout,
      );

      await _workoutService.completeWorkout(workout);

      gamificationService.onLevelUp = (newLevel, xpGained) async {
        if (mounted) {
          final currentData = await gamificationService.getCurrentData();
          final totalXP = currentData.stats.currentXp;

          await Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => LevelUpPage(
                newLevel: newLevel,
                xpGained: xpGained,
                totalXP: totalXP,
              ),
            ),
          );
        }
      };

      if (mounted) {
        if (isFirstWorkoutOfDay) {
          final data = await gamificationService.getCurrentData();
          final streakCount = data.stats.workoutStreak; // Use verified property

          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GlobalStreakSuccessPage(
                    globalStreak: streakCount,
                    themeColor: const Color(0xFFCEF24B), // Lime
                    title: 'Workout Streak!',
                    subtitle: 'Great job keeping up the momentum!',
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Workout completed! Ã°Å¸â€™Âª',
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
    } catch (e) {
      print("Workout completion error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Issues saving workout. Check internet."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false; // Stop loading
        });
      }
    }
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

  void _onCapsuleComplete() {
    _handleWorkoutCompletion(_selectedIndex);
  }

  void _onNextWorkout() {
    if (_selectedIndex < _filteredWorkouts.length - 1) {
      setState(() {
        _selectedIndex = _selectedIndex + 1;
        _remainingSeconds = null;
        _playingIndex =
            null; // Auto-pause or auto-play? User said "moves to next workout".
      });
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

    final currentWorkout =
        _filteredWorkouts.isNotEmpty &&
            _selectedIndex < _filteredWorkouts.length
        ? _filteredWorkouts[_selectedIndex]
        : null;

    final hasNextWorkout =
        _filteredWorkouts.isNotEmpty &&
        _selectedIndex < _filteredWorkouts.length - 1;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            leading: GlobalBackButton(
              isDark: isDarkMode,
              onPressed: () => Navigator.maybePop(context),
            ),
            actions: [
              SizedBox(width: SizeConfig.w(16)),
            ],
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            iconTheme: IconThemeData(color: appBarIconColor),
          ),
          body: StreakCelebrationOverlay(
            key: _celebrationKey,
            child: SafeArea(
              child: _isLoading
                  ? Center(
                      child: BouncingDotsIndicator(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.h(8)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
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

                          Center(
                            child: StepCounterCard(
                              steps: 8234,
                              maxSteps: 10000,
                              distanceKm: 6.5,
                              isDarkMode: isDarkMode,
                            ),
                          ),

                          SizedBox(height: SizeConfig.h(20)),

                          StreamBuilder<GamificationData>(
                            stream: GamificationService().gamificationStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData)
                                return const SizedBox.shrink();
                              final data = snapshot.data!;

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontal,
                                ),
                                child: StreakCard(
                                  streakDays: data.stats.workoutStreak,
                                  isDarkMode: isDarkMode,
                                  title: 'Workout Streak',
                                  currentLevel: data.stats.currentLevel,
                                  currentXp: data.stats.currentXp,
                                  nextLevelXp: GamificationService()
                                      .getXpForNextLevel(
                                        data.stats.currentLevel,
                                      ),
                                  gradientColors: isDarkMode
                                      ? [
                                          Colors.black,
                                          const Color(0xFF1A1A1A), // Dark grey
                                          const Color(
                                            0xFFCEF24B,
                                          ), // Lime accent
                                        ]
                                      : [
                                          Colors.white,
                                          const Color(0xFFF5F5F5), // Light grey
                                          const Color(
                                            0xFFCEF24B,
                                          ), // Lime accent
                                        ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: SizeConfig.h(30)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: Divider(color: borderColor, thickness: 1),
                          ),

                          SizedBox(height: SizeConfig.h(24)),

                          if (currentWorkout != null) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontal,
                              ),
                              child: WorkoutCapsuleCard(
                                isDarkMode: isDarkMode,
                                hasOngoing: _playingIndex != null,
                                workoutName: currentWorkout.title,
                                minutes: currentWorkout.durationMinutes,
                                kcal: currentWorkout.caloriesBurned,
                                isPlaying:
                                    _playingIndex != null &&
                                    _playingIndex == _selectedIndex,
                                heroTag: 'play_button_${currentWorkout.id}',
                                onToggle: _onCapsuleToggle,
                                onComplete:
                                    _onCapsuleComplete, // Wire up complete button
                                onNext: hasNextWorkout
                                    ? _onNextWorkout
                                    : null, // Pass next callback if available
                                points: currentWorkout.points,
                                isCompleted: _completed.contains(
                                  currentWorkout.id,
                                ),
                                remainingSeconds:
                                    _selectedIndex == _playingIndex ||
                                        (_remainingSeconds != null &&
                                            _selectedIndex == _selectedIndex)
                                    ? _remainingSeconds
                                    : null,
                                activeColor: const Color.fromRGBO(
                                  206,
                                  242,
                                  75,
                                  1,
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(24)),
                          ],


                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: _buildCreatePlanCapsule(context),
                          ),

                          SizedBox(height: SizeConfig.h(24)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: Divider(color: borderColor, thickness: 1),
                          ),

                          SizedBox(height: SizeConfig.h(24)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: Text(
                              "My Plans",
                              style: TextStyle(
                                fontSize: SizeConfig.sp(18),
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(12)),

                          _userPlans.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontal,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(SizeConfig.w(24)),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white10
                                            : Colors.black12,
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.fitness_center_outlined,
                                            size: SizeConfig.w(48),
                                            color: isDarkMode
                                                ? Colors.white54
                                                : Colors.black38,
                                          ),
                                          SizedBox(height: SizeConfig.h(12)),
                                          Text(
                                            'Generate a workout plan',
                                            style: TextStyle(
                                              fontSize: SizeConfig.sp(16),
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: SizeConfig.h(6)),
                                          Text(
                                            'Use our AI to create a custom routine',
                                            style: TextStyle(
                                              fontSize: SizeConfig.sp(13),
                                              color: isDarkMode
                                                  ? Colors.white54
                                                  : Colors.black38,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: SizeConfig.h(160),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _userPlans.length,
                                    itemBuilder: (context, index) {
                                      final plan = _userPlans[index];
                                      final isFirst = index == 0;
                                      final isLast =
                                          index == _userPlans.length - 1;

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: isFirst
                                              ? horizontal
                                              : SizeConfig.w(8),
                                          right: isLast ? horizontal : 0,
                                        ),
                                        child: _buildPlanCard(
                                          plan,
                                          isDarkMode,
                                          const Color(0xFFCEF24B),
                                          isDarkMode
                                              ? const Color(0xFF1E1E1E)
                                              : Colors.white,
                                          primaryText,
                                        ),
                                      );
                                    },
                                  ),
                                ),

                          SizedBox(height: SizeConfig.h(24)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: Divider(color: borderColor, thickness: 1),
                          ),
                          SizedBox(height: SizeConfig.h(24)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
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

                          if (_filteredWorkouts.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontal,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(SizeConfig.w(24)),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white10
                                        : Colors.black12,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.fitness_center_outlined,
                                        size: SizeConfig.w(48),
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black38,
                                      ),
                                      SizedBox(height: SizeConfig.h(12)),
                                      Text(
                                        "It's a rest day or no active plans",
                                        style: TextStyle(
                                          fontSize: SizeConfig.sp(16),
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: SizeConfig.h(6)),
                                      Text(
                                        "Tap + to add a custom workout",
                                        style: TextStyle(
                                          fontSize: SizeConfig.sp(13),
                                          color: isDarkMode
                                              ? Colors.white54
                                              : Colors.black38,
                                        ),
                                      ),
                                    ],
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
                                      _playingIndex != null &&
                                      _playingIndex == index;
                                  final isCompleted = _completed.contains(
                                    workout.id,
                                  );
                                  final isPaused =
                                      _selectedIndex == index &&
                                      !isPlaying &&
                                      !isCompleted;

                                  return InteractiveWorkoutCard(
                                    key: ValueKey(
                                      'workout_${workout.id}_$index',
                                    ),
                                    workout: workout,
                                    index: index,
                                    isPlaying: isPlaying,
                                    isCompleted: isCompleted,
                                    isPaused: isPaused,
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
        ),

        if (_isSubmitting)
          Positioned.fill(
            child: Stack(
              children: [
                AbsorbPointer(
                  absorbing: true,
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.3,
                    ), // Semi-transparent dim
                  ),
                ),
                Center(
                  child: BouncingDotsIndicator(
                    color: isDarkMode ? const Color(0xFFCEF24B) : Colors.white,
                    size: 12.0,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCreatePlanCapsule(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final limeColor = const Color(0xFFCEF24B);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateWorkoutPlanPage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: SizeConfig.h(120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2C2C2C),
                  ] // Dark Surface
                : [
                    const Color(0xFFF9FBE7),
                    const Color(0xFFF0F4C3),
                  ], // Light Lime
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDarkMode
                ? limeColor.withOpacity(0.3)
                : limeColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: limeColor.withOpacity(isDarkMode ? 0.15 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -20,
              child: Icon(
                Icons.fitness_center_rounded,
                size: SizeConfig.w(140),
                color: isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SizeConfig.w(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: limeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "AI POWERED",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Create a workout plan",
                          style: TextStyle(
                            fontSize: SizeConfig.sp(20),
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          "Tailored to your fitness goals",
                          style: TextStyle(
                            fontSize: SizeConfig.sp(12),
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildPlanCard(
    Map<String, dynamic> plan,
    bool isDark,
    Color accentColor,
    Color cardColor,
    Color textColor,
  ) {
    final weeklyPlan = plan['weeklyPlan'] as List? ?? [];
    final daysCount = weeklyPlan.length;
    final isActive = plan['isActive'] == true;

    return Container(
      width: SizeConfig.w(220),
      padding: EdgeInsets.all(SizeConfig.w(20)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? accentColor
              : (isDark ? Colors.white10 : Colors.black12),
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(
                  fontSize: SizeConfig.sp(10),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          if (isActive) SizedBox(height: SizeConfig.h(12)),
          Text(
            plan['name'] ?? 'Workout Plan',
            style: TextStyle(
              fontSize: SizeConfig.sp(16),
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: SizeConfig.h(8)),
          Text(
            '$daysCount days/week',
            style: TextStyle(
              fontSize: SizeConfig.sp(13),
              color: textColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (!isActive)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    await WorkoutPlanService().setActiveWorkoutPlan(
                      userId,
                      plan['id'],
                      DateTime.now(),
                    );
                    _loadWorkouts();
                    _loadUserPlans();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Plan activated!'),
                        backgroundColor: accentColor,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Activate',
                  style: TextStyle(
                    fontSize: SizeConfig.sp(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
