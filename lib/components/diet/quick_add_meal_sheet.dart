import 'package:flutter/material.dart';
import '../../models/nutrition_model.dart';
import '../../services/nutrition_service.dart';
import '../../services/meal_service.dart';
import '../../services/user_profile_service.dart';
import '../../utils/size_config.dart';
import '../shared/bouncing_dots_indicator.dart';

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
  final MealService _mealService = MealService();
  final UserProfileService _userProfileService = UserProfileService();

  List<Meal> _recommendedMeals = [];
  List<Meal> _recentMeals = [];
  List<Meal> _favoriteMeals = [];
  List<Meal> _searchResults = [];
  List<String> _suggestions = []; // Autocomplete suggestions
  bool _isLoading = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Increased to 4
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadMeals(),
      _loadRecommendedMeals(),
    ]);
  }

  Future<void> _loadRecommendedMeals() async {
    try {
      final profile = await _userProfileService.loadProfile();
      if (profile.activeDietPlan != null && profile.activeDietPlan!.weeklyPlan.isNotEmpty) {
        // Calculate day index (0 for Monday, etc.) based on week of plan
        // Simply cycling through plan days based on actual weekday
        // Weekday 1 (Mon) -> Index 0
        final dayIndex = (DateTime.now().weekday - 1) % profile.activeDietPlan!.weeklyPlan.length;
        final dailyPlan = profile.activeDietPlan!.weeklyPlan[dayIndex];
        
        final meals = dailyPlan.meals.map((item) {
          return Meal(
            id: 'rec_${DateTime.now().millisecondsSinceEpoch}_${item.name.hashCode}',
            name: item.name,
            type: _mapMealType(item.type),
            calories: item.calories,
            macros: MacroNutrients(
              protein: item.macros.protein,
              carbs: item.macros.carbs,
              fats: item.macros.fats,
            ),
            timestamp: DateTime.now(),
          );
        }).toList();

        if (mounted) {
          setState(() {
            _recommendedMeals = meals;
          });
        }
      }
    } catch (e) {
      print('Error loading recommended meals: $e');
    }
  }

  MealType _mapMealType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'breakfast': return MealType.breakfast;
      case 'lunch': return MealType.lunch;
      case 'dinner': return MealType.dinner;
      case 'snack': return MealType.snack;
      default: return MealType.snack;
    }
  }

  Future<void> _loadMeals() async {
    final recentMaps = await _mealService.getRecentMeals();
    final favoriteMaps = await _mealService.getSavedMeals();

    if (mounted) {
      setState(() {
        _recentMeals = recentMaps.map((data) => Meal.fromJson(data)).toList();
        _favoriteMeals = favoriteMaps.map((data) => Meal.fromJson(data)).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) setState(() => _suggestions = []);
      return;
    }

    try {
      final suggestions = await _mealService.getAutocompleteSuggestions(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> _searchMeals(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _suggestions = [];
        });
      }
      return;
    }

    // Clear suggestions when starting a real search
    if (mounted) {
      setState(() {
        _isSearching = true;
        _suggestions = []; 
      });
    }

    try {
      final results = await _mealService.searchMeals(query);
      if (mounted) {
        setState(() {
          _searchResults = results.map((data) => Meal.fromJson(data)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching meals: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.only(left: SizeConfig.w(16), right: SizeConfig.w(16)),
            tabs: const [
              Tab(text: 'Recommended'),
              Tab(text: 'Recent'),
              Tab(text: 'Favorites'),
              Tab(text: 'Search'),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: BouncingDotsIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMealList(_recommendedMeals, emptyMessage: "No plan active. Generate one!"),
                      _buildMealList(_recentMeals, emptyMessage: "No recent meals"),
                      _buildMealList(_favoriteMeals, emptyMessage: "No favorites yet"),
                      _buildSearchTab(textColor),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(Color textColor) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.w(16)),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(color: textColor),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => _searchMeals(value),
            onChanged: (value) {
              // Debounce suggestions
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                if (_searchController.text == value) {
                   if (value.isEmpty) {
                     setState(() => _suggestions = []);
                   } else {
                     _fetchSuggestions(value);
                   }
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'Search for food...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: widget.isDarkMode ? Colors.black12 : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(height: SizeConfig.h(20)),
          
          Expanded(
            child: _suggestions.isNotEmpty
                ? ListView.separated(
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        leading: const Icon(Icons.search, color: Colors.grey, size: 20),
                        title: Text(
                          suggestion,
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                        onTap: () {
                          _searchController.text = suggestion;
                          _searchMeals(suggestion);
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  )
                : _isSearching
                    ? const Center(child: BouncingDotsIndicator())
                    : _searchResults.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? "Start typing to search..."
                                  : "No results found",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return _buildMealItem(_searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(List<Meal> meals, {String emptyMessage = 'No meals found'}) {
    if (meals.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
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
                        fontSize: SizeConfig.sp(15),
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
