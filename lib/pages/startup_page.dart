import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_constants.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(
      const AssetImage('lib/assets/images/startup_page_vector.jpg'),
      context,
    );
  }

  void signInButtonAction(context) =>
      Navigator.pushNamed(context, AppRoutes.login);
  void registerButtonAction(context) =>
      Navigator.pushNamed(context, AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent, // navigation bar color
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        children: [
                          SizedBox(height: height * 0.04),

                          Center(
                            child: Image.asset(
                              'lib/assets/images/startup_page_vector.jpg',
                              width: width * 0.8,
                              height: width * 0.8,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: height * 0.07),

                          Text(
                            "Ready to Train?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: width * 0.09,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.015,
                            ),
                            child: Text(
                              "Track your workouts, build consistency, and achieve your fitness goals Ã¢â‚¬â€ all in one place.",
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: width * 0.04,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: height * 0.05),

                          ElevatedButton(
                            onPressed: () => signInButtonAction(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: Size(width * 0.65, height * 0.08),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.02),

                          ElevatedButton(
                            onPressed: () => registerButtonAction(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                146,
                                146,
                                146,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize: Size(width * 0.65, height * 0.08),
                            ),
                            child: Text(
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.05),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05,
                            ),
                            child: Text(
                              "By signing up, you agree to our Terms of Service and Privacy Policy.",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 179, 179, 179),
                                fontSize: width * 0.03,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
