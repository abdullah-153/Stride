import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/auth/auth_scaffold.dart';
import '../components/auth/animated_input_field.dart';
import '../components/auth/auth_navigation_buttons.dart';
import '../components/auth/auth_glass_card.dart';
import '../utils/size_config.dart';
import '../utils/app_constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore/user_profile_firestore_service.dart';
import '../models/user_profile_model.dart';
import '../utils/transitions.dart';
import '../pages/onboarding_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';

import 'package:email_otp/email_otp.dart';
import '../components/auth/premium_otp_section.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Page Controller
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  bool _tosAgreed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<void> _handleContinue() async {
    // Step 0: Name
    if (_currentStep == 0) {
      if (nameController.text.trim().isEmpty) {
        _showError("Please enter your name.");
        return;
      }
      _nextStep();
      return;
    }
    
    // Step 1: Email
    if (_currentStep == 1) {
      if (emailController.text.trim().isEmpty) {
        _showError("Please enter your email.");
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

    // Step 2: Password & TOS
    if (_currentStep == 2) {
      if (passwordController.text.isEmpty) {
        _showError("Please enter a password.");
        return;
      }
      if (passwordController.text.length < 6) {
        _showError("Password must be at least 6 characters.");
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        _showError("Passwords do not match.");
        return;
      }
      if (!_tosAgreed) {
        _showError("Please agree to the Terms and Conditions.");
        return;
      }

      // Check if account exists and Send OTP
      FocusScope.of(context).unfocus();
      await _sendOtp();
    }
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      // 1. Check if email already used (Removed hacky check, will be handled at registration)
      // We proceed to verification first. If email is taken, it will fail at the final step.
      if (emailController.text.trim().isEmpty) { 
        _showError("Please enter your email."); 
        return; 
      }

      // 2. Configure OTP (Static)
      EmailOTP.config(
        appName: 'Fitness Tracker',
        otpType: OTPType.numeric,
        emailTheme: EmailTheme.v4,
        otpLength: 4,
      );

      // 3. Configure SMTP (Gmail requires App Password if 2FA is on)
      EmailOTP.setSMTP(
        host: 'smtp.gmail.com',
        emailPort: EmailPort.port587,
        secureType: SecureType.tls,
        username: 'kanpeki.dev@gmail.com',
        password: 'zpjfutkgunazxkfo',
      );

      // 4. Send OTP
      final sent = await EmailOTP.sendOTP(email: emailController.text.trim());
      if (!mounted) return;
      if (sent) {
        _nextStep(); // Move to OTP screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification code sent to your email")),
        );
      } else {
        _showError("Failed to send code. Check credentials (use App Password for Gmail) or internet.");
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isLoading = true);
    try {
      // 1. Register with Firebase Auth
      final cred = await ref.read(authServiceProvider).registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      // 2. Create Firestore Profile
      if (cred.user != null) {
        final profileService = UserProfileFirestoreService();
        await profileService.createUserProfile(
          cred.user!.uid,
          UserProfile(
            name: nameController.text.trim(),
            bio: "Ready to get fit!",
            weight: 70.0,
            height: 170.0,
            age: 25,
          ),
        );
      }

      // 3. Initialize gamification data
      await ref.read(authServiceProvider).initializeUserData();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadeScalePageRoute(page: const OnboardingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleLoginAction() async {
     setState(() => _isLoading = true);
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();

      // Initialize user data (creates profile/gamification if missing)
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
    
    // Determine title/subtitle based on step
    String title = "Create Account";
    String subtitle = "Join us to start your fitness journey";
    bool showNavButtons = true;

    if (_currentStep == 0) {
      title = "What's your name?";
      subtitle = "Let's get to know each other";
    } else if (_currentStep == 3) {
      title = "Verify Identity";
      subtitle = "Enter the 4-digit code sent to ${emailController.text}";
      showNavButtons = false; 
    } else if (_currentStep == 1) {
      title = "Your Email";
      subtitle = "Where can we reach you?";
    } else if (_currentStep == 2) {
      title = "Set Password";
      subtitle = "Secure your account";
    }

    return WillPopScope(
      onWillPop: () async {
        _previousStep();
        return false;
      },
      child: AuthScaffold(
        flow: _currentStep == 3 ? AuthFlow.otp : AuthFlow.register,
        title: title,
        subtitle: subtitle,
        isFullPage: _currentStep == 3,
        showBackButton: true,
        currentStep: _currentStep,
        onBack: () => _previousStep(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(opacity: animation, child: SlideTransition(
                               position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(animation),
                               child: child
                             ));
                          },
                          child: _buildCurrentStep(),
                        ),
                      ),
                      
                      if (showNavButtons)
                        Padding(
                          padding: EdgeInsets.symmetric(
                             horizontal: SizeConfig.w(24),
                          ).copyWith(bottom: SizeConfig.h(20)),
                          child: Column(
                            children: [
                              AuthNavigationButtons(
                                onContinue: _handleContinue,
                                onGoogleSignIn: _currentStep == 0 ? _googleLoginAction : null,
                                isLoading: _isLoading,
                                continueLabel: _currentStep == 2 ? "Create Account" : "Continue",
                              ),
                              SizedBox(height: SizeConfig.h(20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.grey[600], fontSize: SizeConfig.sp(14)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                       Navigator.pushReplacement(
                                         context,
                                         FadeScalePageRoute(page: const LoginPage()),
                                       );
                                    },
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: SizeConfig.sp(14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildNameStep();
      case 1: return _buildEmailStep();
      case 2: return _buildPasswordStep();
      case 3: return _buildOtpStep();
      default: return _buildNameStep();
    }
  }

  Widget _buildNameStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('step0'),
        children: [
          AuthGlassCard(
            child: AnimatedInputField(
              controller: nameController,
              label: "Full Name",
              icon: Icons.person_outline_rounded,
              delayMs: 200,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmailStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(24)),
      child: Column(
        key: const ValueKey('step1'),
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
        key: const ValueKey('step2'),
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
                 SizedBox(height: SizeConfig.h(10)), // Reduced spacing inside card
                 AnimatedInputField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                   delayMs: 300,
                 ),
               ],
             ),
           ),
           SizedBox(height: SizeConfig.h(20)),
           _buildTOSCheck(),
        ],
      ),
    );
  }

  Widget _buildOtpStep() {
    return PremiumOTPSection(
      key: const ValueKey('step3'),
      email: emailController.text.trim(),
      onVerified: _completeRegistration,
      onVerifyCode: (code) async {
        setState(() => _isLoading = true);
        try {
          final isValid = EmailOTP.verifyOTP(otp: code);
          return isValid;
        } catch (e) {
          return false;
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      },
      onResend: () async {
        await EmailOTP.sendOTP(email: emailController.text.trim());
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Code resent!"))
           );
        }
      },
      isLoading: _isLoading,
    );
  }

  Widget _buildTOSCheck() => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeOut,
    builder: (context, value, child) => Opacity(opacity: value, child: child),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: _tosAgreed,
          onChanged: (v) => setState(() => _tosAgreed = v ?? false),
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        SizedBox(width: SizeConfig.w(5)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: SizeConfig.sp(12),
              ),
              children: [
                const TextSpan(text: "By creating an account you agree to our "),
                TextSpan(
                  text: "Terms and Conditions",
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
