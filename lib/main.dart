import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/home_page.dart';
import 'components/shared/bouncing_dots_indicator.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/register_page.dart';
import 'pages/startup_page.dart';
import 'utils/app_constants.dart';

import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassMorphismThemeProvider(
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.black,
            contentTextStyle: TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
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
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Colors.white,
            contentTextStyle: TextStyle(color: Colors.black),
            behavior: SnackBarBehavior.floating,
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
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    // Also watch profile to determine if onboarding is needed
    // We only care if auth is data (logged in).
    
    return authState.when(
      data: (user) {
        if (user != null) {
            // User is logged in, check profile
            // We use a separate FutureBuilder or watch the provider if it's available globally
            // Assuming userProfileProvider depends on auth, it should be available.
            
            // We need to return a widget that handles the profile check.
            return const ProfileCheckGate();
        }
        return const StartupPage();
      },
      loading: () => const Scaffold(
        body: Center(child: BouncingDotsIndicator()),
      ),
      error: (e, trace) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class ProfileCheckGate extends ConsumerWidget {
  const ProfileCheckGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile != null) {
          return const HomeScreen();
        } else {
          return OnboardingPage();
        }
      },
      loading: () => const Scaffold(body: Center(child: BouncingDotsIndicator())),
      error: (e, stack) => const Scaffold(body: Center(child: BouncingDotsIndicator())),
    );
  }
}
