import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import 'bouncing_dots_indicator.dart';

class AuthNavigationButtons extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback? onGoogleSignIn;
  final bool isLoading;
  final String continueLabel;

  const AuthNavigationButtons({
    super.key,
    required this.onContinue,
    this.onGoogleSignIn,
    this.isLoading = false,
    this.continueLabel = "Continue",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isLoading ? null : onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: Size(double.infinity, SizeConfig.h(56)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: isLoading
              ? const BouncingDotsIndicator(color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      continueLabel,
                      style: TextStyle(
                        fontSize: SizeConfig.sp(16),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(8)),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),

        if (onGoogleSignIn != null) ...[
          SizedBox(height: SizeConfig.h(20)),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[200])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
                child: Text(
                  "Or continue with",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: SizeConfig.sp(12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[200])),
            ],
          ),
          SizedBox(height: SizeConfig.h(20)),

          OutlinedButton(
            onPressed: isLoading ? null : onGoogleSignIn,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.8),
              side: const BorderSide(color: Colors.white),
              minimumSize: Size(double.infinity, SizeConfig.h(56)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              shadowColor: Colors.black12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeConfig.w(8)),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'lib/assets/icons/google.png',
                    height: SizeConfig.h(20),
                    width: SizeConfig.h(20),
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: SizeConfig.w(12)),
                Text(
                  "Google",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
