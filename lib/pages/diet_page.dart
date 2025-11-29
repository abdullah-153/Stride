import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/diet/water_intake_card.dart';
import '../components/shared/circular_progress.dart';
import '../components/diet/enhanced_meal_card.dart';
import '../components/diet/macro_progress_bar.dart';
import '../components/diet/quick_add_meal_sheet.dart';
import '../components/diet/meal_history_calendar.dart';
import '../models/nutrition_model.dart';
import '../services/nutrition_service.dart';
import '../services/gamification_service.dart';
import '../models/gamification_model.dart';
import '../components/gamification/streak_card.dart';
import '../components/gamification/streak_celebration_overlay.dart';
import 'global_streak_success_page.dart';
import '../utils/size_config.dart';
import '../providers/theme_provider.dart';

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
          _dailyNutrition = nutrition;
          _isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addWater(int amount) async {
    await _nutritionService.logWater(amount);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+${amount}ml water logged',
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  Future<void> _deleteMeal(String mealId) async {
    await _nutritionService.deleteMeal(mealId);
    _loadData(_currentDate);
  }

  Future<void> _addMeal(Meal meal) async {
    // Create a new meal instance with current timestamp
    final newMeal = meal.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
    );

    await _nutritionService.logMeal(newMeal);

    if (mounted) {
      // Check if both streaks are completed today
      final gamificationService = GamificationService();
      final bothCompleted = gamificationService.areBothStreaksCompletedToday();
      
      if (bothCompleted) {
        // Show global streak success page
        final globalStreak = gamificationService.getCurrentData().stats.currentStreak;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GlobalStreakSuccessPage(
              globalStreak: globalStreak,
              themeColor: const Color(0xFF0EA5E9), // Blue for diet
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
      
      _loadData(_currentDate); // Refresh data
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
    final bg = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: textColor),
          onPressed: () => Navigator.maybePop(context),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
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

                        SizedBox(height: SizeConfig.h(24)),

                        // Gamification Section
                        StreamBuilder<GamificationData>(
                          stream: GamificationService().gamificationStream,
                          initialData: GamificationService().getCurrentData(),
                          builder: (context, snapshot) {
                            final data = snapshot.data!;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.w(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StreakCard(
                                          streakDays: data.stats.dietStreak,
                                          isDarkMode: isDarkMode,
                                          title: 'Diet Streak',
                                          icon: Icons.restaurant_menu_rounded,
                                          gradientColors: isDarkMode
                                              ? [
                                                  const Color(0xFF11998E),
                                                  const Color(0xFF38EF7D)
                                                ]
                                              : [
                                                  const Color(0xFF56AB2F),
                                                  const Color(0xFFA8E063)
                                                ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // LevelProgressCard moved to ProfilePage
                                ],
                              ),
                            );
                          },
                        ),

                        SizedBox(height: SizeConfig.h(24)),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(16),
                          ),
                          child: WaterIntakeSliderCard(isDarkMode: isDarkMode),
                        ),

                        SizedBox(height: SizeConfig.h(16)),

                        _buildNutritionDashboard(isDarkMode),

                        SizedBox(height: SizeConfig.h(24)),

                        MealHistoryCalendar(
                          isDarkMode: isDarkMode,
                          selectedDate: _currentDate,
                          onDateSelected: (date) => _loadData(date),
                        ),

                        SizedBox(height: SizeConfig.h(20)),

                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.w(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isSameDay(_currentDate, DateTime.now())
                                    ? 'Today\'s Meals'
                                    : 'Meals for ${DateFormat('MMM d').format(_currentDate)}',
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(20),
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              if (_isSameDay(_currentDate, DateTime.now()))
                                TextButton.icon(
                                  onPressed: _showAddMealSheet,
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    size: SizeConfig.w(20),
                                    color: Colors.blue,
                                  ),
                                  label: Text(
                                    'Add Meal',
                                    style: TextStyle(
                                      fontSize: SizeConfig.sp(14),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
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
                              ? _buildEmptyMealsState(isDarkMode)
                              : Column(
                                  children: _dailyNutrition!.meals
                                      .map(
                                        (meal) => EnhancedMealCard(
                                          meal: meal,
                                          onEdit: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Edit feature coming soon',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: Colors.black,
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          onDelete: () => _deleteMeal(meal.id),
                                          isDarkMode: isDarkMode,
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

  Widget _buildNutritionDashboard(bool isDarkMode) {
    final cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    final macroColor = isDarkMode ? Colors.blue : Colors.black;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
      padding: EdgeInsets.all(SizeConfig.w(16)),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(SizeConfig.w(20)),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Nutrition',
            style: TextStyle(
              fontSize: SizeConfig.sp(18),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          SizedBox(height: SizeConfig.h(12)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DietCircularProgress(
                totalKcal: _dailyNutrition!.goal.dailyCalories.toDouble(),
                consumedKcal: _dailyNutrition!.totalCalories.toDouble(),
                burnedKcal: 0,
                isDarkMode: isDarkMode,
                diameter: SizeConfig.w(140),
              ),
              SizedBox(width: SizeConfig.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${_dailyNutrition!.totalCalories}',
                          style: TextStyle(
                            fontSize: SizeConfig.sp(26),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(4)),
                        Flexible(
                          child: Text(
                            '/ ${_dailyNutrition!.goal.dailyCalories} kcal',
                            style: TextStyle(
                              fontSize: SizeConfig.sp(13),
                              fontWeight: FontWeight.w500,
                              color: subTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.h(6)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(8),
                        vertical: SizeConfig.h(3),
                      ),
                      decoration: BoxDecoration(
                        color: _dailyNutrition!.calorieGoalMet
                            ? Colors.blue.withOpacity(0.15)
                            : (isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05)),
                        borderRadius: BorderRadius.circular(SizeConfig.w(6)),
                      ),
                      child: Text(
                        _dailyNutrition!.calorieGoalMet
                            ? 'On Track'
                            : 'Keep Going',
                        style: TextStyle(
                          fontSize: SizeConfig.sp(11),
                          fontWeight: FontWeight.w600,
                          color: _dailyNutrition!.calorieGoalMet
                              ? Colors.blue
                              : subTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(16)),

          MacroProgressBar(
            label: 'Protein',
            current: _dailyNutrition!.totalMacros.protein,
            goal: _dailyNutrition!.goal.protein,
            color: macroColor,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(10)),
          MacroProgressBar(
            label: 'Carbs',
            current: _dailyNutrition!.totalMacros.carbs,
            goal: _dailyNutrition!.goal.carbs,
            color: macroColor,
            isDarkMode: isDarkMode,
          ),
          SizedBox(height: SizeConfig.h(10)),
          MacroProgressBar(
            label: 'Fats',
            current: _dailyNutrition!.totalMacros.fats,
            goal: _dailyNutrition!.goal.fats,
            color: macroColor,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMealsState(bool isDarkMode) {
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
              'No meals logged yet',
              style: TextStyle(
                fontSize: SizeConfig.sp(16),
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: SizeConfig.h(6)),
            Text(
              'Tap "Add Meal" to get started',
              style: TextStyle(
                fontSize: SizeConfig.sp(13),
                color: isDarkMode ? Colors.white54 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
