import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../components/auth/auth_scaffold.dart';
import '../../components/auth/animated_input_field.dart';
import '../../components/auth/auth_navigation_buttons.dart';
import '../../components/auth/auth_glass_card.dart';
import '../../utils/size_config.dart';
import '../../utils/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../utils/transitions.dart';
import '../../pages/onboarding_page.dart';
import '../../pages/home_page.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
        _showError("Please enter your email address.");
        return;
      }

      final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        _showError("Please enter a valid email address.");
        return;
      }

      _nextStep();
      return;
    }

    if (_currentStep == 1) {
      if (passwordController.text.isEmpty) {
        _showError("Please enter your password.");
        return;
      }
      await _loginAction();
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _loginAction() async {
    setState(() => _isLoading = true);

    try {
      final cred = await ref
          .read(authServiceProvider)
          .signInWithEmailPassword(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      await ref.read(authServiceProvider).initializeUserData();

      if (mounted) {
        if (cred.additionalUserInfo?.isNewUser ?? false) {
          Navigator.pushReplacement(
            context,
            FadeScalePageRoute(page: const OnboardingPage()),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            FadeScalePageRoute(page: const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLoginAction() async {
    setState(() => _isLoading = true);
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();

      await ref.read(authServiceProvider).initializeUserData();

      if (mounted) {
        if (cred.additionalUserInfo?.isNewUser ?? false) {
          Navigator.pushReplacement(
            context,
            FadeScalePageRoute(page: const OnboardingPage()),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            FadeScalePageRoute(page: const HomeScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    String title = "Welcome Back";
    String subtitle = "Enter your email to sign in to your account.";
    if (_currentStep == 1) {
      title = "Enter Password";
      subtitle = "Welcome back, ${emailController.text.trim()}";
    }

    final bool showBack = true;

    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          setState(() => _currentStep--);
          return false;
        }
        return true;
      },
      child: AuthScaffold(
        flow: AuthFlow.login,
        title: title,
        subtitle: subtitle,
        showBackButton: showBack,
        currentStep: _currentStep,
        onBack: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            Navigator.pop(context);
          }
        },
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.2, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: _currentStep == 0
                              ? _buildEmailStep()
                              : _buildPasswordStep(),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(24),
                        ).copyWith(bottom: SizeConfig.h(24)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AuthNavigationButtons(
                              onContinue: _handleContinue,
                              onGoogleSignIn: _currentStep == 0
                                  ? _googleLoginAction
                                  : null,
                              isLoading: _isLoading,
                              continueLabel: _currentStep == 0
                                  ? "Continue"
                                  : "Log In",
                            ),
                            SizedBox(height: SizeConfig.h(24)),

                            if (_currentStep == 0)
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    FadeScalePageRoute(
                                      page: const RegisterPage(),
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: SizeConfig.sp(14),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Sign Up",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: SizeConfig.sp(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            if (_currentStep == 1)
                              TextButton(
                                onPressed: () {
                                  setState(() => _currentStep = 0);
                                },
                                child: Text(
                                  "Switch Account",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: SizeConfig.sp(14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('step0'), // Key forces rebuild for animation
        children: [
          AuthGlassCard(
            child: AnimatedInputField(
              controller: emailController,
              label: "Email Address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              delayMs: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('step1'),
        children: [
          AuthGlassCard(
            child: Column(
              children: [
                AnimatedInputField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  delayMs: 200,
                ),
                SizedBox(height: SizeConfig.h(10)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeScalePageRoute(page: const ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.sp(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
