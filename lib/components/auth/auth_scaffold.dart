import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import 'animated_background.dart';
import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter_glass_morphism/flutter_glass_morphism.dart';

enum AuthFlow { login, register, forgotPassword, otp }

class AuthScaffold extends StatelessWidget {
  final AuthFlow flow;
  final Widget body;
  final String title;
  final String subtitle;
  final bool showBackButton;
  final bool isFullPage;
  final bool isLoading; // New prop for validation state
  final int currentStep;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    required this.flow,
    required this.body,
    this.title = '',
    this.subtitle = '',
    this.showBackButton = true,
    this.isFullPage = false,
    this.isLoading = false,
    this.currentStep = 0,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final double headerHeight = SizeConfig.h(200);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(
              stepIndex: currentStep,
              isLoading: isLoading,
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ), // Increased blur for better separation
              child: Container(color: Colors.transparent),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              top: false, // Handle padding manually inside for full control
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).padding.top +
                        (isFullPage ? SizeConfig.h(20) : SizeConfig.h(60)),
                  ),

                  if (title.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(24),
                      ),
                      child: Column(
                        crossAxisAlignment: isFullPage
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            textAlign: isFullPage
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                              fontSize: SizeConfig.sp(32),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(8)),
                          Text(
                            subtitle,
                            textAlign: isFullPage
                                ? TextAlign.center
                                : TextAlign.start,
                            style: TextStyle(
                              fontSize: SizeConfig.sp(16),
                              color: Colors.grey[800],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.h(30)),
                  ],

                  Expanded(child: body),
                ],
              ),
            ),
          ),

          if (showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + SizeConfig.h(10),
              left: SizeConfig.w(20),
              child: GlassMorphismButton(
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                style: GlassMorphismButtonStyle(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  blurIntensity: 10,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
