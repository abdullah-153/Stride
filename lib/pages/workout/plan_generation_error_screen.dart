import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../utils/size_config.dart';

class PlanGenerationErrorScreen extends ConsumerWidget {
  final VoidCallback onRetry;
  final String? errorMessage;

  const PlanGenerationErrorScreen({
    super.key,
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = const Color(0xFFCEF24B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.w(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: SizeConfig.w(120),
                height: SizeConfig.w(120),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: SizeConfig.w(60),
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: SizeConfig.h(32)),

              Text(
                "Trainer Offline",
                style: TextStyle(
                  fontSize: SizeConfig.sp(28),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: SizeConfig.h(16)),

              Text(
                "Our AI coach needs an internet connection to design your perfect plan. Please check your signal and try again.\n\n(Error: ${errorMessage ?? 'Unknown'})",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.sp(16),
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),

              SizedBox(height: SizeConfig.h(48)),

              SizedBox(
                width: double.infinity,
                height: SizeConfig.h(56),
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Retry Connection",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.h(16)),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Go Back",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
