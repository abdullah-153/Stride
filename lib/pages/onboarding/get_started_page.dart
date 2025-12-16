import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import '../onboarding_page.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  final Color themeColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    final userName = "there";

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
              Text(
                "Hi, $userName",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.1,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Answer a few quick questions so we can tailor your journey.",
                style: TextStyle(
                  fontSize: SizeConfig.screenWidth * 0.055,
                  color: const Color.fromARGB(255, 126, 126, 126),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              Center(
                child: SizedBox(
                  height: SizeConfig.screenHeight * 0.25,
                  width: SizeConfig.screenWidth * 1.3,
                  child: Image.asset(
                    'lib/assets/images/onboarding_page_vector.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.05),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .findAncestorStateOfType<OnboardingPageState>()
                        ?.goToNext();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    backgroundColor: themeColor,
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
