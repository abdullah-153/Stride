import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../components/shared/password_field.dart';
import '../utils/size_config.dart';
import '../utils/app_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _tosAgreed = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  void handleRegister() {
    if ([
      emailController,
      nameController,
      passwordController,
      confirmPasswordController,
    ].any((c) => c.text.trim().isEmpty)) {
      showError("Please enter all required information.");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showError("Passwords do not match.");
      return;
    }

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, size: SizeConfig.w(30)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.only(
          left: SizeConfig.w(28),
          right: SizeConfig.w(28),
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.h(14)),

            Text(
              "Create Account",
              style: TextStyle(
                fontSize: SizeConfig.sp(40),
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              "Your next workout starts here.",
              style: TextStyle(
                fontSize: SizeConfig.sp(18),
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: SizeConfig.h(80)),

            _textInput(nameController, "Full Name"),
            SizedBox(height: SizeConfig.h(20)),
            _textInput(emailController, "Email"),
            SizedBox(height: SizeConfig.h(20)),
            PasswordField(
              label: "Password",
              controller: passwordController,
              vpad: 11,
              fSize: 12,
            ),
            SizedBox(height: SizeConfig.h(20)),
            PasswordField(
              label: "Confirm Password",
              controller: confirmPasswordController,
              vpad: 11,
              fSize: 12,
            ),
            SizedBox(height: SizeConfig.h(6)),

            _buildTOSCheck(),
            SizedBox(height: SizeConfig.h(60)),

            _loginRedirect(context),
            SizedBox(height: SizeConfig.h(10)),

            Center(
              child: ElevatedButton(
                onPressed: _tosAgreed ? handleRegister : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tosAgreed ? Colors.black : Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(SizeConfig.w(235), SizeConfig.h(55)),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: SizeConfig.sp(16),
                    fontWeight: FontWeight.bold,
                    color: _tosAgreed ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textInput(TextEditingController c, String label) {
    return TextField(
      controller: c,
      style: TextStyle(fontSize: SizeConfig.sp(14), color: Colors.black87),
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(color: Colors.black),
        labelText: label,
        labelStyle: TextStyle(fontSize: SizeConfig.sp(12)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.w(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: SizeConfig.w(3)),
          borderRadius: BorderRadius.circular(SizeConfig.w(15)),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.h(15),
          horizontal: SizeConfig.w(15),
        ),
      ),
    );
  }

  Widget _buildTOSCheck() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Checkbox(
        value: _tosAgreed,
        onChanged: (v) => setState(() => _tosAgreed = v ?? false),
        checkColor: Colors.white,
        activeColor: Colors.black,
      ),
      SizedBox(width: SizeConfig.w(5)),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.black87,
              fontSize: SizeConfig.sp(10),
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
  );

  Widget _loginRedirect(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Already have an account?",
        style: TextStyle(color: Colors.black54, fontSize: SizeConfig.sp(12)),
      ),
      SizedBox(width: SizeConfig.w(5)),
      GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        child: Text(
          "Sign In",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: SizeConfig.sp(12),
          ),
        ),
      ),
    ],
  );
}
