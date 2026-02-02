import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/diet/water_intake_card.dart';
import '../components/diet/enhanced_meal_card.dart';
import '../components/diet/quick_add_meal_sheet.dart';
import '../components/diet/meal_history_calendar.dart';
import '../models/nutrition_model.dart';
import '../services/nutrition_service.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_celebration_overlay.dart';
import 'gamification/global_streak_success_page.dart';
import '../components/common/global_back_button.dart';
import 'gamification/level_up_page.dart';
import '../utils/size_config.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/services.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/diet/animated_nutrition_card.dart';
import 'generate_diet_page.dart';

class DietPage extends ConsumerStatefulWidget {
  const DietPage({super.key});

  @override
  ConsumerState<DietPage> createState() => _DietPageState();
}

class _DietPageState extends ConsumerState<DietPage>
    with SingleTickerProviderStateMixin {
  final NutritionService _nutritionService = NutritionService();
  DailyNutrition? _dailyNutrition;
  bool _isLoading = true;
  DateTime _currentDate = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late Animation<Offset> _slideAnimation;
  final GlobalKey<StreakCelebrationOverlayState> _celebrationKey = GlobalKey();

  Map<DateTime, DailyNutrition> _historyMap = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _loadData(_currentDate);
    _loadHistory();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData(DateTime date) async {
    setState(() {
      _isLoading = true;
      _currentDate = date;
    });

    try {
      final nutrition = await _nutritionService.getDailyNutrition(date);
      if (mounted) {
        setState(() {
          _dailyNutrition =
              nutrition ??
              DailyNutrition(
                date: date,
                meals: [],
                waterIntake: 0,
                goal: NutritionGoal(
                  dailyCalories: 2000,
                  protein: 150,
                  carbs: 200,
                  fats: 65,
                  waterGoal: 2500,
                ),
              );
          _isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dailyNutrition = DailyNutrition(
            date: date,
            meals: [],
            waterIntake: 0,
            goal: NutritionGoal(
              dailyCalories: 2000,
              protein: 150,
              carbs: 200,
              fats: 65,
              waterGoal: 2500,
            ),
          );
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));
      final history = await _nutritionService.getNutritionHistory(start, end);

      if (mounted) {
        setState(() {
          _historyMap = {
            for (var item in history)
              DateTime(item.date.year, item.date.month, item.date.day): item,
          };
        });
      }
    } catch (e) {
      print("Error loading history: $e");
    }
  }

  Future<void> _addWater(int amount) async {
    HapticFeedback.lightImpact();

    final oldIntake = _dailyNutrition?.waterIntake ?? 0;
    final newIntake = (oldIntake + amount).clamp(0, 99999);
    setState(() {
      _dailyNutrition = _dailyNutrition?.copyWith(waterIntake: newIntake);
    });

    _nutritionService.logWater(amount).catchError((e) {
      if (mounted) {
        setState(() {
          _dailyNutrition = _dailyNutrition?.copyWith(waterIntake: oldIntake);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log water: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  Future<void> _deleteMeal(String mealId) async {
    HapticFeedback.mediumImpact();
    await _nutritionService.deleteMeal(_currentDate, mealId);
    await _nutritionService.deleteMeal(_currentDate, mealId);
    _loadData(_currentDate);
    _loadHistory();
  }

  Future<void> _addMeal(Meal meal) async {
    final newMeal = meal.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
    );

    final gamificationService = GamificationService();
    final isFirstMealOfDay = await gamificationService.isFirstOfDayForType(
      StreakType.diet,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: BouncingDotsIndicator(color: Colors.white)),
    );

    try {
      await _nutritionService.logMeal(newMeal);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding meal: $e. Saved locally if possible.'),
          ),
        );
      }
      return;
    }

    if (mounted) Navigator.pop(context);

    gamificationService.onLevelUp = (newLevel, xpGained) async {
      if (mounted) {
        final currentData = await gamificationService.getCurrentData();
        final totalXP = currentData.stats.currentXp;

        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LevelUpPage(
                    newLevel: newLevel,
                    xpGained: xpGained,
                    totalXP: totalXP,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      }
    };

    final leveledUp = await gamificationService.addXp(25);

    if (mounted && !leveledUp) {
      if (isFirstMealOfDay) {
        final bothCompleted = await gamificationService
            .areBothStreaksCompletedToday();
        final data = await gamificationService.getCurrentData();
        final stats = data.stats;

        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GlobalStreakSuccessPage(
                  globalStreak: bothCompleted
                      ? stats.currentStreak
                      : stats.dietStreak,
                  themeColor: const Color(0xFF0EA5E9),
                  title: bothCompleted ? 'Perfect Day!' : 'Nutrition Streak!',
                  subtitle: bothCompleted
                      ? 'You completed both workout and diet goals today'
                      : 'Healthy eating streak kept alive! Great job!',
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
            content: Text(
              'Added ${meal.name}',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      _loadData(_currentDate);
      _loadHistory();
    }
  }

  void _showAddMealSheet() {
    final isDarkMode = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddMealSheet(
        isDarkMode: isDarkMode,
        onMealSelected: (meal) {
          Navigator.pop(context);
          _addMeal(meal);
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final isDarkMode = ref.watch(themeProvider);
    final isHistory = !_isSameDay(_currentDate, DateTime.now());

    final bg = isDarkMode
        ? (isHistory ? const Color(0xFF1F1A10) : const Color(0xFF121212))
        : (isHistory ? const Color(0xFFFFFDF5) : Colors.white);

    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: GlobalBackButton(
          isDark: isDarkMode,
          onPressed: () => Navigator.maybePop(context),
        ),

        centerTitle: true,
        title: isHistory
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('MMMM d, y').format(_currentDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.amberAccent
                            : Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              )
            : null,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
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
              : _dailyNutrition == null
              ? Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: textColor),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isHistory) ...[
                            SizedBox(height: SizeConfig.h(10)),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(16),
                              ),
                              child: Text(
                                'Diet\nDashboard',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(48),
                                  fontWeight: FontWeight.w300,
                                  color: textColor,
                                  height: 1.1,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: SizeConfig.h(24)),

                          if (!isHistory)
                            StreamBuilder<GamificationData>(
                              stream: GamificationService().gamificationStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                final data = snapshot.data!;
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.w(16),
                                  ),
                                  child: StreakCard(
                                    streakDays: data.stats.dietStreak,
                                    isDarkMode: isDarkMode,
                                    title: 'Diet Streak',
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
                                            const Color(0xFF0EA5E9),
                                          ]
                                        : [
                                            Colors.white,
                                            const Color(0xFFF5F5F5),
                                            const Color(0xFF0EA5E9),
                                          ],
                                  ),
                                );
                              },
                            ),

                          SizedBox(height: SizeConfig.h(20)),

                          if (!isHistory) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(16),
                              ),
                              child: _buildGeneratePlanCapsule(isDarkMode),
                            ),
                            SizedBox(height: SizeConfig.h(24)),
                          ],

                          AnimatedNutritionCard(
                            nutrition: _dailyNutrition!,
                            isDarkMode: isDarkMode,
                            isHistory: isHistory,
                          ),

                          SizedBox(height: SizeConfig.h(16)),

                          if (!isHistory) ...[
                            _buildQuickActions(isDarkMode),
                            SizedBox(height: SizeConfig.h(24)),
                          ],

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(16),
                            ),
                            child: WaterIntakeSliderCard(
                              isDarkMode: isDarkMode,
                              currentIntake: _dailyNutrition?.waterIntake ?? 0,
                              dailyGoal:
                                  _dailyNutrition?.goal.waterGoal ?? 2500,
                              onAddWater: (amount) => _addWater(amount),
                            ),
                          ),

                          SizedBox(height: SizeConfig.h(24)),

                          MealHistoryCalendar(
                            isDarkMode: isDarkMode,
                            selectedDate: _currentDate,
                            onDateSelected: (date) => _loadData(date),
                            minDate: FirebaseAuth
                                .instance
                                .currentUser
                                ?.metadata
                                .creationTime,
                            historyData: _historyMap,
                          ),

                          SizedBox(height: SizeConfig.h(20)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(16),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isHistory
                                      ? 'Records for ${DateFormat('MMM d').format(_currentDate)}'
                                      : 'Today\'s Meals',
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(20),
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: SizeConfig.h(12)),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(16),
                            ),
                            child: _dailyNutrition!.meals.isEmpty
                                ? _buildEmptyMealsState(
                                    isDarkMode,
                                    _currentDate,
                                  )
                                : Column(
                                    children: _dailyNutrition!.meals
                                        .map(
                                          (meal) => EnhancedMealCard(
                                            meal: meal,
                                            onEdit: isHistory
                                                ? null
                                                : () {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Edit feature coming soon',
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            onDelete: isHistory
                                                ? null
                                                : () => _deleteMeal(meal.id),
                                            isDarkMode: isDarkMode,
                                            isHistory: isHistory,
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),

                          SizedBox(height: SizeConfig.h(100)),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGeneratePlanCapsule(bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenerateDietPage()),
        );
      },
      child: Container(
        width: double.infinity,
        height: SizeConfig.h(110),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)]
                : [const Color(0xFFE3F2FD), const Color(0xFF90CAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.auto_awesome,
                size: 120,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(SizeConfig.w(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "AI DIET PLANNER",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.blue[800],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Generate Your Plan",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    "Tailored to your goals",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
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

  Widget _buildQuickActions(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: "Log Meal",
              icon: Icons.add,
              color: Colors.blue,
              onTap: _showAddMealSheet,
              isDarkMode: isDarkMode,
            ),
          ),
          SizedBox(width: 12),

          Expanded(
            child: _buildActionButton(
              label: "Scan Food",
              icon: Icons.camera_alt_rounded,
              color: Colors.purple,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Scan to Log coming soon!")),
                );
              },
              isDarkMode: isDarkMode,
              isOutlined: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOutlined ? color.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealsState(bool isDarkMode, DateTime date) {
    bool isToday = _isSameDay(date, DateTime.now());
    bool isPast = date.isBefore(DateTime.now()) && !isToday;

    return Container(
      padding: EdgeInsets.all(SizeConfig.w(24)),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(SizeConfig.w(16)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: SizeConfig.w(48),
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
            SizedBox(height: SizeConfig.h(12)),
            Text(
              isPast
                  ? 'No meals were logged on this day'
                  : 'No meals logged yet',
              style: TextStyle(
                fontSize: SizeConfig.sp(16),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            if (isToday) ...[
              SizedBox(height: SizeConfig.h(6)),
              Text(
                'Tap "Add Meal" to get started',
                style: TextStyle(
                  fontSize: SizeConfig.sp(13),
                  color: isDarkMode ? Colors.white54 : Colors.black38,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
