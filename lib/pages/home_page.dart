import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/home/home_page_content.dart';
import '../components/shared/navbar.dart';
import '../pages/diet_page.dart';
import '../pages/profile_page.dart';
import '../pages/workout_page.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';
import '../utils/size_config.dart';

/// Main home screen with navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _navigationHistory = [0];
  bool _isInitialPage = true;

  final List<Color> _pageColors = const [
    AppColors.navHome,
    AppColors.navWorkout,
    AppColors.navDiet,
    AppColors.navProfile,
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onNavBarTap(int index) {
    if (_currentIndex == index) return;

    if (_isInitialPage) {
      _isInitialPage = false;
    }

    setState(() {
      _currentIndex = index;

      // Remove the current page from history if it exists to prevent circular navigation
      // This prevents: Workout -> Diet -> Workout (back) -> Diet (back) -> Workout
      // Instead: Workout -> Diet -> Workout (back) -> goes to Home
      if (_navigationHistory.contains(index)) {
        _navigationHistory.remove(index);
      }

      _navigationHistory.add(index);
    });
  }

  void navigateToPage(int index) {
    _onNavBarTap(index);
  }

  Future<bool> _onWillPop() async {
    if (_isInitialPage) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.startup, (route) => false);
      return false;
    }

    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast();
      final previousIndex = _navigationHistory.last;
      setState(() {
        _currentIndex = previousIndex;
      });
      return false;
    } else {
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.logout),
          content: const Text(AppStrings.logoutConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.logout),
            ),
          ],
        ),
      );

      if (shouldLogout ?? false) {
        await ref.read(authServiceProvider).signOut(); // Perform actual logout
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.startup, (route) => false);
        }
      }

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    // Use global theme provider
    final isDarkMode = ref.watch(themeProvider);

    final List<Widget> pages = [
      HomePageContent(
        isDarkMode: isDarkMode,
        onThemeChanged: (value) =>
            ref.read(themeProvider.notifier).setTheme(value),
        onNavigate: navigateToPage,
      ),
      DietPage(),
      WorkoutPage(),
      const ProfilePage(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
          body: Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: IndexedStack(index: _currentIndex, children: pages),
                ),
              ),
              FloatingNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavBarTap,
                pageColors: _pageColors,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
