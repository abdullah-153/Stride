import 'package:flutter/material.dart';
import '../../components/shared/digit_box.dart';
import '../../utils/size_config.dart';
import '../onboarding_page.dart';

class AgePage extends StatefulWidget {
  const AgePage({super.key});

  @override
  State<AgePage> createState() => AgePageState();
}

class AgePageState extends State<AgePage> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(
    initialItem: 0,
  );
  int selectedAgeIndex = 0;

  final List<int> ageList = List.generate(88, (i) => i + 13);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.screenWidth * 0.07,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.02),

              Text(
                "What's your age?",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.09,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 255, 119, 0),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              Expanded(
                child: Center(
                  child: ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: SizeConfig.screenHeight * 0.25,
                    diameterRatio: 2.5,
                    onSelectedItemChanged: (index) {
                      setState(() => selectedAgeIndex = index);
                    },
                    physics: const FixedExtentScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: ageList.length,
                      builder: (context, index) {
                        return DigitBox(
                          digit: ageList[index].toString(),
                          isSelected: index == selectedAgeIndex,
                        );
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final onboardingState = context
                        .findAncestorStateOfType<OnboardingPageState>();

                    if (onboardingState != null) {
                      onboardingState.updateAge(ageList[selectedAgeIndex]);
                      onboardingState.goToNext();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 119, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: SizeConfig.screenWidth * 0.08,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.screenHeight * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
