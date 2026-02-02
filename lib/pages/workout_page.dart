import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_plans_provider.dart';
import '../providers/workout_provider.dart';
import '../components/workout/steps_counter_card.dart';
import '../components/workout/workout_capsule_card.dart';
import '../components/workout/interactive_workout_card.dart';
import '../components/workout/workout_detail_sheet.dart';
import '../models/workout_model.dart';
import '../services/workout_service.dart';
import '../utils/size_config.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_celebration_overlay.dart';
import 'gamification/global_streak_success_page.dart';
import 'gamification/level_up_page.dart';
import '../components/common/global_back_button.dart';
import '../providers/theme_provider.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import 'workout/create_workout_plan_page.dart';
import 'workout/workout_plan_detail_page.dart';
import 'active_tracking_page.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> with TickerProviderStateMixin {
  final WorkoutService _workoutService = WorkoutService();
  final GlobalKey _celebrationKey = GlobalKey();

   
  List<Workout> _filteredWorkouts = [];
  bool _isCategoryLoading = false; 

  WorkoutCategory _selectedCategory = WorkoutCategory.all;

   
  int _selectedIndex = 0;
  
   
  String? _playingWorkoutId;
  
  Timer? _timer;
  int? _remainingSeconds;
  
   
   
   
   
  
  late AnimationController _playAnimController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _playAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _onCategorySelected(WorkoutCategory category) async {
    setState(() {
      _selectedCategory = category;
      _isCategoryLoading = true;
    });

    try {
      if (category == WorkoutCategory.all) {
          
          
         _isCategoryLoading = false;
          
         _filteredWorkouts = [];
      } else {
        final workouts = await _workoutService.getWorkoutsByCategory(category);
        if (mounted) {
          setState(() {
            _filteredWorkouts = workouts;
            _isCategoryLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCategoryLoading = false;
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
    ref.read(workoutProvider.notifier).addWorkoutToToday(workout);

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

  void _startTimer(String workoutId, int index, List<Workout> activeList) {
    if (index >= activeList.length) return;

    _timer?.cancel();
    
    setState(() {
      _playingWorkoutId = workoutId;
      _selectedIndex = index;
      
      _remainingSeconds ??= 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds != null && _remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        await _handleWorkoutCompletion(workoutId, activeList);
      }
    });
  }

  Future<void> _handleWorkoutCompletion(String workoutId, List<Workout> activeList) async {
    _timer?.cancel();
    
    final workout = activeList.firstWhere((w) => w.id == workoutId, orElse: () => activeList[0]);

    try {
      final gamificationService = GamificationService();
      final isFirstWorkoutOfDay = await gamificationService.isFirstOfDayForType(
        StreakType.workout,
      );

       
      await ref.read(workoutProvider.notifier).completeWorkout(workout);
      
       
       
      setState(() {
        _playingWorkoutId = null;
        _remainingSeconds = null;
      });

       
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
          final streakCount = data.stats.workoutStreak;

          await Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GlobalStreakSuccessPage(
                    globalStreak: streakCount,
                    themeColor: const Color(0xFFCEF24B),
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
    } catch (e) {
      print("Workout completion error: $e");
    } 
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _playingWorkoutId = null;
    });
  }

  void _onCardPressed(String workoutId, int index, List<Workout> activeList) {
    if (_playingWorkoutId == workoutId) {
      _pauseTimer();
    } else {
        
      if (_selectedIndex != index) {
        _remainingSeconds = null;
      }
      _startTimer(workoutId, index, activeList);
    }
  }

  void _onCardRestarted(String workoutId, int index, List<Workout> activeList) {
     
    ref.read(workoutProvider.notifier).uncompleteWorkout(workoutId);
    
    _remainingSeconds = null;
    _startTimer(workoutId, index, activeList);
  }

  void _onCapsuleToggle(String currentId, int currentIndex, List<Workout> activeList) {
    final completed = ref.read(workoutProvider).value?.completedWorkoutIds ?? {};
    
    if (_playingWorkoutId == currentId) {
       
      _pauseTimer();
    } else if (completed.contains(currentId)) {
        
        
       ref.read(workoutProvider.notifier).uncompleteWorkout(currentId);
       _remainingSeconds = null;  
       _startTimer(currentId, currentIndex, activeList);
    } else {
      _startTimer(currentId, currentIndex, activeList);
    }
  }

   
  void _onNextWorkout(List<Workout> activeList) {
    final notifier = ref.read(workoutProvider.notifier);
    
     
    final nextIndex = notifier.getNextUncompletedIndex(_selectedIndex, activeList);
    
    if (nextIndex < activeList.length) {
      setState(() {
        _selectedIndex = nextIndex;
        _remainingSeconds = null;
        _playingWorkoutId = null;  
      });
    }
  }

  void _removeWorkoutFromToday(Workout workout) {
    ref.read(workoutProvider.notifier).removeWorkoutFromToday(workout.id);
    
    setState(() {
        
       if (_filteredWorkouts.isNotEmpty) {
         _filteredWorkouts.removeWhere((w) => w.id == workout.id);
       }
       if (_playingWorkoutId == workout.id) {
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
    
     
    final workoutState = ref.watch(workoutProvider);
    final plansState = ref.watch(workoutPlansProvider);
    
     
    ref.listen<AsyncValue<WorkoutPlansState>>(workoutPlansProvider, (prev, next) {
       final prevId = prev?.value?.activePlanId;
       final nextId = next.value?.activePlanId;
       
        
       if (prevId != nextId) {
           
          ref.invalidate(workoutProvider);
       }
    });

    final isLoading = workoutState.isLoading;
    final completedIds = workoutState.value?.completedWorkoutIds ?? {};
    
     
     
     
    List<Workout> displayedWorkouts;
    if (_selectedCategory == WorkoutCategory.all && _filteredWorkouts.isEmpty) {
         
        displayedWorkouts = ref.read(workoutProvider.notifier).sortedWorkouts;
    } else {
        displayedWorkouts = _filteredWorkouts;
    }

    final horizontal = SizeConfig.w(16);
    final headerSize = SizeConfig.sp(48);

    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final appBarIconColor = isDarkMode ? Colors.white : Colors.black;
    final titleColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryText = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;

     
    if (_selectedIndex >= displayedWorkouts.length && displayedWorkouts.isNotEmpty) {
      _selectedIndex = 0;
    }
    
    final currentWorkout =
        displayedWorkouts.isNotEmpty &&
            _selectedIndex < displayedWorkouts.length
        ? displayedWorkouts[_selectedIndex]
        : null;

     
     
    final hasNextWorkout = displayedWorkouts.length > 1;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            leading: GlobalBackButton(
              isDark: isDarkMode,
              onPressed: () => Navigator.maybePop(context),
            ),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: appBarIconColor),
          ),
          body: StreakCelebrationOverlay(
            key: _celebrationKey,
            child: SafeArea(
              child: isLoading || _isCategoryLoading
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const ActiveTrackingPage()),
                                );
                              },
                              child: StreamBuilder<ActivityData?>(
                                stream: ActivityService().streamTodayActivity(),
                                builder: (context, snapshot) {
                                  final activityData = snapshot.data;
                                  final steps = activityData?.steps ?? 0;
                                  final maxSteps = activityData?.maxSteps ?? 10000;
                                  final distanceKm = (steps * 0.000762).toDouble();

                                  return StepCounterCard(
                                    steps: steps,
                                    maxSteps: maxSteps,
                                    distanceKm: distanceKm,
                                    isDarkMode: isDarkMode,
                                  );
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: SizeConfig.h(20)),

                           
                          StreamBuilder<GamificationData>(
                            stream: GamificationService().gamificationStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox.shrink();
                              }
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
                                          const Color(0xFF1A1A1A),
                                          const Color(0xFFCEF24B),
                                        ]
                                      : [
                                          Colors.white,
                                          const Color(0xFFF5F5F5),
                                          const Color(0xFFCEF24B),
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
                                hasOngoing: _playingWorkoutId != null,
                                workoutName: currentWorkout.title,
                                workoutId: currentWorkout.id,
                                minutes: currentWorkout.durationMinutes,
                                kcal: currentWorkout.caloriesBurned,
                                isPlaying: _playingWorkoutId == currentWorkout.id,
                                heroTag: 'play_button_${currentWorkout.id}',
                                onToggle: () => _onCapsuleToggle(currentWorkout.id, _selectedIndex, displayedWorkouts),
                                onComplete: () => _handleWorkoutCompletion(currentWorkout.id, displayedWorkouts),
                                onNext: hasNextWorkout
                                    ? () => _onNextWorkout(displayedWorkouts)
                                    : null,
                                points: currentWorkout.points,
                                isCompleted: completedIds.contains(
                                  currentWorkout.id,
                                ),
                                remainingSeconds: _remainingSeconds,
                                activeColor: const Color(0xFFCEF24B),
                              ),
                            ),
                            SizedBox(height: SizeConfig.h(24)),
                          ],

                           
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                            ),
                            child: _buildGeneratePlanCapsule(context, isDarkMode),
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

                          (plansState.value?.plans ?? []).isEmpty
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
                                            size: SizeConfig.w(32),
                                            color: isDarkMode
                                                ? Colors.white54
                                                : Colors.black38,
                                          ),
                                          SizedBox(height: SizeConfig.h(12)),
                                          Text(
                                            'No custom plans',
                                            style: TextStyle(
                                              fontSize: SizeConfig.sp(14),
                                              fontWeight: FontWeight.w500,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: SizeConfig.h(200),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: (plansState.value?.plans ?? []).length,
                                    itemBuilder: (context, index) {
                                      final plan = (plansState.value?.plans ?? [])[index];
                                      final isFirst = index == 0;
                                      final isLast =
                                          index == (plansState.value?.plans ?? []).length - 1;
                                      final isActive = plan['id'] == plansState.value?.activePlanId;

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
                                          isActive,
                                          () => ref.read(workoutPlansProvider.notifier).activatePlan(plan['id']),
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
                                  "${displayedWorkouts.length} workouts",
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

                          if (displayedWorkouts.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontal,
                              ),
                              child: Center(
                                child: Text(
                                  "No workouts for today",
                                  style: TextStyle(
                                     color: isDarkMode ? Colors.white54 : Colors.grey,
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
                                itemCount: displayedWorkouts.length,
                                itemBuilder: (context, index) {
                                  final workout = displayedWorkouts[index];
                                  final isPlaying = _playingWorkoutId == workout.id;
                                  final isCompleted = completedIds.contains(
                                    workout.id,
                                  );
                                  
                                   
                                   
                                  final isSelected = _selectedIndex == index;

                                  return InteractiveWorkoutCard(
                                    key: ValueKey(
                                      'workout_${workout.id}_$index',
                                    ),
                                    workout: workout,
                                    index: index,
                                    isPlaying: isPlaying,
                                    isCompleted: isCompleted,
                                    isPaused: isSelected &&
                                        !isPlaying &&
                                        !isCompleted,
                                    isDarkMode: isDarkMode,
                                    onPressed: () {
                                      if (isCompleted) {
                                        _onCardRestarted(workout.id, index, displayedWorkouts);
                                      } else {
                                        _onCardPressed(workout.id, index, displayedWorkouts);
                                      }
                                    },
                                    onDelete: () =>
                                        _removeWorkoutFromToday(workout),
                                  );
                                },
                              ),
                            ),
                          SizedBox(height: SizeConfig.h(100)),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

   
  Widget _buildGeneratePlanCapsule(BuildContext context, bool isDarkMode) {
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
        height: SizeConfig.h(64),  
        decoration: BoxDecoration(
          color: const Color(0xFFCEF24B),  
          borderRadius: BorderRadius.circular(SizeConfig.w(32)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCEF24B).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: SizeConfig.w(20)),
            Container(
              padding: EdgeInsets.all(SizeConfig.w(8)),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: const Color(0xFFCEF24B),
                size: SizeConfig.w(18),
              ),
            ),
            SizedBox(width: SizeConfig.w(16)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate Workout Plan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.sp(15),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'AI-powered personalization',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: SizeConfig.sp(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: SizeConfig.w(8)),
              width: SizeConfig.w(48),
              height: SizeConfig.w(48),
              decoration: const BoxDecoration(
                color: Colors.black,  
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: const Color(0xFFCEF24B),
                size: SizeConfig.w(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

   
  Widget _buildPlanCard(
    Map<String, dynamic> plan,
    bool isDarkMode,
    Color accentColor,
    Color cardColor,
    Color textColor,
    bool isActive,
    VoidCallback onActivate,
  ) {
    final String name = plan['name'] ?? 'Workout Plan';
    final String goal = plan['goal'] ?? 'Fitness';
    final int days = (plan['weeklyPlan'] as List?)?.length ?? 0;
    
     
    final glassColor = isDarkMode 
        ? const Color(0xFF1E1E1E).withOpacity(0.6) 
        : Colors.white.withOpacity(0.8);
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black12;
    final limeAccent = const Color(0xFFCEF24B);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPlanDetailPage(
              plan: plan,
              isDarkMode: isDarkMode,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: SizeConfig.w(220),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(24),
              border: isActive 
                  ? Border.all(color: limeAccent.withOpacity(0.5), width: 1.5)
                  : Border.all(color: borderColor),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode 
                    ? [Colors.white.withOpacity(0.05), Colors.transparent]
                    : [Colors.white, Colors.white.withValues(alpha: 0.5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: limeAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: limeAccent, size: 14),
                          if (isActive) ...[
                            const SizedBox(width: 4),
                            Text("ACTIVE", style: TextStyle(color: limeAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          ]
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: isDarkMode ? Colors.white24 : Colors.black26, size: 20),
                  ],
                ),
                Expanded(  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        goal.toUpperCase(),
                        style: TextStyle(
                          fontSize: SizeConfig.sp(10),
                          fontWeight: FontWeight.w900,
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: SizeConfig.sp(18),
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: isDarkMode ? Colors.white38 : Colors.black38),
                          const SizedBox(width: 6),
                          Text(
                            "$days Days / Week",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(12),
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                 
                if (!isActive)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onActivate();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Activate",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontSize: SizeConfig.sp(12),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                   SizedBox(
                      height: 36,
                      child: Align(
                         alignment: Alignment.centerLeft,
                         child: Text("Current Plan", style: TextStyle(color: limeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                   )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
