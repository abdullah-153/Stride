import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/register_page.dart';
import 'pages/startup_page.dart';
import 'utils/app_constants.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.orange,
          surface: AppColors.darkSurface,
        ),
      ),
      themeMode: ThemeMode.system,
      routes: {
        AppRoutes.startup: (context) => const StartupPage(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.onboarding: (context) => OnboardingPage(),
      },
      home: const HomeScreen(),
    );
  }
}
