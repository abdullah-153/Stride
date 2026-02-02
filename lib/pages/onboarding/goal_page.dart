import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/size_config.dart';
import '../../utils/app_constants.dart';
import '../../models/user_profile_model.dart';
import '../../providers/user_profile_provider.dart';

class GoalPage extends ConsumerStatefulWidget {
  final int selectedAge;
  final String selectedGender;
  final double selectedHeight;
  final double selectedWeight;
  final String selectedFitnessLevel;

  const GoalPage({
    super.key,
    required this.selectedAge,
    required this.selectedGender,
    required this.selectedHeight,
    required this.selectedWeight,
    required this.selectedFitnessLevel,
  });

  @override
  ConsumerState<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends ConsumerState<GoalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final name = user?.displayName ?? 'User';

      final newProfile = UserProfile(
        name: name,
        age: widget.selectedAge,
        gender: widget.selectedGender,
        height: widget.selectedHeight,
        weight: widget.selectedWeight,
        bio: widget.selectedFitnessLevel,
        weeklyWorkoutGoal: 4,
        dailyCalorieGoal: 2000,
      );

      await ref.read(userProfileProvider.notifier).updateProfile(newProfile);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final isMale = widget.selectedGender.toLowerCase() == 'male';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: -SizeConfig.screenHeight * 0.1,
            right: -SizeConfig.screenWidth * 0.2,
            child: Container(
              width: SizeConfig.screenWidth * 0.8,
              height: SizeConfig.screenWidth * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGreen.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.h(40)),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "YOU'RE ALL SET!",
                          style: TextStyle(
                            fontSize: SizeConfig.sp(14),
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGreen,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(10)),
                        Text(
                          "Your Personalized\nPlan is Ready",
                          style: TextStyle(
                            fontSize: SizeConfig.sp(32),
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: SizeConfig.h(40)),

                  SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(SizeConfig.w(24)),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PROFILE SUMMARY",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(12),
                              fontWeight: FontWeight.w700,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(20)),

                          Row(
                            children: [
                              _buildStatItem(
                                icon: isMale ? Icons.male : Icons.female,
                                value: widget.selectedGender,
                                label: "Gender",
                              ),
                              _buildDivider(),
                              _buildStatItem(
                                icon: Icons.cake_outlined,
                                value: "${widget.selectedAge}",
                                label: "Age",
                              ),
                            ],
                          ),
                          SizedBox(height: SizeConfig.h(20)),
                          Row(
                            children: [
                              _buildStatItem(
                                icon: Icons.height,
                                value: "${widget.selectedHeight.toInt()} cm",
                                label: "Height",
                              ),
                              _buildDivider(),
                              _buildStatItem(
                                icon: Icons.monitor_weight_outlined,
                                value: "${widget.selectedWeight.toInt()} kg",
                                label: "Weight",
                              ),
                            ],
                          ),

                          SizedBox(height: SizeConfig.h(24)),
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          SizedBox(height: SizeConfig.h(24)),

                          Text(
                            "FITNESS LEVEL",
                            style: TextStyle(
                              fontSize: SizeConfig.sp(12),
                              fontWeight: FontWeight.w700,
                              color: Colors.white54,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(12)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.w(16),
                              vertical: SizeConfig.h(12),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.accentGreen.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fitness_center,
                                  color: AppColors.accentGreen,
                                  size: SizeConfig.sp(18),
                                ),
                                SizedBox(width: SizeConfig.w(8)),
                                Text(
                                  widget.selectedFitnessLevel,
                                  style: TextStyle(
                                    fontSize: SizeConfig.sp(16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      height: SizeConfig.h(56),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Let's Get Started",
                                style: TextStyle(
                                  fontSize: SizeConfig.sp(16),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(10)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white70, size: SizeConfig.sp(20)),
          ),
          SizedBox(width: SizeConfig.w(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: SizeConfig.sp(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: SizeConfig.sp(12),
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: SizeConfig.h(40),
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.symmetric(horizontal: SizeConfig.w(8)),
    );
  }
}
