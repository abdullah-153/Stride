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
import '../components/common/global_back_button.dart'; // Added import
import 'level_up_page.dart';
import '../utils/size_config.dart';
import '../providers/theme_provider.dart';
import 'package:flutter/services.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'generate_diet_page.dart'; // Import the generator page

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
          // If null (no data for today), show empty state instead of "No data" text
          _dailyNutrition = nutrition ?? DailyNutrition(
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
          // Fallback to empty state on error too, so UI doesn't break
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

  Future<void> _addWater(int amount) async {
    HapticFeedback.lightImpact();
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
    HapticFeedback.mediumImpact();
    await _nutritionService.deleteMeal(_currentDate, mealId);
    _loadData(_currentDate);
  }

  Future<void> _addMeal(Meal meal) async {
    // Create a new meal instance with current timestamp
    final newMeal = meal.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
    );

    // Check if this is the first meal of the day BEFORE logging
    final gamificationService = GamificationService();
    final isFirstMealOfDay = await gamificationService.isFirstOfDayForType(StreakType.diet);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: BouncingDotsIndicator(color: Colors.white),
      ),
    );

    await _nutritionService.logMeal(newMeal);
    
    if (mounted) Navigator.pop(context); // Dismiss loading

    // Set up level up callback
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

    // Add XP for meal logging
    final leveledUp = await gamificationService.addXp(25);

    if (mounted && !leveledUp) {
      if (isFirstMealOfDay) {
        final bothCompleted = await gamificationService.areBothStreaksCompletedToday();
        final data = await gamificationService.getCurrentData();
        final stats = data.stats;
        
        // Show streak page for either Global or just Diet streak
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GlobalStreakSuccessPage(
              // If both completed, show global streak, otherwise show diet streak
              globalStreak: bothCompleted ? stats.currentStreak : stats.dietStreak,
              themeColor: const Color(0xFF0EA5E9),
              title: bothCompleted ? 'Perfect Day!' : 'Nutrition Streak!',
              subtitle: bothCompleted 
                  ? 'You completed both workout and diet goals today'
                  : 'Healthy eating streak kept alive! Great job!',
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        // Show simple snackbar for subsequent meals
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
        leading: GlobalBackButton(
          isDark: isDarkMode,
          onPressed: () => Navigator.maybePop(context),
        ),
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
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
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
                                          currentLevel: data.stats.currentLevel,
                                          currentXp: data.stats.currentXp,
                                          nextLevelXp: GamificationService().getXpForNextLevel(data.stats.currentLevel),
                                          gradientColors: isDarkMode
                                              ? [
                                                  Colors.black,
                                                  const Color(0xFF1A1A1A), // Dark grey
                                                  const Color(0xFF0EA5E9), // Blue accent
                                                ]
                                              : [
                                                  Colors.white,
                                                  const Color(0xFFF5F5F5), // Light grey
                                                  const Color(0xFF0EA5E9), // Blue accent
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
                          child: _buildGeneratePlanCapsule(isDarkMode),
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
                          minDate: FirebaseAuth.instance.currentUser?.metadata.creationTime,
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
        height: SizeConfig.h(120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.w(24)),
           gradient: LinearGradient(
              colors: isDarkMode
                ? [const Color(0xFF1E3A8A), const Color(0xFF1E40AF)] // Deep Blue
                : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)], // Light Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
           ),
           border: Border.all(
              color: isDarkMode ? Colors.blueAccent.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
              width: 1,
           ),
           boxShadow: [
              BoxShadow(
                  color: Colors.blue.withOpacity(isDarkMode ? 0.2 : 0.05),
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
                Icons.auto_awesome,
                size: SizeConfig.w(140),
                color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.1),
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
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                    "AI POWERED",
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Create a Plan",
                              style: TextStyle(
                                fontSize: SizeConfig.sp(20), 
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87
                              ),
                            ),
                            Text(
                              "Tailored to your body & goals",
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
                        color: isDarkMode ? Colors.black26 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward, color: isDarkMode ? Colors.white : Colors.blue),
                    )
                 ],
               ),
            ),
          ],
        ),
      ),
    );
  }
}
