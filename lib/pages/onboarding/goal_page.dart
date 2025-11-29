import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../../utils/app_constants.dart';

class GoalPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth * 0.08,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You're all set!",
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.015),
            Text(
              "Let's head to your home page.",
              style: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.05,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.07),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: SizeConfig.screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
