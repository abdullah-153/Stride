import 'package:flutter/material.dart';
import '../../models/nutrition_model.dart';
import '../../services/nutrition_service.dart';
import '../../utils/size_config.dart';

class QuickAddMealSheet extends StatefulWidget {
  final Function(Meal) onMealSelected;
  final bool isDarkMode;

  const QuickAddMealSheet({
    super.key,
    required this.onMealSelected,
    this.isDarkMode = false,
  });

  @override
  State<QuickAddMealSheet> createState() => _QuickAddMealSheetState();
}

class _QuickAddMealSheetState extends State<QuickAddMealSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NutritionService _nutritionService = NutritionService();

  List<Meal> _recentMeals = [];
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final recent = await _nutritionService.getRecentMeals();
    final favorites = await _nutritionService.getFavoriteMeals();

    if (mounted) {
      setState(() {
        _recentMeals = recent;
        _favoriteMeals = favorites;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final indicatorColor = Colors.blue;

    return Container(
      height: SizeConfig.h(600),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          SizedBox(height: SizeConfig.h(12)),
          Container(
            width: SizeConfig.w(40),
            height: SizeConfig.h(4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: SizeConfig.h(16)),

          TabBar(
            controller: _tabController,
            labelColor: indicatorColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: indicatorColor,
            tabs: const [
              Tab(text: 'Recent'),
              Tab(text: 'Favorites'),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMealList(_recentMeals),
                      _buildMealList(_favoriteMeals, isFavorites: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(List<Meal> meals, {bool isFavorites = false}) {
    if (meals.isEmpty) {
      return Center(
        child: Text(
          isFavorites ? 'No favorites yet' : 'No recent meals',
          style: TextStyle(color: Colors.grey, fontSize: SizeConfig.sp(16)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildMealItem(meal);
      },
    );
  }

  Widget _buildMealItem(Meal meal) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
    final cardBg = widget.isDarkMode
        ? const Color(0xFF2C2C2E)
        : Colors.grey.shade50;

    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(12)),
      child: InkWell(
        onTap: () => widget.onMealSelected(meal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(SizeConfig.w(12)),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: SizeConfig.w(48),
                height: SizeConfig.w(48),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Colors.blue,
                  size: SizeConfig.w(24),
                ),
              ),
              SizedBox(width: SizeConfig.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(16),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(4)),
                    Text(
                      '${meal.calories} kcal • ${meal.macros.protein}g P • ${meal.macros.carbs}g C • ${meal.macros.fats}g F',
                      style: TextStyle(
                        fontSize: SizeConfig.sp(12),
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                color: Colors.blue,
                size: SizeConfig.w(24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
