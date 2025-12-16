import 'package:flutter/material.dart';
import '../services/ai_diet_service.dart';
import '../models/diet_plan_model.dart';
import 'generated_diet_plan_page.dart';
import '../utils/size_config.dart';
import '../components/auth/auth_glass_card.dart';
import '../components/diet/premium_slider.dart';
import '../components/diet/premium_selector.dart';
import '../components/shared/bouncing_dots_indicator.dart';
import '../components/common/global_back_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class GenerateDietPage extends ConsumerStatefulWidget {
  const GenerateDietPage({super.key});

  @override
  ConsumerState<GenerateDietPage> createState() => _GenerateDietPageState();
}

class _GenerateDietPageState extends ConsumerState<GenerateDietPage> with SingleTickerProviderStateMixin {
  final AIDietService _aiService = AIDietService();
  bool _isLoading = false;
  late AnimationController _animationController;

  // Form State
  int _currentWeight = 70;
  int _targetWeight = 70;
  int _height = 175;
  int _age = 25;
  String _gender = 'Male';
  String _goal = 'Maintain';
  String _activityLevel = 'Moderate';
  String _region = 'Western';
  int _mealsPerDay = 3;
  
  final List<String> _selectedRestrictions = [];
  final TextEditingController _allergiesController = TextEditingController();

  final List<String> _availableRestrictions = [
    'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Gluten-Free', 'Dairy-Free', 'Halal', 'Kosher'
  ];

  final List<String> _regions = [
    'Western', 'Asian', 'Pakistani', 'Mediterranean', 'Indian', 'Latin American', 'Middle Eastern'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
    
    // Pre-fill data from profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfileState = ref.read(userProfileProvider);
      if (userProfileState.hasValue) {
        final profile = userProfileState.value!;
        setState(() {
          _age = profile.age;
          _height = profile.height.round();
          _currentWeight = profile.weight.round();
          _targetWeight = profile.weight.round(); // Default to current
          _gender = profile.gender; // Fetch gender
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white, // Pure black/white
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GlobalBackButton(isDark: isDarkMode, onPressed: () => Navigator.pop(context)),
        // title removed
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background ambient elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(isDarkMode ? 0.05 : 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, SizeConfig.h(100), 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 _buildAnimatedSection(0, _buildSectionTitle('Goal', isDarkMode)),
                 _buildAnimatedSection(1, _buildGoalSelector(isDarkMode)),
                 const SizedBox(height: 30),
                 
                 _buildAnimatedSection(2, _buildSectionTitle('Biometrics', isDarkMode)),
                 _buildAnimatedSection(3, AuthGlassCard(
                   child: Column(
                     children: [
                       // 1. Read-Only Personal Data Summary (Premium Look)
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
                         ),
                         child: Column(
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 _buildBiometricItem(Icons.person, _gender, "Gender", isDarkMode),
                                 _buildVerticalDivider(isDarkMode),
                                 _buildBiometricItem(Icons.cake, "$_age", "Age", isDarkMode),
                               ],
                             ),
                             const SizedBox(height: 16),
                             Divider(color: isDarkMode ? Colors.white10 : Colors.black12, height: 1),
                             const SizedBox(height: 16),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 _buildBiometricItem(Icons.height, "$_height cm", "Height", isDarkMode),
                                 _buildVerticalDivider(isDarkMode),
                                 _buildBiometricItem(Icons.monitor_weight, "$_currentWeight kg", "Current", isDarkMode),
                               ],
                             ),
                             const SizedBox(height: 12),
                             // Info Note
                             Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.lock_outline_rounded, size: 12, color: isDarkMode ? Colors.white38 : Colors.black38),
                                 const SizedBox(width: 4),
                                 Text(
                                   "Synced from your profile", 
                                   style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white38 : Colors.black38),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       
                       const SizedBox(height: 24),
                       
                       // 2. Editable Target Weight
                       PremiumSlider(
                         label: 'Target Weight',
                         value: _targetWeight.toDouble(),
                         min: 40,
                         max: 150,
                         onChanged: (v) => setState(() => _targetWeight = v.toInt()),
                         unit: ' kg',
                         isDarkMode: isDarkMode,
                       ),
                       
                       const SizedBox(height: 24),

                       // 3. Meals Per Day
                       PremiumSelector<int>(
                         label: 'Meals Per Day',
                         items: const [3, 4, 5, 6],
                         selectedValue: _mealsPerDay,
                         onSelected: (v) => setState(() => _mealsPerDay = v),
                         itemLabelBuilder: (v) => "$v Meals",
                         isDarkMode: isDarkMode,
                       ),
                       
                       const SizedBox(height: 24),
                       
                       // 4. Activity Level
                       PremiumSelector<String>(
                         label: 'Activity Level',
                         items: const ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'],
                         selectedValue: _activityLevel,
                         onSelected: (v) => setState(() => _activityLevel = v),
                         itemLabelBuilder: (v) => v,
                         isDarkMode: isDarkMode,
                       ),
                     ],
                   ),
                 )),
                 
                 const SizedBox(height: 30),
                 _buildAnimatedSection(4, _buildSectionTitle('Cuisine', isDarkMode)),
                 _buildAnimatedSection(5, AuthGlassCard(
                   child: PremiumSelector<String>(
                     label: 'Preferred Region',
                     items: _regions,
                     selectedValue: _region,
                     onSelected: (v) => setState(() => _region = v),
                     itemLabelBuilder: (v) => v,
                     isDarkMode: isDarkMode,
                  ),
                 )),
                 
                 const SizedBox(height: 30),
                 _buildAnimatedSection(6, _buildSectionTitle('Dietary Restrictions', isDarkMode)),
                 _buildAnimatedSection(7, _buildRestrictionsChips(isDarkMode)),
                
                 const SizedBox(height: 30),
                 _buildAnimatedSection(8, _buildSectionTitle('Allergies', isDarkMode)),
                 _buildAnimatedSection(9, _buildAllergiesInput(isDarkMode)),
                
                 const SizedBox(height: 40),
                 _buildAnimatedSection(10, _buildGenerateButton(isDarkMode)),
                 const SizedBox(height: 20),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BouncingDotsIndicator(color: Colors.blueAccent),
                    const SizedBox(height: 20),
                    Text(
                      "Designing your plan...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.05, 1.0, curve: Curves.easeOut),
          ),
        ),
        child: child,
      ),
    );
  }

  Future<void> _generateDietPlan() async {
    setState(() => _isLoading = true);
    try {
        final plan = await _aiService.generateDietPlan(
          currentWeight: _currentWeight,
          targetWeight: _targetWeight,
          height: _height,
          age: _age,
          gender: _gender,
          goal: _goal,
          activityLevel: _activityLevel,
          region: _region,
          dietaryRestrictions: _selectedRestrictions,
          allergies: _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          mealsPerDay: _mealsPerDay
        );
        
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GeneratedDietPlanPage(dietPlan: plan)),
        );
    } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
        if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGoalSelector(bool isDarkMode) {
    final goals = [
      {'label': 'Lose Fat', 'icon': Icons.local_fire_department_rounded},
      {'label': 'Maintain', 'icon': Icons.balance_rounded},
      {'label': 'Build Muscle', 'icon': Icons.fitness_center_rounded},
    ];
    
    return Row(
      children: goals.map((g) {
        final label = g['label'] as String;
        final icon = g['icon'] as IconData;
        final isSelected = _goal == label;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _goal = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(
                      colors: [Colors.blueAccent.shade400, Colors.blueAccent.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                color: isSelected ? null : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] 
                  : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                border: Border.all(color: isSelected ? Colors.transparent : (isDarkMode ? Colors.white10 : Colors.black12)),
              ),
              child: Column(
                children: [
                  Icon(icon, color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black54)),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRestrictionsChips(bool isDarkMode) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableRestrictions.map((r) {
        final isSelected = _selectedRestrictions.contains(r);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected ? _selectedRestrictions.remove(r) : _selectedRestrictions.add(r);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent.withOpacity(0.2) : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : (isDarkMode ? Colors.white12 : Colors.black12),
                width: 1.5
              ),
            ),
            child: Text(
              r,
              style: TextStyle(
                color: isSelected ? Colors.blueAccent : (isDarkMode ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergiesInput(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.transparent),
      ),
      child: TextField(
        controller: _allergiesController,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: "E.g. Peanuts, Shellfish...",
          hintStyle: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38),
          border: InputBorder.none,
          icon: Icon(Icons.warning_amber_rounded, color: isDarkMode ? Colors.white30 : Colors.black38),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateDietPlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
               colors: [Colors.blueAccent.shade400, Colors.blueAccent.shade700],
               begin: Alignment.centerLeft,
               end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'GENERATE PLAN',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDarkMode) {
    return Container(
      height: 30,
      width: 1,
      color: isDarkMode ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildBiometricItem(IconData icon, String value, String label, bool isDarkMode) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
