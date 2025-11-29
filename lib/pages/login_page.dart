import 'package:flutter/material.dart';
import '../components/shared/password_field.dart';
import '../utils/size_config.dart';
import '../utils/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  void loginButtonAction() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please enter all required information.");
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, size: SizeConfig.w(30)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: SizeConfig.screenWidth * 0.85,
          height: SizeConfig.screenHeight * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.h(20)),
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: SizeConfig.sp(40),
                ),
              ),
              Text(
                "Your next workout awaits.",
                style: TextStyle(
                  fontSize: SizeConfig.sp(18),
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: SizeConfig.h(40)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(SizeConfig.w(300), SizeConfig.h(55)),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeConfig.h(25),
                      width: SizeConfig.w(25),
                      child: Image.asset(
                        'lib/assets/icons/google.png',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(20)),
                    Text(
                      "Continue using Google",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.sp(12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.h(40)),

              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(10)),
                    child: Text(
                      "Or",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: SizeConfig.sp(14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(30)),

              TextField(
                controller: emailController,
                style: TextStyle(
                  fontSize: SizeConfig.sp(16),
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  labelText: "Email",
                  labelStyle: TextStyle(fontSize: SizeConfig.sp(12)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SizeConfig.w(10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 3),
                    borderRadius: BorderRadius.circular(SizeConfig.w(15)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: SizeConfig.h(15),
                    horizontal: SizeConfig.w(15),
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.h(20)),

              PasswordField(
                label: "Password",
                controller: passwordController,
                vpad: 16,
                fSize: 12,
              ),
              SizedBox(height: SizeConfig.h(5)),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: SizeConfig.sp(11),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(95)),

              _registerRedirect(context),

              SizedBox(height: SizeConfig.h(14)),

              Center(
                child: ElevatedButton(
                  onPressed: loginButtonAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size(SizeConfig.w(235), SizeConfig.h(55)),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: SizeConfig.sp(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerRedirect(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account?",
        style: TextStyle(color: Colors.black54, fontSize: SizeConfig.sp(12)),
      ),
      SizedBox(width: SizeConfig.w(5)),
      GestureDetector(
        onTap: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.register),
        child: Text(
          "Register",
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
