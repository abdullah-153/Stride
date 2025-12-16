import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/auth/auth_scaffold.dart';
import '../../components/auth/animated_input_field.dart';
import '../../components/auth/auth_navigation_buttons.dart';
import '../../utils/size_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _handleContinue() async {
    if (_currentStep == 0) {
      if (emailController.text.trim().isEmpty) {
        _showError("Please enter your email.");
        return;
      }
      final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        _showError("Please enter a valid email address.");
        return;
      }

      try {
        setState(() => _isLoading = true);
        final signInMethods = await ref
            .read(authServiceProvider)
            .checkEmailExists(emailController.text.trim());
        if (signInMethods.isEmpty) {
          _showError("No account found with this email.");
          return;
        }
      } catch (e) {
        _showError("An error occurred. Please try again.");
        return;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }

      await _sendResetEmail();
    }

    if (_currentStep == 1) {
      Navigator.pop(context);
    }
  }

  Future<void> _sendResetEmail() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordResetEmail(emailController.text.trim());

      setState(() {
        _currentStep++;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      });
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    String title = "Forgot Password?";
    String subtitle = "Don't worry, it happens to the best of us.";
    if (_currentStep == 1) {
      title = "Check your mail";
      subtitle = "We have sent a password recover instructions to your email.";
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: AuthScaffold(
        flow: AuthFlow.forgotPassword,
        title: title,
        subtitle: subtitle,
        showBackButton:
            _currentStep ==
            0, // Hide back button on success step to force "Back to Login" flow
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildEmailStep(), _buildSuccessStep()],
              ),
            ),

            Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(20),
                left: SizeConfig.w(24),
                right: SizeConfig.w(24),
              ),
              child: AuthNavigationButtons(
                onContinue: _handleContinue,
                isLoading: _isLoading,
                continueLabel: _currentStep == 0
                    ? "Send Instructions"
                    : "Back to Login",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('fp_step0'),
        children: [
          AnimatedInputField(
            controller: emailController,
            label: "Email Address",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            delayMs: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('fp_step1'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.w(30)),
            decoration: BoxDecoration(
              color: Colors.green[50], // Light green bg
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 50,
              color: Colors.green,
            ),
          ),
          SizedBox(height: SizeConfig.h(24)),
          Text(
            "Email Sent!",
            style: TextStyle(
              fontSize: SizeConfig.sp(20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
